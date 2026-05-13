import { StatusCodes } from 'http-status-codes';
import { v4 as uuidv4 } from 'uuid';

import { CustomError } from '../../../common/errors/index.js';
import { ROLE } from '../../access-control/role-permission.constant.js';
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
import type { ListAuditLogsQueryDto } from '../../audit-log/dto/audit-log.dto.js';
import type { AuditLogService } from '../../audit-log/service/audit-log.service.js';
import type { ListInventoriesQueryDto } from '../../inventories/dto/inventory.dto.js';
import type { InventoryService } from '../../inventories/index.js';
import type { StoreMemberRepository } from '../../store-member/repository/store-member.repository.js';
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
    private readonly auditLogService: AuditLogService,
    private readonly storeMemberRepository: StoreMemberRepository,
  ) {}

  private async generateFriendlyReply(context: string): Promise<string> {
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
            content: context,
          },
        ],
      });

      return response.choices[0]?.message?.content ?? context;
    } catch (error) {
      console.error('[AI Responder Error]', error);

      return context;
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

          // -------------------------------------------------------------
          // LOGIC KIỂM TRA PENDING DRAFT (ĐÃ NÂNG CẤP)
          // -------------------------------------------------------------
          if (intent === 'create_import' || intent === 'create_export') {
            const draftRefKey = buildUserDraftRefKey(storeId, userId);
            const pendingDraftId = await this.redisClient.get(draftRefKey);

            if (pendingDraftId) {
              const draftKey = buildChatDraftKey(pendingDraftId);
              const draftData = await this.redisClient.get(draftKey);

              if (draftData) {
                const draft = JSON.parse(draftData) as DraftAction;

                if (intent !== draft.type) {
                  const systemInstruction = `CẢNH BÁO HỆ THỐNG: Người dùng đang có một phiếu ${draft.type === 'create_import' ? 'NHẬP' : 'XUẤT'} kho đang chờ xử lý. Yêu cầu người dùng Xác nhận hoặc Hủy phiếu cũ ở thẻ bên dưới trước khi tạo mới.`;

                  const botReply = await this.generateFriendlyReply(
                    this.buildReplyContext(payload.message, systemInstruction),
                  );

                  await this.chatMemoryService.saveChatHistory(
                    storeId,
                    userId,
                    [
                      { role: 'user', content: payload.message },
                      { role: 'assistant', content: botReply },
                    ],
                  );

                  return {
                    aiIntent:
                      draft.type === 'create_import'
                        ? 'confirm_import'
                        : 'confirm_export',
                    botReply: botReply,
                    data: { draftActionId: pendingDraftId },
                  };
                }
              } else {
                await this.redisClient.del(draftRefKey);
              }
            }
          }
          // -------------------------------------------------------------

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

              case 'query_audit_logs': {
                // 1. Lấy thông tin thành viên thực tế từ Database
                const member =
                  await this.storeMemberRepository.findByIdsWithStore(
                    userId,
                    storeId,
                  );

                const userRole = member?.role?.toUpperCase() || ROLE.STAFF;

                if (userRole === ROLE.STAFF) {
                  finalResponse = {
                    aiIntent: 'unauthorized',
                    botReply: await this.generateFriendlyReply(
                      this.buildReplyContext(
                        payload.message,
                        "System: The user is trying to view the Audit Logs, but their role is 'Staff'. They DO NOT have permission. Task: Politely refuse and state that only Managers or Owners can view the system history.",
                      ),
                    ),
                  };
                } else {
                  finalResponse = await this.handleQueryAuditLogs(
                    storeId,
                    params,
                    payload.message,
                  );
                }
                break;
              }

              default:
                finalResponse = {
                  aiIntent: 'unknown',
                  botReply: await this.generateFriendlyReply(
                    this.buildReplyContext(
                      payload.message,
                      'No, this feature is not currently available on the system.',
                    ),
                  ),
                };
            }

            const toolContent = finalResponse.aiIntent.includes('confirm')
              ? 'Draft created, awaiting user confirmation.'
              : finalResponse.aiIntent === 'get_product_info'
                ? `Found product: ${(finalResponse.data as InventoryItemData)?.productPackage?.displayName}`
                : 'Tool executed successfully.';

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
               - If the user's message is a greeting or asks for help/guide/features -> Reply friendly as Tori and EXPLICITLY LIST your capabilities: 1) Create Import/Export, 2) Check product info & low stock, 3) View Audit Logs.
               - If the message is OUT OF DOMAIN (e.g. coding, math, weather, history, gossip...) -> REFUSE to answer. Strictly reply with exactly this message: "${STATIC_REJECTION_REPLY}"`,
            ),
          ),
        };
      }

      messagesToSave.push({
        role: 'assistant',
        content: finalResponse.botReply,
      });

      const isShouldSave = finalResponse.aiIntent !== 'out_of_domain_or_casual';

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
        message: 'Connection to the AI model system failed.',
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
    const hasActionKeyword = [
      'import',
      'export',
      'xuất',
      'nhập',
      'tồn kho',
    ].some((kw) => normalizedMessage.includes(kw));

    if (isAskingForHelp && !hasActionKeyword) {
      return {
        isValid: false,
        reason:
          '[SYSTEM INSTRUCTION]: Inform the user that their history query is too general. Ask them to specify the action type, product name, or a specific time period.',
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

        // 1. Nếu không có item nào
        if (items.length === 0 && !(params.product_name && params.quantity)) {
          return {
            isValid: false,
            reason: `What product and quantity do you want to import using ${intent === 'create_import' ? 'import' : 'export'}? Please provide enough information so Tori can create the order.`,
          };
        }

        // 2. GUARDRAIL THÉP: Kiểm tra xem người dùng CÓ THỰC SỰ GÕ SỐ lượng vào tin nhắn không!
        // Quét các chữ số (0-9) hoặc các chữ cái chỉ số lượng cơ bản tiếng Anh/Việt
        const hasNumberInMessage =
          /\d/.test(normalizedMessage) ||
          // eslint-disable-next-line max-len
          /một|hai|ba|bốn|năm|sáu|bảy|tám|chín|mười|chục|trăm|ngàn|one|two|three|four|five|ten/i.test(
            normalizedMessage,
          );

        if (!hasNumberInMessage) {
          return {
            isValid: false,
            reason: `The user specified the product but did NOT provide the exact quantity in their message. You MUST NOT assume the quantity. Ask the user clearly: "How many [Product Name] do you want to ${intent === 'create_import' ? 'import' : 'export'}?"`,
          };
        }

        const hasMissingQuantity = items.some(
          (item) =>
            item.quantity === undefined ||
            item.quantity === null ||
            Number.isNaN(Number(item.quantity)),
        );

        if (hasMissingQuantity) {
          return {
            isValid: false,
            reason: `Ask the user clearly: "How many [Product Name] do you want to ${intent === 'create_import' ? 'import' : 'export'}?"`,
          };
        }

        // 4. Kiểm tra số lượng âm/bằng 0
        const hasInvalidQuantity = items.some(
          (item) => Number(item.quantity) <= 0,
        );

        if (hasInvalidQuantity) {
          return {
            isValid: false,
            reason:
              '[SYSTEM INSTRUCTION]: Inform the user that the quantity must be greater than 0.',
          };
        }
        break;
      }

      case 'get_low_stock':
        break;

      case 'query_audit_logs':
        if (
          !params.keyword &&
          !params.time_period &&
          params.action_type?.toLowerCase() === 'all'
        ) {
          return {
            isValid: false,
            reason:
              'Người dùng đang hỏi lịch sử chung chung quá. Hãy yêu cầu họ chỉ định rõ loại thao tác (xóa, thêm), tên sản phẩm, hoặc thời gian cụ thể.',
          };
        }
        break;

      default:
        break;
    }

    return { isValid: true };
  }

  public async confirmDraftAction(
    draftActionId: string,
    isConfirmed: boolean,
    requestingStoreId: string,
    requestingUserId: string,
  ): Promise<string> {
    const draftKey = buildChatDraftKey(draftActionId);
    const draftData = await this.redisClient.get(draftKey);

    if (!draftData) {
      throw new CustomError({
        message: 'The request has expired or does not exist (over 5 minutes).',
        status: StatusCodes.GONE,
      });
    }

    const draft = JSON.parse(draftData) as DraftAction;

    if (
      draft.storeId !== requestingStoreId ||
      draft.userId !== requestingUserId
    ) {
      throw new CustomError({
        message: 'Forbidden',
        status: StatusCodes.FORBIDDEN,
      });
    }

    const refKey = buildUserDraftRefKey(draft.storeId, draft.userId);

    const history = await this.chatMemoryService.getChatHistory(
      draft.storeId,
      draft.userId,
    );
    const lastMessage = history.reverse().find((m) => m.role === 'user');

    const lastUserMessage =
      typeof lastMessage?.content === 'string'
        ? lastMessage.content
        : 'Confirm';

    try {
      if (!isConfirmed) {
        await this.chatMemoryService.clearChatHistory(
          draft.storeId,
          draft.userId,
        );
        await this.chatMemoryService.clearCartSession(
          draft.storeId,
          draft.userId,
        );

        return await this.generateFriendlyReply(
          this.buildReplyContext(
            lastUserMessage,
            '[SYSTEM]: The transaction operation has been cancelled by the user. Inform them friendly.',
          ),
        );
      }

      // Xử lý tạo giao dịch
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

      await this.chatMemoryService.clearChatHistory(
        draft.storeId,
        draft.userId,
      );
      await this.chatMemoryService.clearCartSession(
        draft.storeId,
        draft.userId,
      );

      return await this.generateFriendlyReply(
        this.buildReplyContext(
          lastUserMessage,
          '[SYSTEM]: The transaction has been recorded successfully. Congratulate the user.',
        ),
      );
    } finally {
      await this.redisClient.del(draftKey);
      await this.redisClient.del(refKey);
    }
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

    const allLowStockItems = (res.items as InventoryItemData[]).filter(
      (item) =>
        item.quantity <= (item.reorder_threshold ?? item.reorderThreshold ?? 0),
    );

    const totalCount = allLowStockItems.length;
    const displayItems = allLowStockItems.slice(0, 5);

    const productListStr = displayItems
      .map((i) => `\n- ${i.productPackage.displayName}: ${i.quantity} in stock`)
      .join('');

    let systemContext =
      totalCount > 0
        ? `There are a total of ${totalCount} products that have reached the warning level. List of the 5 most depleted products: ${productListStr}\nDO NOT invent or add any other numbers.`
        : 'Great, no products are currently at the warning level!';

    if (res.items.length >= 100) {
      systemContext +=
        ' Note: The system only shows data for the first 100 products scanned. Please visit the Low Stock screen for a complete list.';
    }

    return {
      aiIntent: 'get_low_stock',
      botReply: await this.generateFriendlyReply(
        this.buildReplyContext(userMessage, systemContext),
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
            `Task: Inform the user that you found multiple products matching "${productName}". Ask them to select the exact one from the interface below 👇. (Strict rule: Output only 1-2 sentences. No bullet points, no product examples).`,
          ),
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
        ),
      };
    }

    const exactMatch = findExactInventoryMatch(searchResult, productName);
    const firstResult = searchResult[0];

    if (exactMatch) {
      const context = `Product ${exactMatch.productPackage.displayName} has a selling price of ${exactMatch.productPackage.sellingPrice}. 
Inventory: ${exactMatch.quantity} ${exactMatch.productPackage.unit.name}.`;

      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(userMessage, context),
        ),
        data: exactMatch,
      };
    }

    if (searchResult.length === 1 && firstResult) {
      const context = `Product ${firstResult.productPackage.displayName} has a selling price of ${firstResult.productPackage.sellingPrice}. 
Inventory: ${firstResult.quantity} ${firstResult.productPackage.unit.name}.`;

      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(userMessage, context),
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
        ),
      };
    }

    const isExport = intent === 'create_export';

    // 1. LẤY GIỎ HÀNG HIỆN TẠI (hoặc tạo mới)
    let cart = await this.chatMemoryService.getCartSession(storeId, userId);

    if (!cart || cart.type !== intent) {
      cart = { type: intent, items: [] };
    }

    // Tạo bản sao sâu (deep clone) để tính toán an toàn
    const tempCartItems: CartItem[] = cart.items.map((item) => ({ ...item }));
    const newlyAddedItems: string[] = [];

    // BƯỚC QUAN TRỌNG: TỐI ƯU HÓA TRUY VẤN N+1
    // Tìm kiếm tất cả sản phẩm dưới DB song song cùng một lúc
    const searchPromises = itemsToProcess.map(async (item) => {
      if (!item.product_name || !item.quantity) {
        return null;
      }
      const searchResult = await this.searchInventory(
        storeId,
        item.product_name,
      );

      return { item, searchResult };
    });

    // Chờ tất cả kết quả trả về, loại bỏ các giá trị null
    const resolvedSearchResults = (await Promise.all(searchPromises)).filter(
      (res) => res !== null,
    ) as {
      item: { product_name: string; quantity: number | string };
      searchResult: InventoryItemData[];
    }[];

    // Hàm tiện ích: Lưu lại giỏ hàng nếu gặp lỗi giữa chừng
    const saveProgressAndReturn = async (returnPayload: ChatbotResponseDto) => {
      cart!.items = tempCartItems; // Gán phần đã xử lý được
      await this.chatMemoryService.saveCartSession(storeId, userId, cart!);

      return returnPayload;
    };

    // 2. DUYỆT QUA KẾT QUẢ TÌM KIẾM ĐỂ XỬ LÝ LOGIC GIỎ HÀNG
    for (const { item, searchResult } of resolvedSearchResults) {
      if (searchResult.length === 0) {
        return saveProgressAndReturn({
          aiIntent: intent,
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              userMessage,
              `Error: "${item.product_name}" was not found. Previous items (if any) have been saved to the cart.`,
            ),
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
        return saveProgressAndReturn({
          aiIntent: 'choose_product',
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              userMessage,
              `Task: Inform the user that you found multiple products matching "${item.product_name}". Ask them to select the exact one they want to ${isExport ? 'export' : 'import'} from the interface below 👇. (Strict rule: Output only 1-2 sentences. No bullet points, no product examples).`,
            ),
          ),
          data: {
            originalIntent: intent,
            quantity: item.quantity,
            items: searchResult,
            pendingProductName: item.product_name,
          },
        });
      }

      const pkg = targetItem.productPackage;
      const price = isExport
        ? Number(pkg.sellingPrice)
        : Number(pkg.importPrice);

      // LOGIC CỘNG DỒN GIỎ HÀNG (Vào biến tạm)
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

      newlyAddedItems.push(`${Number(item.quantity)} ${pkg.displayName}`);
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

    const formattedTotal = grandTotal.toLocaleString('en-US');
    const systemContext = `Successfully added to cart: ${newlyAddedItems.join(', ')}. Current entire cart items: ${successMessages.join(', ')}. Grand Total: ${formattedTotal}. Ask if they want to add more or confirm.`;

    return {
      aiIntent: isExport ? 'confirm_export' : 'confirm_import',
      botReply: await this.generateFriendlyReply(
        this.buildReplyContext(userMessage, systemContext),
      ),
      data: { draftActionId: draftId },
    };
  }

  private async searchInventory(
    storeId: string,
    keyword: string,
  ): Promise<InventoryItemData[]> {
    const aliasMap: Record<string, string> = {
      // Đồ uống
      'bò húc': 'redbull',
      'bò cụng': 'redbull',
      'sting dâu': 'sting đỏ',
      'cô ca': 'coca',
      pexi: 'pepsi',
      'nước lọc': 'aquafina',
      'trà xanh': 'không độ',
      'ô long': 'tea plus',

      // Đồ ăn / Snack
      'mì tôm': 'hảo hảo',
      'bim bim': 'oishi',
      'xúc xích': 'cp',
      'sữa đặc': 'ông thọ',

      // Hóa mỹ phẩm / Cá nhân
      bvs: 'băng vệ sinh',
      bcs: 'bao cao su',
      'áo mưa': 'bao cao su',
      kđr: 'kem đánh răng',
      'sữa tắm': 'lifebuoy',
      'dầu gội': 'clear',

      // Gia vị
      'bột ngọt': 'ajinomoto',
      'mì chính': 'ajinomoto',
      'nước mắm': 'nam ngư',
    };

    let cleanKeyword = keyword
      .toLowerCase()
      .replace(
        /\b(lốc|thùng|chai|lon|gói|hộp|pack|case|bottle|can|bag|box)\b/gi,
        '',
      )
      .trim();

    for (const [slang, realName] of Object.entries(aliasMap)) {
      if (cleanKeyword.includes(slang)) {
        cleanKeyword = cleanKeyword.replace(slang, realName);
      }
    }

    const query = {
      keyword: cleanKeyword || keyword.trim(),
      limit: 5,
      page: 1,
    } as unknown as ListInventoriesQueryDto;

    let res = await this.inventoryService.getInventoriesByStoreId(
      storeId,
      query,
    );

    if (res.items.length === 0) {
      const splitArr = keyword.split('(');

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

  private async handleQueryAuditLogs(
    storeId: string,
    params: LLMToolParams,
    userMessage: string,
  ): Promise<ChatbotResponseDto> {
    const {
      action_type: actionType,
      keyword,
      time_period: timePeriod,
    } = params;

    // 1. CHUẨN HÓA QUERY & XỬ LÝ THỜI GIAN (Giờ VN)
    const queryPayload: Record<string, unknown> = {
      limit: 15,
      page: 1,
      sortBy: 'performedAt',
      sortOrder: 'desc',
      search: keyword,
    };

    if (actionType && actionType.toLowerCase() !== 'all') {
      queryPayload.actionType = actionType.toLowerCase();
    }

    const timeRange = this.resolveTimePeriod(timePeriod);

    Object.assign(queryPayload, timeRange);

    // Gọi service với kiểu dữ liệu chuẩn
    const { items } = await this.auditLogService.getAuditLogs(
      storeId,
      queryPayload as unknown as ListAuditLogsQueryDto,
    );

    if (items.length === 0) {
      return {
        aiIntent: 'query_audit_logs',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(userMessage, 'No action history found.'),
        ),
      };
    }

    // 2. ĐỊNH NGHĨA INTERFACE CHI TIẾT (Thay thế Any)
    interface AuditLogJsonDetails {
      displayName?: string;
      productName?: string;
      name?: string;
      [key: string]: unknown;
    }

    interface AuditLogWithRelations {
      actionType: string;
      entityType: string;
      entityId: string;
      note: string | null;
      newValue: unknown;
      performedAt: string | Date;
      user?: { fullName: string | null } | null;
    }

    const typedItems = items as unknown as AuditLogWithRelations[];

    // 3. XỬ LÝ DỮ LIỆU TRẢ VỀ UI
    const responseData = typedItems.map((log) => {
      let details: AuditLogJsonDetails = {};

      if (typeof log.newValue === 'string') {
        try {
          details = JSON.parse(log.newValue);
        } catch (e) {
          console.error('[handleQueryAuditLogs', e);
        }
      } else if (log.newValue && typeof log.newValue === 'object') {
        details = log.newValue as AuditLogJsonDetails;
      }

      let displayTarget =
        details.displayName || details.productName || details.name || log.note;

      if (!displayTarget || /^[0-9a-fA-F-]{36}$/.test(displayTarget)) {
        const typeMap: Record<string, string> = {
          Product: 'Product',
          ProductPackage: 'Product Package',
          Inventory: 'Inventory',
          Category: 'Category',
          Transaction: 'Transaction', // Để tiếng Anh cho AI dễ hiểu
        };

        displayTarget = typeMap[log.entityType] || 'System Data';
      }

      // ĐẶC BIỆT: Nếu là giao dịch, cố gắng phân biệt Nhập hay Xuất dựa vào note
      if (log.entityType === 'Transaction') {
        const noteLower = (log.note || '').toLowerCase();

        if (noteLower.includes('xuất') || noteLower.includes('export')) {
          displayTarget = 'Export Transaction';
        } else if (noteLower.includes('nhập') || noteLower.includes('import')) {
          displayTarget = 'Import Transaction';
        }
      }

      return {
        action: log.actionType,
        target: displayTarget,
        userFullName: log.user?.fullName || 'User',
        time: new Date(log.performedAt).toLocaleString('vi-VN', {
          timeZone: 'Asia/Ho_Chi_Minh',
          hour: '2-digit',
          minute: '2-digit',
          day: '2-digit',
          month: '2-digit',
        }),
        entityType: log.entityType,
      };
    });

    const contextLines = responseData.map(
      (r) =>
        `- [${r.time}] User ${r.userFullName} performed "${r.action}" on "${r.target}"`,
    );

    // LẤY NGÀY GIỜ HIỆN TẠI BƠM VÀO PROMPT
    const today = new Date().toLocaleString('en-US', {
      timeZone: 'Asia/Ho_Chi_Minh',
    });

    const systemContext = `Current System Time: ${today}
Below is the audit log data:
${contextLines.join('\n')}

Task: Answer the user's query accurately using ONLY the logs provided above. Do not hallucinate dates or data.`;

    return {
      aiIntent: 'query_audit_logs',
      botReply: await this.generateFriendlyReply(
        this.buildReplyContext(userMessage, systemContext),
      ),
      data: responseData,
    };
  }
  private resolveTimePeriod(timePeriod: string | undefined): {
    startDate?: string;
    endDate?: string;
  } {
    if (!timePeriod) {
      return {};
    }

    // Chuẩn hóa về offset UTC+7
    const vnNow = new Date(Date.now() + 7 * 3600_000);

    const startOf = (d: Date) => {
      const t = new Date(d);

      t.setUTCHours(0, 0, 0, 0);

      return new Date(t.getTime() - 7 * 3600_000).toISOString(); // back to UTC
    };
    const endOf = (d: Date) => {
      const t = new Date(d);

      t.setUTCHours(23, 59, 59, 999);

      return new Date(t.getTime() - 7 * 3600_000).toISOString();
    };

    switch (timePeriod) {
      case 'today':
        return { startDate: startOf(vnNow) };

      case 'yesterday': {
        const yd = new Date(vnNow);

        yd.setUTCDate(vnNow.getUTCDate() - 1);

        return { startDate: startOf(yd), endDate: endOf(yd) };
      }

      case 'this_week': {
        const day = vnNow.getUTCDay(); // 0=Sun
        const monday = new Date(vnNow);

        monday.setUTCDate(vnNow.getUTCDate() - ((day + 6) % 7));

        return { startDate: startOf(monday) };
      }

      case 'last_week': {
        const day = vnNow.getUTCDay();
        const thisMonday = new Date(vnNow);

        thisMonday.setUTCDate(vnNow.getUTCDate() - ((day + 6) % 7));
        const lastMonday = new Date(thisMonday);

        lastMonday.setUTCDate(thisMonday.getUTCDate() - 7);
        const lastSunday = new Date(thisMonday);

        lastSunday.setUTCDate(thisMonday.getUTCDate() - 1);

        return { startDate: startOf(lastMonday), endDate: endOf(lastSunday) };
      }

      case 'this_month': {
        const firstDay = new Date(vnNow);

        firstDay.setUTCDate(1);

        return { startDate: startOf(firstDay) };
      }

      case 'last_month': {
        const firstOfThisMonth = new Date(vnNow);

        firstOfThisMonth.setUTCDate(1);
        const lastOfPrev = new Date(firstOfThisMonth);

        lastOfPrev.setUTCDate(0);
        const firstOfPrev = new Date(lastOfPrev);

        firstOfPrev.setUTCDate(1);

        return { startDate: startOf(firstOfPrev), endDate: endOf(lastOfPrev) };
      }

      default:
        return {};
    }
  }

  private buildReplyContext(userMessage: string, systemData: string): string {
    return `You are Tori, a helpful AI assistant for Storix.

SYSTEM FACTS / TASKS:
${systemData}

USER MESSAGE:
"${userMessage}"

STRICT INSTRUCTIONS:
- IF the USER MESSAGE is in English -> You MUST reply ONLY in English.
- IF the USER MESSAGE is in Vietnamese -> You MUST reply ONLY in Vietnamese.
- NEVER explain your language detection. NEVER output lines like "The language is..." or "Ngôn ngữ là...".
- Respond directly with the conversational text based ONLY on the SYSTEM FACTS.
- CRITICAL: DO NOT output any prefixes like "[REPLY]", "Reply:", or explain your thoughts. Output ONLY the final conversational response.`;
  }
}
