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

    // set lockey khóa tạm thời để tránh spam request
    // nếu key chưa tồn tại -> set thành công -> request được xử lý
    // nếu key đã tồn tại -> set fail -> request bị reject (429)
    const acquired = await this.redisClient.set(
      lockKey,
      'locked',
      'EX', // lock tự hết hạn nếu có lỗi bất ngờ
      LOCK_TTL_SECONDS,
      'NX', // chỉ set khi key chưa tồn tại
    );

    if (!acquired) {
      throw new CustomError({
        message:
          'Tori đang suy nghĩ câu hỏi trước của bạn, vui lòng đợi vài giây nhé! ⏳',
        status: StatusCodes.TOO_MANY_REQUESTS,
      });
    }

    try {
      // lấy lịch sử hội thoại ngắn hạn từ Redis để giữ ngữ cảnh cho model
      const previousHistory = await this.chatMemoryService.getChatHistory(
        storeId,
        userId,
      );

      // ghép system prompt + history + message hiện tại thành input cho model điều phối
      const messages = buildCoordinatorMessages(
        storeId,
        userId,
        previousHistory,
        payload.message,
      );

      // gọi model coordinator để xác định intent và quyết định có cần gọi tool hay không
      const response = await this.llmProvider.createChatCompletion({
        model: COORDINATOR_MODEL,
        messages,
        tools: CHAT_TOOLS,
        tool_choice: 'auto',
        temperature: COORDINATOR_TEMPERATURE,
      });

      const responseMessage = response.choices[0]?.message; // chỉ lấy và xử lý response tốt nhất
      const toolCalls = responseMessage?.tool_calls; // tool model quyết định gọi

      let finalResponse: ChatbotResponseDto;

      if (toolCalls && toolCalls.length > 0) {
        // hiện tại chỉ xử lý tool call đầu tiên do model trả về.
        const toolCall = toolCalls[0];

        if (!toolCall || toolCall.type !== 'function') {
          finalResponse = {
            aiIntent: 'unknown',
            botReply: 'Lỗi truy xuất công cụ hệ thống.',
          };
        } else {
          const intent = toolCall.function.name;
          let params: LLMToolParams = {};

          // parse arguments từ tool call để lấy các tham số đã được model trích xuất
          if (toolCall.function.arguments) {
            params = JSON.parse(toolCall.function.arguments) as LLMToolParams;
          }

          // điều hướng sang handler tương ứng với intent mà model đã chọn
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
        }
      } else {
        // nếu model không chọn tool nào, ưu tiên dùng câu trả lời trực tiếp của model
        finalResponse = {
          aiIntent: 'unknown',
          botReply:
            responseMessage?.content ||
            'Em chưa hiểu ý anh/chị, mình có thể nói rõ hơn được không ạ?',
        };
      }

      // lưu lại cặp hỏi - đáp để dùng làm ngữ cảnh cho các lượt chat tiếp theo
      await this.chatMemoryService.saveChatHistory(
        storeId,
        userId,
        payload.message,
        finalResponse.botReply,
      );

      return finalResponse;
    } catch (error) {
      console.error('[Chatbot Error]', error);
      throw new CustomError({
        message: 'Lỗi kết nối với hệ thống mô hình AI',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    } finally {
      // luôn giải phóng lock kể cả khi xử lý thành công hay phát sinh lỗi
      await this.redisClient.del(lockKey);
    }
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
      botReply: await this.generateFriendlyReply(
        userMessage,
        systemContext,
      ),
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
        `Hệ thống tìm thấy nhiều kết quả cho "${productName}". Yêu cầu người dùng chọn chính xác trong danh sách.`,
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

    const transactionItems: TransactionItemPayload[] = [];
    let grandTotal = 0;
    const successMessages: string[] = [];

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
            `Lỗi: Không tìm thấy "${item.product_name}" trong kho. Thao tác đã bị hủy.`,
          ),
        };
      }

      let targetItem: InventoryItemData;
      const exactMatch = findExactInventoryMatch(
        searchResult,
        item.product_name,
      );
      const firstResult = searchResult[0];

      if (exactMatch) {
        targetItem = exactMatch;
      } else if (searchResult.length === 1 && firstResult) {
        targetItem = firstResult;
      } else {
        return {
          aiIntent: 'choose_product',
          botReply: await this.generateFriendlyReply(
            userMessage,
            `Cảnh báo: Tìm thấy nhiều mặt hàng giống "${item.product_name}". Yêu cầu người dùng chọn chính xác để tiếp tục.`,
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

      if (price <= 0) {
        return {
          aiIntent: intent,
          botReply: await this.generateFriendlyReply(
            userMessage,
            `Lỗi: Sản phẩm "${pkg.displayName}" chưa được cài đặt giá ${isExport ? 'bán' : 'nhập'}. Thao tác bị hủy.`,
          ),
        };
      }

      if (isExport && targetItem.quantity < item.quantity) {
        return {
          aiIntent: intent,
          botReply: await this.generateFriendlyReply(
            userMessage,
            `Lỗi: "${pkg.displayName}" chỉ còn ${targetItem.quantity} ${pkg.unit.name}, không đủ để xuất ${item.quantity}. Thao tác bị hủy.`,
          ),
        };
      }

      transactionItems.push({
        productPackageId: pkg.productPackageId,
        quantity: Number(item.quantity),
        unitPrice: price,
      });

      const itemTotal = item.quantity * price;

      grandTotal += itemTotal;
      successMessages.push(
        `${item.quantity} ${pkg.displayName} (${itemTotal.toLocaleString('vi-VN')}đ)`,
      );
    }

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

    const systemContext = `Hệ thống chuẩn bị tạo phiếu ${actionText} cho các sản phẩm: ${successMessages.join('; ')}. Tổng tiền: ${grandTotal.toLocaleString('vi-VN')} VNĐ. Yêu cầu người dùng xác nhận.`;

    return {
      aiIntent: isExport ? 'confirm_export' : 'confirm_import',
      botReply: await this.generateFriendlyReply(
        userMessage,
        systemContext,
      ),
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
