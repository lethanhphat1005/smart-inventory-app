import { StatusCodes } from 'http-status-codes';
import { v4 as uuidv4 } from 'uuid';

import { CustomError } from '../../../common/errors/index.js';
import {
  COORDINATOR_MODEL,
  COORDINATOR_TEMPERATURE,
  DRAFT_TTL_SECONDS,
  FRIENDLY_REPLY_MODEL,
  FRIENDLY_REPLY_TEMPERATURE,
  LOCK_TTL_SECONDS,
} from '../chatbot.constants.js';
import {
  buildChatDraftKey,
  buildChatLockKey,
  buildCoordinatorMessages,
  findExactInventoryMatch,
} from '../chatbot.mapper.js';
import { getFriendlyReplyPrompt } from '../chatbot.prompt.js';
import { CHAT_TOOLS } from '../tools/tool-registry.js';

import type { ChatMemoryService } from './chat-memory.service.js';
import type { ListInventoriesQueryDto } from '../../inventories/dto/inventory.dto.js';
import type { InventoryService } from '../../inventories/index.js';
import type { TransactionService } from '../../transactions/transaction.service.js';
import type { ChatbotRequestDto, ChatbotResponseDto } from '../chatbot.dto.js';
import type {
  ChatHistoryMessage,
  DraftAction,
  DraftActionType,
  InventoryItemData,
  LLMToolParams,
  TransactionItemPayload,
  TransactionPayload,
} from '../chatbot.type.js';
import type { LLMProvider } from '../llm/llm.provider.js';
import type { Redis } from 'ioredis';

export class ChatbotService {
  constructor(
    private readonly inventoryService: InventoryService,
    private readonly transactionService: TransactionService,
    private readonly redisClient: Redis,
    private readonly chatMemoryService: ChatMemoryService,
    private readonly llmProvider: LLMProvider,
  ) {}

  // tạo reply cho mọi request của user
  private async generateFriendlyReply(
    userMessage: string,
    systemContext: string,
  ): Promise<string> {
    try {
      const response = await this.llmProvider.createChatCompletion({
        model: FRIENDLY_REPLY_MODEL,
        temperature: FRIENDLY_REPLY_TEMPERATURE,
        messages: [
          {
            role: 'system',
            content: getFriendlyReplyPrompt(),
          },
          {
            role: 'user',
            content: `Câu nói: "${userMessage}"\nDữ liệu: ${systemContext}`,
          },
        ],
      });

      return response.choices[0]?.message?.content ?? systemContext;
    } catch (error) {
      console.error('[AI Responder Error]', error);

      return systemContext;
    }
  }

  // tạo streaming reply cho các response thuần text
  // private async *streamFriendlyReply(
  //   userMessage: string,
  //   systemContext: string,
  // ): AsyncGenerator<string, string, void> {
  //   try {
  //     const stream = await this.llmProvider.createChatCompletionStream({
  //       model: FRIENDLY_REPLY_MODEL,
  //       stream: true,
  //       temperature: FRIENDLY_REPLY_TEMPERATURE,
  //       messages: [
  //         {
  //           role: 'system',
  //           content: getFriendlyReplyPrompt(),
  //         },
  //         {
  //           role: 'user',
  //           content: `Câu nói: "${userMessage}"\nDữ liệu: ${systemContext}`,
  //         },
  //       ],
  //     });

  //     let fullReply = '';

  //     for await (const chunk of stream) {
  //       const delta = chunk.choices[0]?.delta?.content ?? '';

  //       if (!delta) {
  //         continue;
  //       }

  //       fullReply += delta;
  //       yield delta;
  //     }

  //     return fullReply;
  //   } catch (error) {
  //     console.error('[AI Responder Error]', error);

  //     return systemContext;
  //   }
  // }

  // private async collectStream(
  //   stream: AsyncGenerator<string, string, void>,
  // ): Promise<string> {
  //   let full = '';

  //   for await (const chunk of stream) {
  //     full += chunk;
  //   }

  //   return full;
  // }

  // private async generateStreamFriendlyReply(
  //   userMessage: string,
  //   systemContext: string,
  // ): Promise<string> {
  //   const stream = this.streamFriendlyReply(userMessage, systemContext);

  //   return await this.collectStream(stream);
  // }

  public async processMessage(
    storeId: string,
    userId: string,
    payload: ChatbotRequestDto,
  ): Promise<ChatbotResponseDto> {
    const lockKey = buildChatLockKey(storeId, userId);

    const acquired = await this.redisClient.set(
      lockKey,
      'locked',
      'EX',
      LOCK_TTL_SECONDS,
      'NX',
    );

    if (!acquired) {
      throw new CustomError({
        message:
          'Tori đang suy nghĩ câu hỏi trước của bạn, vui lòng đợi vài giây nhé! ⏳',
        status: StatusCodes.TOO_MANY_REQUESTS,
      });
    }

    try {
      const previousHistory = await this.chatMemoryService.getChatHistory(
        storeId,
        userId,
      );

      const messages = buildCoordinatorMessages(
        storeId,
        userId,
        previousHistory,
        payload.message,
      );

      const cart = await this.chatMemoryService.getCartSession(storeId, userId);

      if (cart && cart.items.length > 0) {
        const cartDetails = cart.items
          .map((i) => `${i.quantity} ${i.displayName}`)
          .join(', ');
        const actionName = cart.type === 'create_export' ? 'XUẤT' : 'NHẬP';

        // Chèn ngay sau system prompt để AI luôn nhớ trạng thái giỏ hàng
        messages.splice(1, 0, {
          role: 'system',
          content: `[TRẠNG THÁI GIỎ HÀNG TẠM]: Người dùng đang có một phiên ${actionName} kho chưa hoàn tất. Các mặt hàng đã thêm: ${cartDetails}. Hãy ưu tiên xử lý tiếp phiên này.`,
        });
      }

      const messagesToSave: ChatHistoryMessage[] = [
        { role: 'user', content: payload.message },
      ];

      const response = await this.llmProvider.createChatCompletion({
        model: COORDINATOR_MODEL,
        messages,
        tools: CHAT_TOOLS,
        tool_choice: 'auto',
        temperature: COORDINATOR_TEMPERATURE,
      });

      const responseMessage = response.choices[0]?.message;
      const toolCalls = responseMessage?.tool_calls;

      let finalResponse: ChatbotResponseDto;

      if (toolCalls && toolCalls.length > 0) {
        messagesToSave.push(responseMessage as ChatHistoryMessage);

        const toolCall = toolCalls[0];

        if (!toolCall || toolCall.type !== 'function') {
          finalResponse = {
            aiIntent: 'unknown',
            botReply: 'Lỗi truy xuất công cụ hệ thống.',
          };

          messagesToSave.push({
            role: 'tool',
            tool_call_id: toolCall?.id || 'unknown',
            content: 'Lỗi hệ thống: Không thể xử lý tool.',
          });
        } else {
          const intent = toolCall.function.name;
          let params: LLMToolParams = {};

          try {
            if (toolCall.function.arguments) {
              params = JSON.parse(toolCall.function.arguments) as LLMToolParams;
            }
          } catch (e) {
            console.error('Lỗi parse arguments từ tool:', e);
          }

          const validationResult = this.isToolCallEligible(
            intent,
            params,
            payload.message,
          );

          if (!validationResult.isValid) {
            finalResponse = {
              aiIntent: 'clarify',
              botReply: await this.generateFriendlyReply(
                payload.message,
                validationResult.reason ||
                  'Thông tin chưa đủ, yêu cầu người dùng làm rõ.',
              ),
            };

            messagesToSave.push({
              role: 'tool',
              tool_call_id: toolCall.id,
              content: `Bị chặn bởi Guardrail: ${validationResult.reason}`,
            });
          } else {
            switch (intent) {
              case 'get_low_stock':
                finalResponse = await this.handleGetLowStock(
                  storeId,
                  payload.message,
                );
                break;
              case 'get_product_info':
                finalResponse = await this.handleGetProductInfo(
                  storeId,
                  params.product_name,
                  payload.message,
                );
                break;
              case 'create_export':
                finalResponse = await this.handleTransactionDraft(
                  storeId,
                  userId,
                  'create_export',
                  params,
                  payload.message,
                );
                break;
              case 'create_import':
                finalResponse = await this.handleTransactionDraft(
                  storeId,
                  userId,
                  'create_import',
                  params,
                  payload.message,
                );
                break;
              default:
                finalResponse = {
                  aiIntent: 'unknown',
                  botReply: await this.generateFriendlyReply(
                    payload.message,
                    'Dạ, tính năng này hiện chưa khả dụng trên hệ thống.',
                  ),
                };
            }

            const toolContent = finalResponse.data
              ? JSON.stringify(finalResponse.data)
              : finalResponse.aiIntent.includes('confirm')
                ? 'Đã tạo Draft, chờ xác nhận'
                : 'Không có dữ liệu';

            messagesToSave.push({
              role: 'tool',
              tool_call_id: toolCall.id,
              content: toolContent,
            });
          }
        }
      } else {
        finalResponse = {
          aiIntent: 'unknown',
          botReply: await this.generateFriendlyReply(
            payload.message,
            `LỆNH KIỂM DUYỆT HỆ THỐNG: Người dùng đang chat một câu không yêu cầu gọi tool. 
            - Nếu đây là lời chào hỏi cơ bản, hãy chào lại thân thiện.
            - Nếu đây là câu hỏi kiến thức ngoài luồng (như người nổi tiếng, lịch sử, toán học, code...), TUYỆT ĐỐI KHÔNG trả lời nội dung. BẮT BUỘC áp dụng CÔNG THỨC TỪ CHỐI trong quy tắc "KỶ LUẬT NGOÀI LUỒNG".`,
          ),
        };
      }

      messagesToSave.push({
        role: 'assistant',
        content: finalResponse.botReply,
      });

      if (finalResponse.aiIntent !== 'unknown') {
        await this.chatMemoryService.saveChatHistory(
          storeId,
          userId,
          messagesToSave,
        );
      } else {
        // Nếu user hỏi lan man quá nhiều, chủ động clear history luôn để reset AI
        // (Tùy chọn: bạn có thể bỏ dòng này nếu muốn nhẹ tay hơn)
        await this.chatMemoryService.clearChatHistory(storeId, userId);
      }

      return finalResponse;
    } catch (error) {
      console.error('[Chatbot Error]', error);
      throw new CustomError({
        message: 'Lỗi kết nối với hệ thống mô hình AI',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    } finally {
      await this.redisClient.del(lockKey);
    }
  }

  private isToolCallEligible(
    intent: string,
    params: LLMToolParams,
    userMessage: string,
  ): { isValid: boolean; reason?: string } {
    const normalizedMessage = userMessage.toLowerCase();

    // 1. Chặn lỗi META-IN-DOMAIN: Người dùng chỉ đang "hỏi cách dùng" chứ không muốn thực thi
    const metaKeywords = ['cách', 'làm sao', 'hướng dẫn', 'có thể', 'hỗ trợ'];
    const isAskingForHelp = metaKeywords.some((kw) =>
      normalizedMessage.includes(kw),
    );

    if (isAskingForHelp) {
      return {
        isValid: false,
        reason:
          'Người dùng chỉ đang hỏi cách sử dụng hệ thống hoặc hỏi về chức năng, không yêu cầu thực thi. Hãy giải thích chức năng cho họ, TUYỆT ĐỐI không bịa dữ liệu.',
      };
    }

    // 2. Validate từng intent cụ thể
    switch (intent) {
      case 'get_product_info':
        if (!params.product_name || params.product_name.trim() === '') {
          return {
            isValid: false,
            reason:
              'Bạn đang tìm sản phẩm nào vậy? Hãy cho Tori biết tên sản phẩm nhé.',
          };
        }
        break;

      case 'create_import':
      case 'create_export': {
        const items = params.products || [];
        const hasSingleItem = params.product_name && params.quantity;

        if (items.length === 0 && !hasSingleItem) {
          return {
            isValid: false,
            reason: `Bạn muốn ${intent === 'create_import' ? 'nhập' : 'xuất'} sản phẩm gì và số lượng bao nhiêu? Cung cấp đủ thông tin để Tori tạo phiếu nhé.`,
          };
        }

        // Kiểm tra xem số lượng có hợp lý không (tránh AI bịa số âm hoặc số 0)
        if (hasSingleItem && Number(params.quantity) <= 0) {
          return { isValid: false, reason: 'Số lượng phải lớn hơn 0 bạn nhé.' };
        }
        break;
      }

      case 'get_low_stock':
        // get_low_stock không cần tham số, luôn hợp lệ nếu đi qua được check Meta-in-domain
        break;
      default:
        break;
    }

    return { isValid: true };
  }

  public async confirmDraftAction(
    draftActionId: string,
    isConfirmed: boolean,
  ): Promise<string> {
    const draftKey = buildChatDraftKey(draftActionId);
    const draftData = await this.redisClient.get(draftKey);

    if (!draftData) {
      throw new CustomError({
        message: 'Yêu cầu đã hết hạn hoặc không tồn tại (quá 5 phút).',
        status: StatusCodes.GONE,
      });
    }

    const draft = JSON.parse(draftData) as DraftAction;

    if (!isConfirmed) {
      await this.redisClient.del(draftKey); // Xóa khỏi Redis

      await this.chatMemoryService.clearChatHistory(
        draft.storeId,
        draft.userId,
      );

      // WARN: Những chỗ như này nếu nhập string khác thì sao?
      return await this.generateFriendlyReply(
        'Tôi muốn hủy giao dịch',
        'Đã hủy thao tác.',
      );
    }

    if (draft.type === 'create_import') {
      await this.transactionService.createImportTransaction(
        draft.storeId,
        draft.userId,
        draft.payload,
      );
    } else {
      await this.transactionService.createExportTransaction(
        draft.storeId,
        draft.userId,
        draft.payload,
      );
    }

    await this.redisClient.del(draftKey);

    await this.chatMemoryService.clearChatHistory(draft.storeId, draft.userId);
    await this.chatMemoryService.clearCartSession(draft.storeId, draft.userId);

    return await this.generateFriendlyReply(
      'Xác nhận thành công',
      'Tuyệt vời! Giao dịch đã được ghi nhận vào hệ thống.',
    );
  }

  private async handleGetLowStock(
    storeId: string,
    userMessage: string,
  ): Promise<ChatbotResponseDto> {
    const query = {
      limit: 100,
      page: 1,
      sortBy: 'quantity',
      sortOrder: 'asc',
    } as unknown as ListInventoriesQueryDto;
    const res = await this.inventoryService.getInventoriesByStoreId(
      storeId,
      query,
    );

    // NOTE: Nếu số lượng kết quả > 100 -> điều hướng user tới màn hình lowstock

    const allLowStockItems = (res.items as InventoryItemData[]).filter(
      (item) =>
        item.quantity <= (item.reorder_threshold ?? item.reorderThreshold ?? 0),
    );

    const totalCount = allLowStockItems.length;
    const displayItems = allLowStockItems.slice(0, 5);

    const systemContext =
      totalCount > 0
        ? `Có tổng cộng ${totalCount} sản phẩm chạm mức cảnh báo. Danh sách 5 sản phẩm cạn kiệt nhất: ${displayItems.map((i) => i.productPackage.displayName).join(', ')}`
        : 'Tuyệt vời, hiện tại không có sản phẩm nào chạm mức cảnh báo!';

    return {
      aiIntent: 'get_low_stock',
      botReply: await this.generateFriendlyReply(userMessage, systemContext),
      data: { totalCount, items: displayItems },
    };
  }

  private async handleGetProductInfo(
    storeId: string,
    productName: string | undefined,
    userMessage: string,
  ): Promise<ChatbotResponseDto> {
    if (!productName) {
      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(
          userMessage,
          'Yêu cầu người dùng cung cấp tên sản phẩm cần tìm.',
        ),
      };
    }

    const searchResult = await this.searchInventory(storeId, productName);

    if (searchResult.length === 0) {
      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(
          userMessage,
          `Không tìm thấy "${productName}" trong kho.`,
        ),
      };
    }

    const exactMatch = findExactInventoryMatch(searchResult, productName);
    const firstResult = searchResult[0];

    if (exactMatch) {
      const context = `Sản phẩm ${exactMatch.productPackage.displayName} có giá bán ${exactMatch.productPackage.sellingPrice} VNĐ.
                        Tồn kho: ${exactMatch.quantity} ${exactMatch.productPackage.unit.name}.`;

      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(userMessage, context),
        data: exactMatch,
      };
    }

    if (searchResult.length === 1 && firstResult) {
      const context = `Sản phẩm ${firstResult.productPackage.displayName} có giá bán ${firstResult.productPackage.sellingPrice} VNĐ.
                        Tồn kho: ${firstResult.quantity} ${firstResult.productPackage.unit.name}.`;

      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(userMessage, context),
        data: firstResult,
      };
    }

    return {
      aiIntent: 'choose_product',
      botReply: await this.generateFriendlyReply(
        userMessage,
        `Hệ thống tìm thấy nhiều kết quả cho "${productName}". HÃY NÓI NGẮN GỌN: "Tori tìm thấy vài sản phẩm tương tự. Bạn vui lòng chọn chính xác ở danh sách bên dưới nhé 👇". TUYỆT ĐỐI KHÔNG tự liệt kê sản phẩm.`,
      ),
      data: { originalIntent: 'get_product_info', items: searchResult },
    };
  }

  private async handleTransactionDraft(
    storeId: string,
    userId: string,
    intent: DraftActionType,
    params: LLMToolParams,
    userMessage: string,
  ): Promise<ChatbotResponseDto> {
    let itemsToProcess = params.products || [];

    if (itemsToProcess.length === 0 && params.product_name && params.quantity) {
      itemsToProcess = [
        { product_name: params.product_name, quantity: params.quantity },
      ];
    }

    if (itemsToProcess.length === 0) {
      return {
        aiIntent: intent,
        botReply: await this.generateFriendlyReply(
          userMessage,
          'Yêu cầu người dùng cho biết tên sản phẩm và số lượng muốn thao tác.',
        ),
      };
    }

    const isExport = intent === 'create_export';
    const actionText = isExport ? 'XUẤT KHO' : 'NHẬP KHO';

    // 1. LẤY GIỎ HÀNG HIỆN TẠI (hoặc tạo mới)
    let cart = await this.chatMemoryService.getCartSession(storeId, userId);

    if (!cart || cart.type !== intent) {
      cart = { type: intent, items: [] };
    }

    for (const item of itemsToProcess) {
      if (!item.product_name || !item.quantity) {
        continue;
      }

      const searchResult = await this.searchInventory(
        storeId,
        item.product_name,
      );

      if (searchResult.length === 0) {
        return {
          aiIntent: intent,
          botReply: await this.generateFriendlyReply(
            userMessage,
            `Lỗi: Không tìm thấy "${item.product_name}". Các mặt hàng trước đó vẫn được giữ trong giỏ.`,
          ),
        };
      }

      // Xử lý exact match (đã rút gọn cho dễ đọc, bạn giữ nguyên logic match của bạn)
      let targetItem: InventoryItemData;
      const exactMatch = findExactInventoryMatch(
        searchResult,
        item.product_name,
      );

      if (exactMatch) {
        targetItem = exactMatch;
      } else if (searchResult.length === 1) {
        targetItem = searchResult[0]!;
      } else {
        return {
          aiIntent: 'choose_product',
          botReply: await this.generateFriendlyReply(
            userMessage,
            `Tìm thấy nhiều mặt hàng giống "${item.product_name}". HÃY NÓI NGẮN GỌN: "Có vài sản phẩm trùng tên, bạn click chọn đúng loại muốn ${isExport ? 'xuất' : 'nhập'} ở bên dưới giúp Tori nha 👇". TUYỆT ĐỐI KHÔNG tự liệt kê.`,
          ),
          data: {
            originalIntent: intent,
            quantity: item.quantity,
            items: searchResult,
          },
        };
      }

      const pkg = targetItem.productPackage;
      const price = isExport
        ? Number(pkg.sellingPrice)
        : Number(pkg.importPrice);

      // 2. LOGIC CỘNG DỒN GIỎ HÀNG
      const existingItem = cart.items.find(
        (i) => i.productPackageId === pkg.productPackageId,
      );
      const newQuantity = existingItem
        ? existingItem.quantity + Number(item.quantity)
        : Number(item.quantity);

      // Validate tồn kho với TỔNG SỐ LƯỢNG (cũ + mới)
      if (isExport && targetItem.quantity < newQuantity) {
        return {
          aiIntent: intent,
          botReply: await this.generateFriendlyReply(
            userMessage,
            `Lỗi: Không đủ hàng. Kho còn ${targetItem.quantity}, nhưng bạn đang muốn xuất tổng cộng ${newQuantity} (tính cả trong giỏ).`,
          ),
        };
      }

      // Cập nhật mảng items trong Cart
      if (existingItem) {
        existingItem.quantity = newQuantity;
      } else {
        cart.items.push({
          productPackageId: pkg.productPackageId,
          displayName: pkg.displayName,
          quantity: Number(item.quantity),
          unitPrice: price,
        });
      }
    }

    // 3. LƯU GIỎ HÀNG VÀO REDIS
    await this.chatMemoryService.saveCartSession(storeId, userId, cart);

    // 4. TẠO LẠI DRAFT VỚI TOÀN BỘ GIỎ HÀNG
    let grandTotal = 0;
    const successMessages: string[] = [];
    const transactionItems: TransactionItemPayload[] = cart.items.map(
      (cartItem) => {
        const itemTotal = cartItem.quantity * cartItem.unitPrice;

        grandTotal += itemTotal;
        successMessages.push(`${cartItem.quantity} ${cartItem.displayName}`);

        return {
          productPackageId: cartItem.productPackageId,
          quantity: cartItem.quantity,
          unitPrice: cartItem.unitPrice,
        };
      },
    );

    const payload: TransactionPayload = {
      note: `${isExport ? 'Xuất' : 'Nhập'} kho nhiều sản phẩm qua AI Assistant`,
      items: transactionItems,
    };

    const draftId = uuidv4();
    const draftAction: DraftAction = {
      id: draftId,
      type: intent,
      storeId,
      userId,
      payload,
      createdAt: Date.now(),
    };

    await this.redisClient.set(
      buildChatDraftKey(draftId),
      JSON.stringify(draftAction),
      'EX',
      DRAFT_TTL_SECONDS,
    );

    const systemContext = `Đã cập nhật giỏ hàng ${actionText}. Hiện có: ${successMessages.join(', ')}. Tổng tiền: ${grandTotal.toLocaleString('vi-VN')} VNĐ. Hỏi xem người dùng muốn thêm gì nữa không hay chốt đơn.`;

    return {
      aiIntent: isExport ? 'confirm_export' : 'confirm_import',
      botReply: await this.generateFriendlyReply(userMessage, systemContext),
      data: { draftActionId: draftId },
    };
  }

  private async searchInventory(
    storeId: string,
    keyword: string,
  ): Promise<InventoryItemData[]> {
    const query = {
      keyword: keyword.trim(),
      limit: 5,
      page: 1,
    } as unknown as ListInventoriesQueryDto;

    // 1. search với keyword gốc
    let res = await this.inventoryService.getInventoriesByStoreId(
      storeId,
      query,
    );

    // 2. fallback bỏ ngoặc hoặc prefix
    if (res.items.length === 0) {
      const splitArr = keyword.split('(');

      // TODO: Nên tối ưu ở đây
      const fallbackName = keyword.includes('(')
        ? (splitArr[0] ?? '').trim()
        : keyword
            .replace(/^(lon|thùng|chai|hộp|gói|bao|lốc|két)\s+/i, '')
            .trim();

      if (fallbackName && fallbackName !== keyword) {
        query.keyword = fallbackName;

        res = await this.inventoryService.getInventoriesByStoreId(
          storeId,
          query,
        );
      }
    }

    // 3. fallback normalize mạnh hơn (chỉ chạy nếu vẫn chưa có kết quả)
    if (res.items.length === 0) {
      const normalizedKeyword = keyword
        .toLowerCase()
        .replace(/[\s()-]/g, '')
        .trim();

      if (normalizedKeyword && normalizedKeyword !== keyword) {
        query.keyword = normalizedKeyword;

        res = await this.inventoryService.getInventoriesByStoreId(
          storeId,
          query,
        );
      }
    }

    return res.items as InventoryItemData[];
  }
}
