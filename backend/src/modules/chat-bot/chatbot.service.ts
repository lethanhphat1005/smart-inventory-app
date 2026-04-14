import { StatusCodes } from 'http-status-codes';
import { OpenAI } from 'openai';

import { CustomError } from '../../common/errors/index.js';

import type { ChatbotRequestDto, ChatbotResponseDto } from './chatbot.dto.js';
import type { ListInventoriesQueryDto } from '../inventories/dto/inventory.dto.js';
import type { InventoryService } from '../inventories/index.js';
import type { ListTransactionsQueryDto } from '../transactions/transaction.dto.js';
import type { TransactionService } from '../transactions/transaction.service.js';

import 'dotenv/config';
export class ChatbotService {
  private openai: OpenAI;

  constructor(
    private readonly inventoryService: InventoryService,
    private readonly transactionService: TransactionService,
  ) {
    // this.openai = new OpenAI({
    //   baseURL: 'http://localhost:1234/v1',
    //   apiKey: 'local',
    // });
    this.openai = new OpenAI({
      baseURL: 'https://api.groq.com/openai/v1',
      apiKey: process.env.GROQ_API_KEY,
    });
  }

  public async processMessage(
    storeId: string,
    userId: string,
    payload: ChatbotRequestDto,
  ): Promise<ChatbotResponseDto> {
    try {
      const response = await this.openai.chat.completions.create({
        // model: 'qwen2.5-vl-3b-instruct',
        model: 'llama-3.1-8b-instant',
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
                'Please provide the product name and the quantity you want to export.',
            };
          }

          const query = {
            keyword: params.product_name,
            limit: 5, // 🌟 Lấy tối đa 5 kết quả
            page: 1,
          } as unknown as ListInventoriesQueryDto;
          const searchResult =
            await this.inventoryService.getInventoriesByStoreId(storeId, query);

          if (searchResult.items.length === 0) {
            return {
              aiIntent: intent,
              botReply: `I couldn't find the product "${params.product_name}" to export.`,
            };
          }

          let targetItem;

          // 🌟 FIX RỦI RO 2: XỬ LÝ TRÙNG LẶP (MULTIPLE MATCHES)
          if (searchResult.items.length > 1) {
            const exactMatch = searchResult.items.find(
              (i) =>
                i.productPackage.displayName?.toLowerCase() ===
                params.product_name.toLowerCase(),
            );

            if (exactMatch) {
              targetItem = exactMatch;
            } else {
              const options = searchResult.items
                .map((i) => i.productPackage.displayName)
                .join(', ');

              return {
                aiIntent: intent,
                botReply: `I found multiple items matching "${params.product_name}": ${options}. Which specific one do you mean?`,
              };
            }
          } else {
            targetItem = searchResult.items[0];
            if (!targetItem) {
              return {
                aiIntent: intent,
                botReply: 'Không tìm thấy sản phẩm phù hợp trong kho.',
              };
            }
          }

          const pkg = targetItem.productPackage;
          const sellingPrice = pkg.sellingPrice ? Number(pkg.sellingPrice) : 0;

          if (sellingPrice <= 0) {
            return {
              aiIntent: intent,
              botReply: `⚠️ The product "${pkg.displayName}" does not have a Selling Price configured. Please update it first!`,
            };
          }

          if (targetItem.quantity < params.quantity) {
            return {
              aiIntent: intent,
              botReply: `⚠️ Unfortunately, there are only ${targetItem.quantity} ${pkg.unit.name} of ${pkg.displayName} left in stock. Not enough to export!`,
            };
          }

          // 🌟 FIX RỦI RO 3: TRẢ VỀ BẢN NHÁP (DRAFT)
          const draftPayload = {
            note: 'Automatic export via AI Assistant',
            items: [
              {
                productPackageId: pkg.productPackageId,
                quantity: params.quantity,
                unitPrice: sellingPrice,
              },
            ],
          };

          const estimatedTotal = (
            params.quantity * sellingPrice
          ).toLocaleString('en-US');

          return {
            aiIntent: 'confirm_export', // Đổi Intent thành "Chờ xác nhận"
            botReply: `Do you want to create an export transaction for **${params.quantity} ${pkg.displayName}** (Total value: ${estimatedTotal} VND)?\n\nPlease confirm below.`,
            data: draftPayload, // Trả nguyên cục payload này cho Flutter
          };
        }

        case 'create_import': {
          if (!params.product_name || !params.quantity) {
            return {
              aiIntent: intent,
              botReply:
                'Please provide the product name and the quantity you want to import.',
            };
          }

          const query = {
            keyword: params.product_name,
            limit: 5, // 🌟 Lấy tối đa 5 kết quả để check trùng lặp
            page: 1,
          } as unknown as ListInventoriesQueryDto;

          const searchResult =
            await this.inventoryService.getInventoriesByStoreId(storeId, query);

          if (searchResult.items.length === 0) {
            return {
              aiIntent: intent,
              botReply: `I couldn't find the product "${params.product_name}" in the system to create an import transaction.`,
            };
          }

          let targetItem;

          // 🌟 FIX RỦI RO 2: XỬ LÝ TRÙNG LẶP (MULTIPLE MATCHES)
          if (searchResult.items.length > 1) {
            // Thử tìm xem có tên nào khớp chính xác 100% không
            const exactMatch = searchResult.items.find(
              (i) =>
                i.productPackage.displayName?.toLowerCase() ===
                params.product_name.toLowerCase(),
            );

            if (exactMatch) {
              targetItem = exactMatch;
            } else {
              // Nếu không khớp chính xác, liệt kê danh sách cho user chọn
              const options = searchResult.items
                .map((i) => i.productPackage.displayName)
                .join(', ');

              return {
                aiIntent: intent, // Giữ nguyên intent để user gõ lại
                botReply: `I found multiple items matching "${params.product_name}": ${options}. Which specific one do you mean?`,
              };
            }
          } else {
            targetItem = searchResult.items[0];
            if (!targetItem) {
              return {
                aiIntent: intent,
                botReply: 'Không tìm thấy sản phẩm phù hợp trong kho.',
              };
            }
          }

          const pkg = targetItem.productPackage;
          const importPrice = pkg.importPrice ? Number(pkg.importPrice) : 0;

          if (importPrice <= 0) {
            return {
              aiIntent: intent,
              botReply: `⚠️ The product "${pkg.displayName}" does not have an Import Price configured. Please update it first!`,
            };
          }

          // 🌟 FIX RỦI RO 3: TRẢ VỀ BẢN NHÁP (DRAFT) THAY VÌ LƯU DATABASE
          const draftPayload = {
            note: 'Automatic import via AI Assistant',
            items: [
              {
                productPackageId: pkg.productPackageId,
                quantity: params.quantity,
                unitPrice: importPrice,
              },
            ],
          };

          const estimatedTotal = (params.quantity * importPrice).toLocaleString(
            'en-US',
          );

          return {
            aiIntent: 'confirm_import', // Đổi Intent thành "Chờ xác nhận"
            botReply: `Do you want to create an import transaction for **${params.quantity} ${pkg.displayName}** (Estimated total: ${estimatedTotal} VND)?\n\nPlease confirm below.`,
            data: draftPayload, // Trả nguyên cục payload này cho Flutter
          };
        }

        case 'get_report': {
          // 1. Lấy thông tin hàng sắp hết
          const lowStockQuery = {
            inventoryStatus: 'lowStock',
            limit: 50,
            page: 1,
          } as unknown as ListInventoriesQueryDto;
          const lowStockResult =
            await this.inventoryService.getInventoriesByStoreId(
              storeId,
              lowStockQuery,
            );

          // 2. Lấy 5 giao dịch xuất/nhập gần nhất
          const recentTxQuery = {
            limit: 5,
            page: 1,
            sortBy: 'createdAt',
            sortOrder: 'desc',
          } as unknown as ListTransactionsQueryDto;
          const recentTxResult =
            await this.transactionService.getTransactionsByStoreId(
              storeId,
              recentTxQuery,
            );

          // 3. AI "hót" ra câu trả lời tổng hợp
          let replyMessage = '**Báo cáo nhanh tình hình cửa hàng:**\n\n';

          if (lowStockResult.items.length > 0) {
            replyMessage += `Cảnh báo: Đang có **${lowStockResult.items.length}** mặt hàng chạm mốc sắp hết (cần nhập thêm).\n\n`;
          } else {
            replyMessage +=
              'Tồn kho ổn định, không có mặt hàng nào bị thiếu hụt.\n\n';
          }

          replyMessage += '**Giao dịch gần đây nhất:**\n';
          if (recentTxResult.items.length === 0) {
            replyMessage += '- Chưa có giao dịch nào.\n';
          } else {
            recentTxResult.items.forEach((tx) => {
              const txType = tx.type === 'import' ? 'Nhập kho' : 'Xuất kho';

              replyMessage += `- ${txType}: ${tx.itemCount} sản phẩm (Tổng tiền: ${tx.totalPrice.toLocaleString('vi-VN')}đ)\n`;
            });
          }

          return {
            aiIntent: intent,
            botReply: replyMessage,
            data: {
              lowStockCount: lowStockResult.items.length,
              recentTransactions: recentTxResult.items,
            },
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
