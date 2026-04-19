import { StatusCodes } from 'http-status-codes';
import { OpenAI } from 'openai';
import { v4 as uuidv4 } from 'uuid';

import { CustomError } from '../../common/errors/index.js';

import type { ChatbotRequestDto, ChatbotResponseDto } from './chatbot.dto.js';
import type { ListInventoriesQueryDto } from '../inventories/dto/inventory.dto.js';
import type { InventoryService } from '../inventories/index.js';
import type { TransactionService } from '../transactions/transaction.service.js';

import 'dotenv/config';

// ==========================================
// INTERFACES
// ==========================================

export type DraftActionType = 'create_import' | 'create_export';

export interface LLMProductParams {
  product_name?: string;
  quantity?: number;
}

export interface TransactionItemPayload {
  productPackageId: string;
  quantity: number;
  unitPrice: number;
}

export interface TransactionPayload {
  note: string;
  items: TransactionItemPayload[];
}

export interface DraftAction {
  id: string;
  type: DraftActionType;
  storeId: string;
  userId: string;
  payload: TransactionPayload;
  createdAt: number;
}

export interface InventoryPackageData {
  productPackageId: string;
  displayName: string;
  sellingPrice: number | string;
  importPrice: number | string;
  unit: { name: string };
}

export interface InventoryItemData {
  quantity: number;
  reorder_threshold?: number;
  reorderThreshold?: number;
  productPackage: InventoryPackageData;
}

// ==========================================
// SERVICE LỚP CHÍNH
// ==========================================

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

  private readonly chatbotTools: OpenAI.Chat.Completions.ChatCompletionTool[] =
    [
      {
        type: 'function',
        function: {
          name: 'get_low_stock',
          description:
            'Xem danh sách các sản phẩm sắp hết hàng hoặc đã hết hàng trong kho cần nhập thêm.',
          parameters: {
            type: 'object',
            properties: {},
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'get_product_info',
          description:
            'Hỏi thông tin, giá bán, số lượng tồn kho của một sản phẩm cụ thể.',
          parameters: {
            type: 'object',
            properties: {
              product_name: {
                type: 'string',
                description: 'Tên sản phẩm cần tìm',
              },
            },
            required: ['product_name'],
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'create_export',
          description: 'Yêu cầu tạo phiếu xuất kho hoặc bán hàng.',
          parameters: {
            type: 'object',
            properties: {
              product_name: {
                type: 'string',
                description: 'Tên sản phẩm cần xuất',
              },
              quantity: { type: 'number', description: 'Số lượng cần xuất' },
            },
            required: ['product_name', 'quantity'],
          },
        },
      },
      {
        type: 'function',
        function: {
          name: 'create_import',
          description: 'Yêu cầu tạo phiếu nhập hàng vào kho.',
          parameters: {
            type: 'object',
            properties: {
              product_name: {
                type: 'string',
                description: 'Tên sản phẩm cần nhập',
              },
              quantity: { type: 'number', description: 'Số lượng cần nhập' },
            },
            required: ['product_name', 'quantity'],
          },
        },
      },
    ];

  public async processMessage(
    storeId: string,
    userId: string,
    payload: ChatbotRequestDto,
  ): Promise<ChatbotResponseDto> {
    try {
      const response = await this.openai.chat.completions.create({
        model: 'llama-3.1-8b-instant',
        messages: [
          {
            role: 'system',
            content: `Bạn là trợ lý AI điều phối dữ liệu của hệ thống Smart Store Support System.
Nhiệm vụ của bạn là phân tích câu nói của người dùng và gọi Tool phù hợp nhất.

[THÔNG TIN HỆ THỐNG]
Active store ID: ${storeId}
User ID: ${userId}

QUY TẮC TUYỆT ĐỐI:
1. Backend đã tự động xử lý Store ID và User ID. Bạn TUYỆT ĐỐI KHÔNG ĐƯỢC truyền 'store_id' hay 'user_id' vào bất kỳ tham số (parameters) nào của Tools.
2. Không bao giờ tự bịa ra dữ liệu tồn kho.`,
          },
          { role: 'user', content: payload.message },
        ],
        tools: this.chatbotTools,
        tool_choice: 'auto',
        temperature: 0.1,
      });

      const responseMessage = response.choices[0]?.message;
      const toolCalls = responseMessage?.tool_calls;

      if (toolCalls && toolCalls.length > 0) {
        // Fix TS Strict: Ép kiểu hoặc check null cho array index
        const toolCall = toolCalls[0];

        if (!toolCall) {
          return {
            aiIntent: 'unknown',
            botReply: 'Lỗi truy xuất công cụ từ AI.',
          };
        }

        if (toolCall.type !== 'function') {
          return {
            aiIntent: 'unknown',
            botReply: 'Loại công cụ không được hỗ trợ.',
          };
        }

        const intent = toolCall.function.name;

        let params: LLMProductParams = {};

        if (toolCall.function.arguments) {
          params = JSON.parse(toolCall.function.arguments) as LLMProductParams;
        }

        switch (intent) {
          case 'get_low_stock':
            return await this.handleGetLowStock(storeId);
          case 'get_product_info':
            return await this.handleGetProductInfo(
              storeId,
              params.product_name,
            );
          case 'create_export':
            return await this.handleTransactionDraft(
              storeId,
              userId,
              'create_export',
              params,
            );
          case 'create_import':
            return await this.handleTransactionDraft(
              storeId,
              userId,
              'create_import',
              params,
            );
          default:
            return {
              aiIntent: 'unknown',
              botReply: 'Dạ, em chưa hỗ trợ tác vụ này.',
            };
        }
      }

      return {
        aiIntent: 'unknown',
        botReply:
          responseMessage?.content ||
          'Dạ, em chỉ là AI quản lý kho nên chưa hiểu ý này.',
      };
    } catch (error) {
      console.error('[Chatbot Error]', error);
      throw new CustomError({
        message: 'Lỗi kết nối với mô hình AI',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    }
  }

  // ==========================================
  // PHA 2: XỬ LÝ XÁC NHẬN GIAO DỊCH
  // ==========================================
  public async confirmDraftAction(
    draftActionId: string,
    isConfirmed: boolean,
  ): Promise<string> {
    if (!isConfirmed) {
      this.drafts.delete(draftActionId);

      return 'Đã hủy thao tác.';
    }

    const draft = this.drafts.get(draftActionId);

    if (!draft) {
      throw new CustomError({
        message: 'Yêu cầu đã hết hạn hoặc không tồn tại.',
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

    return 'Giao dịch thành công!';
  }

  private async handleGetLowStock(
    storeId: string,
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

    return {
      aiIntent: 'get_low_stock',
      botReply:
        totalCount > 0
          ? `Hệ thống ghi nhận có tổng cộng ${totalCount} sản phẩm chạm mức cảnh báo.\n\nDưới đây là danh sách 5 sản phẩm cạn kiệt cần ưu tiên nhập sớm nhất:`
          : 'Tuyệt vời, hiện tại không có sản phẩm nào chạm mức cảnh báo!',
      data: {
        totalCount: totalCount,
        items: displayItems,
      },
    };
  }

  private async handleGetProductInfo(
    storeId: string,
    productName?: string,
  ): Promise<ChatbotResponseDto> {
    if (!productName) {
      return {
        aiIntent: 'get_product_info',
        botReply: 'Vui lòng cho biết tên sản phẩm bạn muốn tìm.',
      };
    }

    const searchResult = await this.searchInventory(storeId, productName);

    if (searchResult.length === 0) {
      return {
        aiIntent: 'get_product_info',
        botReply: `Dạ em không tìm thấy "${productName}" trong kho.`,
      };
    }

    const exactMatch = this.findExactMatch(searchResult, productName);
    const firstResult = searchResult[0]; // Fix TS Strict

    if (exactMatch) {
      return {
        aiIntent: 'get_product_info',
        botReply: `Sản phẩm ${exactMatch.productPackage.displayName} đang có giá bán ${exactMatch.productPackage.sellingPrice} VNĐ. Tồn kho hiện tại: ${exactMatch.quantity} ${exactMatch.productPackage.unit.name}.`,
        data: exactMatch,
      };
    }
    if (searchResult.length === 1 && firstResult) {
      return {
        aiIntent: 'get_product_info',
        botReply: `Sản phẩm ${firstResult.productPackage.displayName} đang có giá bán ${firstResult.productPackage.sellingPrice} VNĐ. Tồn kho hiện tại: ${firstResult.quantity} ${firstResult.productPackage.unit.name}.`,
        data: firstResult,
      };
    }

    return {
      aiIntent: 'choose_product',
      botReply: `Hệ thống tìm thấy nhiều kết quả cho "${productName}". Vui lòng chọn sản phẩm:`,
      data: { originalIntent: 'get_product_info', items: searchResult },
    };
  }

  private async handleTransactionDraft(
    storeId: string,
    userId: string,
    intent: DraftActionType,
    params: LLMProductParams,
  ): Promise<ChatbotResponseDto> {
    if (!params.product_name || !params.quantity) {
      return {
        aiIntent: intent,
        botReply: 'Vui lòng cung cấp đủ tên sản phẩm và số lượng.',
      };
    }

    const searchResult = await this.searchInventory(
      storeId,
      params.product_name,
    );

    if (searchResult.length === 0) {
      return {
        aiIntent: intent,
        botReply: `Dạ em không tìm thấy "${params.product_name}".`,
      };
    }

    let targetItem: InventoryItemData;
    const exactMatch = this.findExactMatch(searchResult, params.product_name);
    const firstResult = searchResult[0]; // Fix TS Strict

    if (exactMatch) {
      targetItem = exactMatch;
    } else if (searchResult.length === 1 && firstResult) {
      targetItem = firstResult;
    } else {
      return {
        aiIntent: 'choose_product',
        botReply: `Vui lòng chọn chính xác sản phẩm để ${intent === 'create_export' ? 'xuất' : 'nhập'}:`,
        data: {
          originalIntent: intent,
          quantity: params.quantity,
          items: searchResult,
        },
      };
    }

    const pkg = targetItem.productPackage;
    const isExport = intent === 'create_export';
    const price = isExport ? Number(pkg.sellingPrice) : Number(pkg.importPrice);

    if (price <= 0) {
      return {
        aiIntent: intent,
        botReply: `⚠️ Sản phẩm "${pkg.displayName}" chưa được cài đặt Giá ${isExport ? 'bán' : 'nhập'}!`,
      };
    }
    if (isExport && targetItem.quantity < params.quantity) {
      return {
        aiIntent: intent,
        botReply: `⚠️ Trong kho chỉ còn ${targetItem.quantity} ${pkg.unit.name}. Không đủ để xuất!`,
      };
    }

    const payload: TransactionPayload = {
      note: `${isExport ? 'Xuất' : 'Nhập'} kho tự động qua AI Assistant`,
      items: [
        {
          productPackageId: pkg.productPackageId,
          quantity: Number(params.quantity),
          unitPrice: price,
        },
      ],
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

    const estimatedTotal = (params.quantity * price).toLocaleString('vi-VN');
    const actionText = isExport ? '**XUẤT KHO**' : '**NHẬP KHO**';

    return {
      aiIntent: isExport ? 'confirm_export' : 'confirm_import',
      botReply: `Bạn có muốn tạo phiếu ${actionText} cho **${params.quantity} ${pkg.displayName}** (Tổng: ${estimatedTotal} VNĐ) không?\n\nVui lòng xác nhận.`,
      data: { draftActionId: draftId },
    };
  }

  // ==========================================
  // UTILS
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
      // Fix TS Strict: Check mảng sinh ra từ split
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
