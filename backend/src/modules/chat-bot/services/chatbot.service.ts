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
  STATIC_REJECTION_REPLY,
} from '../chatbot.constants.js';
import {
  buildChatDraftKey,
  buildChatLockKey,
  buildCoordinatorMessages,
  buildUserDraftRefKey,
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
  CartItem,
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
            content: `Sentence: "${userMessage}"\nData: ${systemContext}`,
          },
        ],
      });

      return response.choices[0]?.message?.content ?? systemContext;
    } catch (error) {
      console.error('[AI Responder Error]', error);

      return systemContext;
    }
  }

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
          'Tori is still processing your previous message ⏳ Please wait a moment!',
        status: StatusCodes.TOO_MANY_REQUESTS,
      });
    }
    try {
      const draftRefKey = buildUserDraftRefKey(storeId, userId);
      const pendingDraftId = await this.redisClient.get(draftRefKey);

      if (pendingDraftId) {
        // Kiểm tra xem draft gốc có còn sống không (chưa hết hạn TTL)
        const draftExists = await this.redisClient.exists(
          buildChatDraftKey(pendingDraftId),
        );

        if (draftExists) {
          return {
            aiIntent: 'pending_confirmation',
            botReply:
              'Bạn đang có một phiếu nháp chưa được xác nhận. Vui lòng xác nhận hoặc hủy phiếu trước khi chúng ta tiếp tục nhé! 📦⚠️',
          };
        }
        // Xóa ref key rác nếu draft đã hết hạn
        await this.redisClient.del(draftRefKey);
      }

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

        messages.splice(1, 0, {
          role: 'system',
          content: `[TEMPORARY CART STATUS]: The user has an incomplete inventory session at ${actionName}. Items added: ${cartDetails}. Please prioritize processing this session.`,
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
            botReply: 'System tool access error.',
          };

          messagesToSave.push({
            role: 'tool',
            tool_call_id: toolCall?.id || 'unknown',
            content: 'System error: Unable to process the tool.',
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
                this.buildReplyContext(
                  payload.message,
                  validationResult.reason ||
                    'The information is insufficient; the user is requested to provide clarification.',
                ),
                '', // systemContext nay đã gộp vào context
              ),
            };

            messagesToSave.push({
              role: 'tool',
              tool_call_id: toolCall.id,
              content: `Blocked by Guardrail: ${validationResult.reason}`,
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
                    this.buildReplyContext(
                      payload.message,
                      'No, this feature is not currently available on the system.',
                    ),
                    '', // systemContext nay đã gộp vào context
                  ),
                };
            }

            const toolContent = finalResponse.data
              ? JSON.stringify(finalResponse.data)
              : finalResponse.aiIntent.includes('confirm')
                ? 'Draft created, awaiting confirmation.'
                : 'No data';

            messagesToSave.push({
              role: 'tool',
              tool_call_id: toolCall.id,
              content: toolContent,
            });
          }
        }
      } else {
        finalResponse = {
          aiIntent: 'out_of_domain_or_casual',
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              payload.message,
              `SYSTEM MODERATION: 
               - If the user's message is a greeting or general system question -> Reply friendly as Tori.
               - If the message is OUT OF DOMAIN (e.g. coding, math, weather, history, gossip...) -> REFUSE to answer. Strictly reply with exactly this message: "${STATIC_REJECTION_REPLY}"`,
            ),
            '',
          ),
        };
      }

      messagesToSave.push({
        role: 'assistant',
        content: finalResponse.botReply,
      });

      const isShouldSave = !['out_of_domain'].includes(finalResponse.aiIntent);

      if (isShouldSave) {
        await this.chatMemoryService.saveChatHistory(
          storeId,
          userId,
          messagesToSave,
        );
      }

      return finalResponse;
    } catch (error) {
      console.error('[Chatbot Error]', error);
      throw new CustomError({
        message: 'Lỗi kết nối với hệ thống mô hình AI',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    } finally {
      try {
        await this.redisClient.del(lockKey);
      } catch (e) {
        console.error('[Lock release failed]', e);
      }
    }
  }

  private isToolCallEligible(
    intent: string,
    params: LLMToolParams,
    userMessage: string,
  ): { isValid: boolean; reason?: string } {
    const normalizedMessage = userMessage.toLowerCase();

    const metaKeywords = ['how to', 'guide', 'can you', 'support', 'help'];
    const isAskingForHelp = metaKeywords.some((kw) =>
      normalizedMessage.includes(kw),
    );

    if (isAskingForHelp) {
      return {
        isValid: false,
        reason:
          'Users are simply asking how to use the system or about its functionality, not requesting execution. Explain the functionality to them; ABSOLUTELY DO NOT fabricate data.',
      };
    }

    // 2. Validate từng intent cụ thể
    switch (intent) {
      case 'get_product_info':
        if (!params.product_name || params.product_name.trim() === '') {
          return {
            isValid: false,
            reason:
              'What product are you looking for? Please let Tori know the name of the product.',
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
            reason: `What product and quantity do you want to import using ${intent === 'create_import' ? 'import' : 'export'}? Please provide enough information so Tori can create the order.`,
          };
        }

        // Kiểm tra xem số lượng có hợp lý không (tránh AI bịa số âm hoặc số 0)
        if (hasSingleItem && Number(params.quantity) <= 0) {
          return {
            isValid: false,
            reason: 'The number must be greater than 0.',
          };
        }
        break;
      }

      case 'get_low_stock':
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

    const refKey = buildUserDraftRefKey(draft.storeId, draft.userId);

    if (!isConfirmed) {
      await this.redisClient.del(draftKey); // Xóa khỏi Redis
      await this.redisClient.del(refKey);

      await this.chatMemoryService.clearChatHistory(
        draft.storeId,
        draft.userId,
      );

      return await this.generateFriendlyReply(
        this.buildReplyContext(
          'I want to cancel the transaction.',
          'The operation has been cancelled.',
        ),
        '',
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
    await this.redisClient.del(refKey);

    await this.chatMemoryService.clearChatHistory(draft.storeId, draft.userId);
    await this.chatMemoryService.clearCartSession(draft.storeId, draft.userId);

    return await this.generateFriendlyReply(
      this.buildReplyContext(
        'Confirmation successful',
        'Great! The transaction has been recorded in the system.',
      ),
      '',
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
        ? `There are a total of ${totalCount} products that have reached the warning level. List of the 5 most depleted products: ${displayItems.map((i) => i.productPackage.displayName).join(', ')}`
        : 'Great, no products are currently at the warning level!';

    return {
      aiIntent: 'get_low_stock',
      botReply: await this.generateFriendlyReply(
        this.buildReplyContext(userMessage, systemContext),
        '',
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
          this.buildReplyContext(
            userMessage,
            'Please ask the user to provide the name of the product they are looking for.',
          ),
          '',
        ),
      };
    }

    const searchResult = await this.searchInventory(storeId, productName);

    if (searchResult.length === 0) {
      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(
            userMessage,
            `${productName} was not found in the inventory.`,
          ),
          '',
        ),
      };
    }

    const exactMatch = findExactInventoryMatch(searchResult, productName);
    const firstResult = searchResult[0];

    if (exactMatch) {
      const context = `Product ${exactMatch.productPackage.displayName} has a selling price of ${exactMatch.productPackage.sellingPrice} VND. 
Inventory: ${exactMatch.quantity} ${exactMatch.productPackage.unit.name}.`;

      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(userMessage, context),
          '',
        ),
        data: exactMatch,
      };
    }

    if (searchResult.length === 1 && firstResult) {
      const context = `Product ${firstResult.productPackage.displayName} has a selling price of ${firstResult.productPackage.sellingPrice} VND. 
Inventory: ${firstResult.quantity} ${firstResult.productPackage.unit.name}.`;

      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(userMessage, context),
          '',
        ),
        data: firstResult,
      };
    }

    return {
      aiIntent: 'choose_product',
      botReply: await this.generateFriendlyReply(
        this.buildReplyContext(
          userMessage,
          `The system found multiple results for "${productName}". PLEASE SAY IN SHORT: "Tori found several similar products. Please select the exact one from the list below 👇". DO NOT list products yourself.`,
        ),
        '',
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
          this.buildReplyContext(
            userMessage,
            'The user is asked to specify the product name and the quantity they wish to process.',
          ),
          '',
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

    // Tạo bản sao sâu (deep clone) để tính toán an toàn
    const tempCartItems: CartItem[] = cart.items.map((item) => ({ ...item }));

    for (const item of itemsToProcess) {
      if (!item.product_name || !item.quantity) {
        continue;
      }

      const searchResult = await this.searchInventory(
        storeId,
        item.product_name,
      );

      // NẾU LỖI: Cần lưu lại những món ĐÃ THÀNH CÔNG trước đó vào Redis trước khi thoát
      const saveProgressAndReturn = async (
        returnPayload: ChatbotResponseDto,
      ) => {
        cart!.items = tempCartItems; // Gán phần đã xử lý được
        await this.chatMemoryService.saveCartSession(storeId, userId, cart!);

        return returnPayload;
      };

      if (searchResult.length === 0) {
        return saveProgressAndReturn({
          aiIntent: intent,
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              userMessage,
              `Error: "${item.product_name}" was not found. Previous items (if any) have been saved to the cart.`,
            ),
            '',
          ),
        });
      }

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
        // Có nhiều kết quả -> Yêu cầu user chọn -> Vẫn phải lưu tiến độ các món trước đó
        return saveProgressAndReturn({
          aiIntent: 'choose_product',
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              userMessage,
              `Many items similar to "${item.product_name}" were found. PLEASE SAY THIS IN SHORT: "There are several products with the same name, please click to select the correct type you want to ${isExport ? 'export' : 'import'} below 👇". ABSOLUTELY DO NOT list items yourself.`,
            ),
            '',
          ),
          data: {
            originalIntent: intent,
            quantity: item.quantity,
            items: searchResult,
          },
        });
      }

      const pkg = targetItem.productPackage;
      const price = isExport
        ? Number(pkg.sellingPrice)
        : Number(pkg.importPrice);

      // 2. LOGIC CỘNG DỒN GIỎ HÀNG (Vào biến tạm)
      const existingItem = tempCartItems.find(
        (i) => i.productPackageId === pkg.productPackageId,
      );
      const newQuantity = existingItem
        ? existingItem.quantity + Number(item.quantity)
        : Number(item.quantity);

      // Validate tồn kho
      if (isExport && targetItem.quantity < newQuantity) {
        return saveProgressAndReturn({
          aiIntent: intent,
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              userMessage,
              `Error: Insufficient stock. The inventory has ${targetItem.quantity}, but you want to export a total of ${newQuantity}.`,
            ),
            '',
          ),
        });
      }

      // Cập nhật mảng items tạm
      if (existingItem) {
        existingItem.quantity = newQuantity;
      } else {
        tempCartItems.push({
          productPackageId: pkg.productPackageId,
          displayName: pkg.displayName,
          quantity: Number(item.quantity),
          unitPrice: price,
        });
      }
    }

    // 3. LƯU GIỎ HÀNG VÀO REDIS (Nếu vòng lặp trót lọt hoàn toàn)
    cart.items = tempCartItems;
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
      note: `${isExport ? 'Xuất' : 'Nhập'} kho qua AI Assistant`,
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

    await this.redisClient.set(
      buildUserDraftRefKey(storeId, userId),
      draftId,
      'EX',
      DRAFT_TTL_SECONDS,
    );

    const systemContext = `The cart has been updated for ${actionText}. Current items: ${successMessages.join(', ')}. Total: ${grandTotal.toLocaleString('en-US')} VND. Ask if they want to add more or confirm the order.`;

    return {
      aiIntent: isExport ? 'confirm_export' : 'confirm_import',
      botReply: await this.generateFriendlyReply(
        this.buildReplyContext(userMessage, systemContext),
        '',
      ),
      data: { draftActionId: draftId },
    };
  }

  private async searchInventory(
    storeId: string,
    keyword: string,
  ): Promise<InventoryItemData[]> {
    const cleanKeyword = keyword
      .replace(
        /\b(lốc|thùng|chai|lon|gói|hộp|pack|case|bottle|can|bag|box)\b/gi,
        '',
      )
      .trim();

    const query = {
      keyword: cleanKeyword || keyword.trim(),
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
            .replace(/^(can|carton|bottle|box|package|bag|crate|crate)\s+/i, '')
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

  private buildReplyContext(userMessage: string, systemData: string): string {
    return `[USER MESSAGE]: ${userMessage}\n[SYSTEM DATA]: ${systemData}\n[INSTRUCTION]: Reply to the user in the language they used above.`;
  }
}
