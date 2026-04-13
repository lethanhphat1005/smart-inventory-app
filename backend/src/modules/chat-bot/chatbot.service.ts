import { StatusCodes } from 'http-status-codes';
import { OpenAI } from 'openai';

import { CustomError } from '../../common/errors/index.js';

import type { ChatbotRequestDto, ChatbotResponseDto } from './chatbot.dto.js';
import type { ListInventoriesQueryDto } from '../inventories/dto/inventory.dto.js';
import type { InventoryService } from '../inventories/index.js';
import type { TransactionService } from '../transactions/transaction.service.js';
export class ChatbotService {
  private openai: OpenAI;

  constructor(
    private readonly inventoryService: InventoryService,
    private readonly transactionService: TransactionService,
  ) {
    this.openai = new OpenAI({
      baseURL: 'http://localhost:1234/v1',
      apiKey: 'local',
    });
  }

  public async processMessage(
    storeId: string,
    userId: string,
    payload: ChatbotRequestDto,
  ): Promise<ChatbotResponseDto> {
    try {
      const response = await this.openai.chat.completions.create({
        model: 'qwen2.5-vl-3b-instruct',
        messages: [
          {
            role: 'system',
            content: `Bạn là trợ lý AI điều phối dữ liệu của hệ thống Smart Store Support System.
              Nhiệm vụ duy nhất của bạn là phân tích câu nói của người dùng và trả về một chuỗi JSON hợp lệ.
              TUYỆT ĐỐI KHÔNG giải thích, KHÔNG thêm bất kỳ văn bản nào ngoài JSON.
              Danh sách các "intent" (ý định) được hỗ trợ:
              "get_low_stock": Xem hàng sắp hết, cần nhập thêm.
              "get_product_info": Hỏi thông tin, giá bán, số lượng tồn kho của một sản phẩm cụ thể.
              "create_export": Yêu cầu xuất kho/bán hàng.
              "create_import": Yêu cầu nhập hàng vào kho.
              "get_report": Xem báo cáo tổng quan.
              "unknown": Câu hỏi nằm ngoài phạm vi quản lý kho.
              Định dạng JSON bắt buộc:
              {
                "intent": "tên_intent",
                "parameters": {
                "product_name": "tên sản phẩm (nếu có, không có thì để null)",
                "quantity": số lượng (kiểu số nguyên, nếu không có để null)
              }
            }`,
          },
          { role: 'user', content: payload.message },
        ],
        temperature: 0.1,
      });

      let aiContent = response.choices[0]?.message?.content || '{}';

      aiContent = aiContent
        .replace(/```json/g, '')
        .replace(/```/g, '')
        .trim();

      const parsedData = JSON.parse(aiContent);

      const intent = parsedData.intent || 'unknown';
      const params = parsedData.parameters || {};

      switch (intent) {
        case 'get_low_stock': {
          const query = {
            inventoryStatus: 'lowStock',
            limit: 10,
            page: 1,
            sortBy: 'quantity',
            sortOrder: 'asc',
          } as unknown as ListInventoriesQueryDto;

          const inventories =
            await this.inventoryService.getInventoriesByStoreId(storeId, query);
          const lowStockNames = inventories.items
            .map((i) => `${i.productPackage.displayName} (Còn: ${i.quantity})`)
            .join(', ');

          return {
            aiIntent: intent,
            botReply:
              inventories.items.length > 0
                ? `Hiện tại kho có các sản phẩm sắp hết hàng cần lưu ý: ${lowStockNames}`
                : 'Tuyệt vời, hiện tại không có sản phẩm nào chạm mức cảnh báo hết hàng!',
            data: inventories.items,
          };
        }

        case 'get_product_info': {
          if (!params.product_name) {
            return {
              aiIntent: intent,
              botReply: 'Vui lòng cho biết tên sản phẩm bạn muốn tìm.',
            };
          }

          const query = {
            keyword: params.product_name,
            limit: 5,
            page: 1,
            sortBy: 'updatedAt',
            sortOrder: 'desc',
          } as unknown as ListInventoriesQueryDto;

          const searchResult =
            await this.inventoryService.getInventoriesByStoreId(storeId, query);

          if (searchResult.items.length === 0) {
            return {
              aiIntent: intent,
              botReply: `Dạ em tìm trong kho không thấy sản phẩm nào tên là "${params.product_name}".`,
            };
          }

          const item = searchResult.items[0];

          if (!item) {
            return {
              aiIntent: intent,
              botReply:
                'Không thể lấy thông tin chi tiết của sản phẩm lúc này.',
            };
          }

          return {
            aiIntent: intent,

            botReply: `Sản phẩm ${item.productPackage.displayName} đang có giá bán ${item.productPackage.sellingPrice} VNĐ. Tồn kho hiện tại: ${item.quantity} ${item.productPackage.unit.name}.`,
            data: item,
          };
        }

        case 'create_export': {
          if (!params.product_name || !params.quantity) {
            return {
              aiIntent: intent,
              botReply:
                'Vui lòng cho biết rõ tên sản phẩm và số lượng bạn muốn xuất nhé.',
            };
          }

          const query = {
            keyword: params.product_name,
            limit: 1,
            page: 1,
          } as unknown as ListInventoriesQueryDto;
          const searchResult =
            await this.inventoryService.getInventoriesByStoreId(storeId, query);

          if (searchResult.items.length === 0) {
            return {
              aiIntent: intent,
              botReply: `Không tìm thấy sản phẩm "${params.product_name}" để xuất kho.`,
            };
          }

          const targetItem = searchResult.items[0];

          if (!targetItem) {
            return {
              aiIntent: intent,
              botReply: 'Không tìm thấy sản phẩm phù hợp trong kho.', // Bạn có thể tùy chỉnh câu này
            };
          }

          const pkg = targetItem.productPackage;

          if (targetItem.quantity < params.quantity) {
            return {
              aiIntent: intent,
              botReply: `Không đủ hàng! ${pkg.displayName} chỉ còn ${targetItem.quantity} ${pkg.unit.name} trong kho.`,
            };
          }

          const txResponse =
            await this.transactionService.createExportTransaction(
              storeId,
              userId,
              {
                note: 'Xuất kho tự động qua AI Chatbot',
                items: [
                  {
                    productPackageId: pkg.productPackageId,
                    quantity: params.quantity,
                    unitPrice: pkg.sellingPrice || 0,
                  },
                ],
              },
            );

          return {
            aiIntent: intent,
            botReply: `Thành công! Đã tạo phiếu xuất kho cho ${params.quantity} ${pkg.displayName}. Tổng tiền: ${txResponse.totalPrice}đ.`,
            data: txResponse,
          };
        }

        default:
          return {
            aiIntent: 'unknown',
            botReply: 'Dạ, em chỉ là AI quản lý kho nên chưa hiểu ý này.',
          };
      }
    } catch (error) {
      console.error('[Chatbot Error]', error);
      throw new CustomError({
        message: 'Lỗi khi AI đang phân tích dữ liệu kho',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    }
  }
}
