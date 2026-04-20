import { StatusCodes } from 'http-status-codes';
import { OpenAI } from 'openai';
import { v4 as uuidv4 } from 'uuid';

import {
  getCoordinatorPrompt,
  getFriendlyReplyPrompt,
} from './chatbot.prompt.js';
import { CHATBOT_TOOLS } from './chatbot.tool.js';
import { CustomError } from '../../common/errors/index.js';

import type { ChatbotRequestDto, ChatbotResponseDto } from './chatbot.dto.js';
import type {
  DraftAction,
  DraftActionType,
  InventoryItemData,
  LLMToolParams,
  TransactionItemPayload,
  TransactionPayload,
} from './chatbot.type.js';
import type { ListInventoriesQueryDto } from '../inventories/dto/inventory.dto.js';
import type { InventoryService } from '../inventories/index.js';
import type { TransactionService } from '../transactions/transaction.service.js';

import 'dotenv/config';

export class ChatbotService {
  private openai: OpenAI;
  private drafts = new Map<string, DraftAction>();

  constructor(
    private readonly inventoryService: InventoryService,
    private readonly transactionService: TransactionService,
  ) {
    this.openai = new OpenAI({
      baseURL: 'https://api.groq.com/openai/v1',
      apiKey: process.env.GROQ_API_KEY,
    });
  }

  private async generateFriendlyReply(
    userMessage: string,
    systemContext: string,
  ): Promise<string> {
    try {
      const response = await this.openai.chat.completions.create({
        model: 'llama-3.1-8b-instant',
        messages: [
          { role: 'system', content: getFriendlyReplyPrompt() },
          {
            role: 'user',
            content: `Câu nói của người dùng: "${userMessage}"\n\nDữ liệu hệ thống: ${systemContext}`,
          },
        ],
        temperature: 0.6,
      });

      return response.choices[0]?.message?.content || systemContext;
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
    try {
      const response = await this.openai.chat.completions.create({
        model: 'llama-3.1-8b-instant',
        messages: [
          { role: 'system', content: getCoordinatorPrompt(storeId, userId) },
          { role: 'user', content: payload.message },
        ],
        tools: CHATBOT_TOOLS,
        tool_choice: 'auto',
        temperature: 0.1,
      });

      const responseMessage = response.choices[0]?.message;
      const toolCalls = responseMessage?.tool_calls;

      if (toolCalls && toolCalls.length > 0) {
        const toolCall = toolCalls[0];

        if (!toolCall || toolCall.type !== 'function') {
          return { aiIntent: 'unknown', botReply: 'Lỗi truy xuất công cụ.' };
        }

        const intent = toolCall.function.name;
        let params: LLMToolParams = {};

        if (toolCall.function.arguments) {
          params = JSON.parse(toolCall.function.arguments) as LLMToolParams;
        }

        switch (intent) {
          case 'get_low_stock':
            return await this.handleGetLowStock(storeId, payload.message);
          case 'get_product_info':
            return await this.handleGetProductInfo(
              storeId,
              params.product_name,
              payload.message,
            );
          case 'create_export':
            return await this.handleTransactionDraft(
              storeId,
              userId,
              'create_export',
              params,
              payload.message,
            );
          case 'create_import':
            return await this.handleTransactionDraft(
              storeId,
              userId,
              'create_import',
              params,
              payload.message,
            );
          default:
            return {
              aiIntent: 'unknown',
              botReply: await this.generateFriendlyReply(
                payload.message,
                'Dạ, tính năng này hiện chưa khả dụng.',
              ),
            };
        }
      }

      return {
        aiIntent: 'unknown',
        botReply:
          responseMessage?.content ||
          'Em chưa hiểu ý anh/chị, mình có thể nói rõ hơn được không ạ?',
      };
    } catch (error) {
      console.error('[Chatbot Error]', error);
      throw new CustomError({
        message: 'Lỗi kết nối với mô hình AI',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    }
  }

  public async confirmDraftAction(
    draftActionId: string,
    isConfirmed: boolean,
  ): Promise<string> {
    if (!isConfirmed) {
      this.drafts.delete(draftActionId);

      return await this.generateFriendlyReply(
        'Hủy bỏ thao tác',
        'Yêu cầu của bạn đã được hủy thành công.',
      );
    }

    const draft = this.drafts.get(draftActionId);

    if (!draft) {
      throw new CustomError({
        message: 'Phiên làm việc đã hết hạn.',
        status: StatusCodes.GONE,
      });
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

    this.drafts.delete(draftActionId);

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

    const exactMatch = this.findExactMatch(searchResult, productName);
    const firstResult = searchResult[0];

    if (exactMatch) {
      const context = `Sản phẩm ${exactMatch.productPackage.displayName} có giá bán ${exactMatch.productPackage.sellingPrice} VNĐ. Tồn kho: ${exactMatch.quantity} ${exactMatch.productPackage.unit.name}.`;

      return {
        aiIntent: 'get_product_info',
        botReply: await this.generateFriendlyReply(userMessage, context),
        data: exactMatch,
      };
    }

    if (searchResult.length === 1 && firstResult) {
      const context = `Sản phẩm ${firstResult.productPackage.displayName} có giá bán ${firstResult.productPackage.sellingPrice} VNĐ. Tồn kho: ${firstResult.quantity} ${firstResult.productPackage.unit.name}.`;

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
      const exactMatch = this.findExactMatch(searchResult, item.product_name);
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

    const draftId = `draft_${uuidv4()}`;

    this.drafts.set(draftId, {
      id: draftId,
      type: intent,
      storeId,
      userId,
      payload,
      createdAt: Date.now(),
    });
    setTimeout(() => this.drafts.delete(draftId), 5 * 60 * 1000);

    const systemContext = `Hệ thống chuẩn bị tạo phiếu ${actionText} cho các sản phẩm: ${successMessages.join('; ')}. Tổng tiền: ${grandTotal.toLocaleString('vi-VN')} VNĐ. Yêu cầu người dùng xác nhận trên giao diện.`;

    return {
      aiIntent: isExport ? 'confirm_export' : 'confirm_import',
      botReply: await this.generateFriendlyReply(userMessage, systemContext),
      data: { draftActionId: draftId },
    };
  }

  // ==========================================
  // UTILS (Giữ nguyên như cũ)
  // ==========================================

  private async searchInventory(
    storeId: string,
    keyword: string,
  ): Promise<InventoryItemData[]> {
    const query = {
      keyword,
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

    return res.items as InventoryItemData[];
  }

  private findExactMatch(
    items: InventoryItemData[],
    keyword: string,
  ): InventoryItemData | undefined {
    const normalizeName = (str?: string | null) =>
      (str || '').toLowerCase().replace(/[\s()-]/g, '');

    return items.find(
      (i) =>
        normalizeName(i.productPackage.displayName) === normalizeName(keyword),
    );
  }
}
