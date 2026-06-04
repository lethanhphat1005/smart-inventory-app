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
} from '../chatbot.constants.js';
import {
  buildChatDraftKey,
  buildChatLockKey,
  buildCoordinatorMessages,
  buildUserDraftRefKey,
  findExactInventoryMatch,
} from '../chatbot.mapper.js';
// Import các Helper tách lớp xử lý
import { getFriendlyReplyPrompt } from '../chatbot.prompt.js';
import { ChatbotGuardHelper } from './helpers/chatbot-guard.helper.js';
import { ProductSearchHelper } from './helpers/product-search.helper.js';
import { TimeResolverHelper } from './helpers/time-resolver.helper.js';
import { CHAT_TOOLS } from '../tools/tool-registry.js';

import type { ChatMemoryService } from './chat-memory.service.js';
import type { SmartDecisionService } from '../../alerts/services/smart-decision.service.js';
import type { ListAuditLogsQueryDto } from '../../audit-log/dto/audit-log.dto.js';
import type { AuditLogService } from '../../audit-log/service/audit-log.service.js';
import type { ListInventoriesQueryDto } from '../../inventories/dto/inventory.dto.js';
import type { InventoryService } from '../../inventories/index.js';
import type { StoreMemberRepository } from '../../store-member/repository/store-member.repository.js';
import type { TransactionService } from '../../transactions/transaction.service.js';
import type { ChatbotRequestDto, ChatbotResponseDto } from '../chatbot.dto.js';
import type {
  AuditLogDetails,
  AuditLogRecord,
  CartItem,
  ChatHistoryMessage,
  CrossSellItem,
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
    private readonly smartDecisionService: SmartDecisionService,
  ) {}

  private async generateFriendlyReply(
    context: string,
    locale: string,
  ): Promise<string> {
    try {
      const response = await this.llmProvider.createChatCompletion({
        model: FRIENDLY_REPLY_MODEL,
        temperature: FRIENDLY_REPLY_TEMPERATURE,
        messages: [
          {
            role: 'system',
            content: getFriendlyReplyPrompt(locale),
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
    locale: string,
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

        const toolCall = toolCalls[0]!;

        if (toolCall.type !== 'function') {
          finalResponse = {
            aiIntent: 'unknown',
            botReply: 'System tool access error.',
          };

          messagesToSave.push({
            role: 'tool',
            tool_call_id: toolCall.id || 'unknown',
            content: 'System error: Unable to process the tool.',
          });
        } else {
          const intent = toolCall.function.name;
          let params: LLMToolParams = {};

          // -------------------------------------------------------------
          // LOGIC KIỂM TRA PENDING DRAFT (LOCALIZATION ĐỘNG)
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
                  const systemInstruction =
                    locale === 'en'
                      ? `SYSTEM ALERT: The user has a pending ${draft.type === 'create_import' ? 'IMPORT' : 'EXPORT'} transaction draft. Request them to Confirm or Cancel the old draft before creating a new one.`
                      : `CẢNH BÁO HỆ THỐNG: Người dùng đang có một phiếu ${draft.type === 'create_import' ? 'NHẬP' : 'XUẤT'} kho đang chờ xử lý. Yêu cầu người dùng Xác nhận hoặc Hủy phiếu cũ ở thẻ bên dưới trước khi tạo mới.`;

                  const botReply = await this.generateFriendlyReply(
                    this.buildReplyContext(payload.message, systemInstruction),
                    locale,
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

          try {
            if (toolCall.function.arguments) {
              params = JSON.parse(toolCall.function.arguments) as LLMToolParams;
            }
          } catch (e) {
            console.error('Lỗi parse arguments từ tool:', e);
          }

          // Gọi Helper kiểm tra Guardrail độc lập
          const validationResult = ChatbotGuardHelper.isToolCallEligible(
            intent,
            params,
            payload.message,
            locale,
          );

          if (!validationResult.isValid) {
            finalResponse = {
              aiIntent: 'clarify',
              botReply: await this.generateFriendlyReply(
                this.buildReplyContext(
                  payload.message,
                  validationResult.reason || 'Information insufficient.',
                ),
                locale,
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
                  locale,
                );
                break;

              case 'get_product_info':
                finalResponse = await this.handleGetProductInfo(
                  storeId,
                  params.product_name,
                  payload.message,
                  locale,
                );
                break;

              case 'create_export':
                finalResponse = await this.handleTransactionDraft(
                  storeId,
                  userId,
                  'create_export',
                  params,
                  payload.message,
                  locale,
                );
                break;

              case 'create_import':
                finalResponse = await this.handleTransactionDraft(
                  storeId,
                  userId,
                  'create_import',
                  params,
                  payload.message,
                  locale,
                );
                break;

              case 'query_audit_logs': {
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
                      locale,
                    ),
                  };
                } else {
                  finalResponse = await this.handleQueryAuditLogs(
                    storeId,
                    params,
                    payload.message,
                    locale,
                  );
                }
                break;
              }

              case 'analyze_restock':
                finalResponse = await this.handleAnalyzeRestock(
                  storeId,
                  params,
                  payload.message,
                  locale,
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
                    locale,
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
         - If the user's message is a greeting or asks for help/guide/features -> Reply friendly as Tori and EXPLICITLY LIST your capabilities: 1) Create Import/Export, 2) Check product info & low stock, 3) View Audit Logs, 4) Smart Analysis & Restock Suggestions.
         - If the message is OUT OF DOMAIN (e.g. coding, math, weather, history, gossip...) -> Politely refuse to answer in the same language as the user. Explain that you are a specialized assistant for Storix and can only assist with store and inventory management tasks.`,
            ),
            locale,
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

  private async handleGetLowStock(
    storeId: string,
    userMessage: string,
    locale: string,
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
        locale,
      ),
      data: { totalCount, items: displayItems },
    };
  }

  private async handleGetProductInfo(
    storeId: string,
    productName: string | undefined,
    userMessage: string,
    locale: string,
  ): Promise<ChatbotResponseDto> {
    if (!productName) {
      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(
            userMessage,
            `Task: Inform the user that you found multiple products matching "${productName}". Ask them to select the exact one from the interface below 👇. (Strict rule: Output only 1-2 sentences. No bullet points, no product examples).`,
          ),
          locale,
        ),
      };
    }

    const searchResult = await ProductSearchHelper.searchInventory(
      this.inventoryService,
      storeId,
      productName,
    );

    if (searchResult.length === 0) {
      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(
            userMessage,
            `${productName} was not found in the inventory.`,
          ),
          locale,
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
          locale,
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
          locale,
        ),
        data: firstResult,
      };
    }

    return {
      aiIntent: 'choose_product',
      botReply: await this.generateFriendlyReply(
        this.buildReplyContext(
          userMessage,
          `Task: The system found multiple results for "${productName}". Inform the user to select the exact product from the interface below 👇. Keep it very short (1 sentence) and DO NOT list the products yourself.`,
        ),
        locale,
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
    locale: string,
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
          locale,
        ),
      };
    }

    const isExport = intent === 'create_export';
    let cart = await this.chatMemoryService.getCartSession(storeId, userId);

    if (!cart || cart.type !== intent) {
      cart = { type: intent, items: [] };
    }

    const tempCartItems: CartItem[] = cart.items.map((item) => ({ ...item }));
    const newlyAddedItems: string[] = [];

    const searchPromises = itemsToProcess.map(async (item) => {
      if (!item.product_name || !item.quantity) {
        return null;
      }
      const searchResult = await ProductSearchHelper.searchInventory(
        this.inventoryService,
        storeId,
        item.product_name,
      );

      return { item, searchResult };
    });

    const resolvedSearchResults = (await Promise.all(searchPromises)).filter(
      (res) => res !== null,
    ) as {
      item: { product_name: string; quantity: number | string };
      searchResult: InventoryItemData[];
    }[];

    const saveProgressAndReturn = async (returnPayload: ChatbotResponseDto) => {
      cart!.items = tempCartItems;
      await this.chatMemoryService.saveCartSession(storeId, userId, cart!);

      return returnPayload;
    };

    for (const { item, searchResult } of resolvedSearchResults) {
      if (searchResult.length === 0) {
        return saveProgressAndReturn({
          aiIntent: intent,
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              userMessage,
              `Task: Inform the user that "${item.product_name}" was not found in the inventory. Also let them know that previous valid items (if any) have been saved to the draft cart.`,
            ),
            locale,
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
            locale,
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

      const existingItem = tempCartItems.find(
        (i) => i.productPackageId === pkg.productPackageId,
      );
      const newQuantity = existingItem
        ? existingItem.quantity + Number(item.quantity)
        : Number(item.quantity);

      if (isExport && targetItem.quantity < newQuantity) {
        return saveProgressAndReturn({
          aiIntent: intent,
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              userMessage,
              `Task: Inform the user that there is insufficient stock. The inventory only has ${targetItem.quantity}, but they want to export ${newQuantity}.`,
            ),
            locale,
          ),
        });
      }

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

    cart.items = tempCartItems;
    await this.chatMemoryService.saveCartSession(storeId, userId, cart);

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
        locale,
      ),
      data: { draftActionId: draftId },
    };
  }

  private isAuditLogDetails(obj: unknown): obj is AuditLogDetails {
    if (typeof obj !== 'object' || obj === null) {
      return false;
    }

    const candidate = obj as Record<string, unknown>;

    return (
      (typeof candidate.displayName === 'string' ||
        typeof candidate.displayName === 'undefined') &&
      (typeof candidate.productName === 'string' ||
        typeof candidate.productName === 'undefined') &&
      (typeof candidate.name === 'string' ||
        typeof candidate.name === 'undefined')
    );
  }

  private async handleQueryAuditLogs(
    storeId: string,
    params: LLMToolParams,
    userMessage: string,
    locale: string,
  ): Promise<ChatbotResponseDto> {
    const queryPayload: Record<string, unknown> = {
      limit: 15,
      page: 1,
      sortBy: 'performedAt',
      sortOrder: 'desc',
      search: params.keyword,
    };

    if (params.action_type && params.action_type.toLowerCase() !== 'all') {
      queryPayload.actionType = params.action_type.toLowerCase();
    }

    const timeRange = TimeResolverHelper.resolveTimePeriod(params.time_period);

    Object.assign(queryPayload, timeRange);

    const { items } = await this.auditLogService.getAuditLogs(
      storeId,
      queryPayload as unknown as ListAuditLogsQueryDto,
    );

    if (items.length === 0) {
      return {
        aiIntent: 'query_audit_logs',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(userMessage, 'No action history found.'),
          locale,
        ),
      };
    }

    // 2. Ép kiểu mảng dữ liệu về đúng Interface AuditLogRecord vừa tạo thay vì dùng any[]
    const responseData = (items as unknown as AuditLogRecord[]).map((log) => {
      let details: AuditLogDetails = {};

      if (typeof log.newValue === 'string') {
        const trimmed = log.newValue.trim();

        if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
          try {
            const parsed: unknown = JSON.parse(trimmed);

            // Gọi chính xác phương thức instance bằng 'this.'
            if (this.isAuditLogDetails(parsed)) {
              details = parsed;
            }
          } catch {
            // Bỏ qua block catch trống một cách an toàn
          }
        }
      } else if (this.isAuditLogDetails(log.newValue)) {
        details = log.newValue;
      }

      const rawNote = log.note || '';
      let displayTarget =
        details.displayName || details.productName || details.name || rawNote;

      if (!displayTarget || /^[0-9a-fA-F-]{36}$/.test(displayTarget)) {
        if (log.entityType === 'Transaction') {
          const noteLower = rawNote.toLowerCase();

          displayTarget =
            noteLower.includes('xuất') || noteLower.includes('export')
              ? 'Export Transaction'
              : 'Import Transaction';
        } else {
          displayTarget = log.entityType || 'System Data';
        }
      }

      // Đảm bảo kiểu dữ liệu đầu vào cho Date luôn hợp lệ và ngắt dòng chuẩn max-len
      const performedAtTime = log.performedAt
        ? new Date(log.performedAt).toLocaleString('vi-VN', {
            timeZone: 'Asia/Ho_Chi_Minh',
            hour: '2-digit',
            minute: '2-digit',
            day: '2-digit',
            month: '2-digit',
          })
        : 'N/A';

      return {
        action: log.actionType,
        target: displayTarget,
        userFullName: log.user?.fullName || 'User', // Không dùng (log.user as any)
        time: performedAtTime,
        entityType: log.entityType,
      };
    });

    const contextLines = responseData.map(
      (r) =>
        `- [${r.time}] User ${r.userFullName} performed "${r.action}" on "${r.target}"`,
    );

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
        locale,
      ),
      data: responseData,
    };
  }

  private async handleAnalyzeRestock(
    storeId: string,
    params: LLMToolParams,
    userMessage: string,
    locale: string,
  ): Promise<ChatbotResponseDto> {
    if (params.product_name) {
      const searchResult = await ProductSearchHelper.searchInventory(
        this.inventoryService,
        storeId,
        params.product_name,
      );

      if (searchResult.length === 0) {
        return {
          aiIntent: 'analyze_restock',
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              userMessage,
              `Không tìm thấy sản phẩm "${params.product_name}" trong hệ thống để phân tích.`,
            ),
            locale,
          ),
        };
      }

      const targetItem =
        findExactInventoryMatch(searchResult, params.product_name) ||
        searchResult[0];
      const packageId = targetItem!.productPackage.productPackageId;
      const displayName = targetItem!.productPackage.displayName;

      const crossSellItems =
        await this.transactionService.getCrossSellSuggestions(
          storeId,
          packageId,
          3,
        );

      if (crossSellItems.length === 0) {
        return {
          aiIntent: 'analyze_restock',
          botReply: await this.generateFriendlyReply(
            this.buildReplyContext(
              userMessage,
              `Hiện tại chưa có đủ dữ liệu giao dịch để phân tích các sản phẩm thường được mua kèm với ${displayName}.`,
            ),
            locale,
          ),
        };
      }

      const crossSellText = (crossSellItems as CrossSellItem[])
        .map(
          (item) =>
            `- Sản phẩm: ${item.productName || 'N/A'} (Mã tham chiếu: ${item.associatedPackageId}, Tần suất mua cùng: ${item.frequency} lần)`,
        )
        .join('\n');

      const systemContext = `Data Analysis: Customers who bought "${displayName}" often buy these items together:\n${crossSellText}\nTask: Explain this insight to the user naturally using Product Names. Suggest they might want to import or display these items close to each other.`;

      return {
        aiIntent: 'analyze_restock',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(userMessage, systemContext),
          locale,
        ),
        data: {
          type: 'cross_sell',
          targetProduct: displayName,
          crossSellItems,
        },
      };
    }

    const suggestions =
      await this.smartDecisionService.getStoreReorderSuggestions(storeId);

    if (suggestions.length === 0) {
      return {
        aiIntent: 'analyze_restock',
        botReply: await this.generateFriendlyReply(
          this.buildReplyContext(
            userMessage,
            'Kho hàng của bạn hiện đang ở trạng thái tối ưu. Dựa trên tốc độ bán hàng hiện tại, chưa có sản phẩm nào chạm ngưỡng cần phải nhập thêm ngay lập tức.',
          ),
          locale,
        ),
        data: { type: 'general_restock', suggestions: [] },
      };
    }

    const displaySuggestions = suggestions.slice(0, 5);
    const suggestionsText = displaySuggestions
      .map(
        (s) =>
          `- ${s.productName}: Kho còn ${s.currentStock}. Vận tốc bán hàng dự báo cạn kho sớm. Đề xuất nhập thêm: ${s.suggestedQuantity} đơn vị.`,
      )
      .join('\n');

    const total = suggestions.length;
    const moreText = total > 5 ? ` (Và ${total - 5} mặt hàng khác)` : '';

    const systemContext = `Restock Analysis Results:\n${suggestionsText}\n${moreText}\nTask: Act as a proactive operation manager. Present these restock suggestions to the user clearly. You can ask if they want you to automatically draft an Import Transaction for these items.`;

    return {
      aiIntent: 'analyze_restock',
      botReply: await this.generateFriendlyReply(
        this.buildReplyContext(userMessage, systemContext),
        locale,
      ),
      data: { type: 'general_restock', suggestions },
    };
  }

  public async confirmDraftAction(
    draftActionId: string,
    isConfirmed: boolean,
    requestingStoreId: string,
    requestingUserId: string,
    locale: string,
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

        const cancelInstruction =
          locale === 'en'
            ? '[SYSTEM]: The transaction operation has been cancelled by the user. Inform them friendly.'
            : '[SYSTEM]: Thao tác tạo phiếu kho đã bị hủy bởi người dùng. Hãy thông báo một cách thân thiện.';

        return await this.generateFriendlyReply(
          this.buildReplyContext(lastUserMessage, cancelInstruction),
          locale,
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

      await this.chatMemoryService.clearChatHistory(
        draft.storeId,
        draft.userId,
      );
      await this.chatMemoryService.clearCartSession(
        draft.storeId,
        draft.userId,
      );

      const successInstruction =
        locale === 'en'
          ? '[SYSTEM]: The transaction has been recorded successfully. Congratulate the user.'
          : '[SYSTEM]: Giao dịch kho đã được ghi nhận thành công vào hệ thống Storix. Hãy chúc mừng người dùng.';

      return await this.generateFriendlyReply(
        this.buildReplyContext(lastUserMessage, successInstruction),
        locale,
      );
    } finally {
      await this.redisClient.del(draftKey);
      await this.redisClient.del(refKey);
    }
  }

  private buildReplyContext(userMessage: string, systemData: string): string {
    return `You are Tori, a helpful AI assistant for Storix.

SYSTEM FACTS / TASKS:
${systemData}

USER MESSAGE:
"${userMessage}"

STRICT INSTRUCTIONS:
- Respond directly with the conversational text based ONLY on the SYSTEM FACTS.
- CRITICAL: DO NOT output any prefixes like "[REPLY]", "Reply:", or explain your thoughts. Output ONLY the final conversational response.
- 🛑 DATA PRESENTATION RULES:
  - NEVER display raw IDs or UUIDs (e.g., '22222222-2222...') in your conversation.
  - ALWAYS use the Product Name (DisplayName) provided in the facts to refer to items.
  - If a Product Name is available, ignore its ID in the final reply.`;
  }
}
