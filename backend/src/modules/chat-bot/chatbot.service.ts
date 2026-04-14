import { StatusCodes } from 'http-status-codes';
import { OpenAI } from 'openai';

import { CustomError } from '../../common/errors/index.js';

import type { ChatbotRequestDto, ChatbotResponseDto } from './chatbot.dto.js';
import type { ListInventoriesQueryDto } from '../inventories/dto/inventory.dto.js';
import type { InventoryService } from '../inventories/index.js';
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
                "product_name": "tên sản phẩm (Trích xuất CHÍNH XÁC từ khóa người dùng nhập. KHÔNG TỰ Ý THÊM BỚT TỪ. VD: 'Sữa tươi', 'Bia Tiger lon').",
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

          let searchResult =
            await this.inventoryService.getInventoriesByStoreId(storeId, query);

          // 1. Nếu không tìm thấy, thử Fallback Search (Cắt đơn vị lon/thùng)
          if (searchResult.items.length === 0) {
            let fallbackName = params.product_name;

            if (fallbackName.includes('(')) {
              fallbackName = fallbackName.split('(')[0].trim();
            } else {
              fallbackName = fallbackName
                .replace(/^(lon|thùng|chai|hộp|gói|bao|lốc|két)\s+/i, '')
                .trim();
            }

            if (fallbackName && fallbackName !== params.product_name) {
              query.keyword = fallbackName;
              searchResult =
                await this.inventoryService.getInventoriesByStoreId(
                  storeId,
                  query,
                );
            }
          }

          if (searchResult.items.length === 0) {
            return {
              aiIntent: intent,
              botReply: `Dạ em tìm trong kho không thấy sản phẩm nào tên là "${params.product_name}".`,
            };
          }

          // 2. PHẢI CÓ BƯỚC NÀY: So khớp chính xác từ danh sách tìm được
          let targetItem;
          const normalizeName = (str?: string | null) =>
            (str || '').toLowerCase().replace(/[\s()-]/g, '');

          const exactMatch = searchResult.items.find(
            (i) =>
              normalizeName(i.productPackage.displayName) ===
              normalizeName(params.product_name),
          );

          if (exactMatch) {
            targetItem = exactMatch;
          } else if (searchResult.items.length === 1) {
            targetItem = searchResult.items[0];
          } else {
            return {
              aiIntent: 'choose_product',
              botReply: `Hệ thống tìm thấy nhiều sản phẩm liên quan đến "${params.product_name}". Vui lòng chọn sản phẩm bạn muốn xem thông tin:`,
              data: {
                originalIntent: intent,
                items: searchResult.items,
              },
            };
          }

          if (!targetItem) {
            return {
              aiIntent: intent,
              botReply: 'Không tìm thấy sản phẩm phù hợp trong kho.',
            };
          }

          return {
            aiIntent: intent,
            botReply: `Sản phẩm ${targetItem.productPackage.displayName} đang có giá bán ${targetItem.productPackage.sellingPrice} VNĐ. Tồn kho hiện tại: ${targetItem.quantity} ${targetItem.productPackage.unit.name}.`,
            data: targetItem,
          };
        }

        case 'create_export': {
          if (!params.product_name || !params.quantity) {
            return {
              aiIntent: intent,
              botReply:
                'Vui lòng cung cấp tên sản phẩm và số lượng bạn muốn xuất.',
            };
          }

          const query = {
            keyword: params.product_name,
            limit: 5,
            page: 1,
          } as unknown as ListInventoriesQueryDto;

          let searchResult =
            await this.inventoryService.getInventoriesByStoreId(storeId, query);

          if (searchResult.items.length === 0) {
            let fallbackName = params.product_name;

            if (fallbackName.includes('(')) {
              fallbackName = fallbackName.split('(')[0].trim();
            } else {
              fallbackName = fallbackName
                .replace(/^(lon|thùng|chai|hộp|gói|bao|lốc|két)\s+/i, '')
                .trim();
            }

            if (fallbackName && fallbackName !== params.product_name) {
              query.keyword = fallbackName;
              searchResult =
                await this.inventoryService.getInventoriesByStoreId(
                  storeId,
                  query,
                );
            }
          }

          if (searchResult.items.length === 0) {
            return {
              aiIntent: intent,
              botReply: `Dạ em tìm trong kho không thấy sản phẩm nào tên là "${params.product_name}" để xuất.`,
            };
          }

          let targetItem;

          if (searchResult.items.length > 1) {
            const normalizeName = (str?: string | null) =>
              (str || '').toLowerCase().replace(/[\s()-]/g, '');
            const exactMatch = searchResult.items.find(
              (i) =>
                normalizeName(i.productPackage.displayName) ===
                normalizeName(params.product_name),
            );

            if (exactMatch) {
              targetItem = exactMatch;
            } else {
              return {
                aiIntent: 'choose_product',
                botReply: `Hệ thống tìm thấy nhiều sản phẩm liên quan đến "${params.product_name}". Vui lòng chọn sản phẩm chính xác bên dưới:`,
                data: {
                  originalIntent: intent,
                  quantity: params.quantity,
                  items: searchResult.items,
                },
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
              botReply: `⚠️ Sản phẩm "${pkg.displayName}" chưa được cài đặt Giá bán. Vui lòng cập nhật giá trước!`,
            };
          }

          // Kiểm tra tồn kho trước khi xuất
          if (targetItem.quantity < params.quantity) {
            return {
              aiIntent: intent,
              botReply: `⚠️ Rất tiếc, trong kho chỉ còn ${targetItem.quantity} ${pkg.unit.name} của ${pkg.displayName}. Không đủ số lượng để xuất!`,
            };
          }

          const quantityNum = Number(params.quantity);

          const draftPayload = {
            note: 'Xuất kho tự động qua AI Assistant',
            items: [
              {
                productPackageId: targetItem.productPackage.productPackageId,
                quantity: quantityNum, // ÉP KIỂU SỐ TẠI ĐÂY
                unitPrice: sellingPrice,
              },
            ],
          };

          const estimatedTotal = (
            params.quantity * sellingPrice
          ).toLocaleString('vi-VN');

          return {
            aiIntent: 'confirm_export',
            botReply: `Bạn có muốn tạo phiếu **XUẤT KHO** cho **${params.quantity} ${pkg.displayName}** (Tổng giá trị: ${estimatedTotal} VNĐ) không?\n\nVui lòng xác nhận bên dưới.`,
            data: draftPayload,
          };
        }

        case 'create_import': {
          if (!params.product_name || !params.quantity) {
            return {
              aiIntent: intent,
              botReply:
                'Vui lòng cung cấp tên sản phẩm và số lượng bạn muốn nhập.',
            };
          }

          const query = {
            keyword: params.product_name,
            limit: 5,
            page: 1,
          } as unknown as ListInventoriesQueryDto;

          let searchResult =
            await this.inventoryService.getInventoriesByStoreId(storeId, query);

          if (searchResult.items.length === 0) {
            let fallbackName = params.product_name;

            if (fallbackName.includes('(')) {
              fallbackName = fallbackName.split('(')[0].trim();
            } else {
              fallbackName = fallbackName
                .replace(/^(lon|thùng|chai|hộp|gói|bao|lốc|két)\s+/i, '')
                .trim();
            }

            if (fallbackName && fallbackName !== params.product_name) {
              query.keyword = fallbackName;
              searchResult =
                await this.inventoryService.getInventoriesByStoreId(
                  storeId,
                  query,
                );
            }
          }

          if (searchResult.items.length === 0) {
            return {
              aiIntent: intent,
              botReply: `Dạ em tìm trong hệ thống không thấy sản phẩm nào tên là "${params.product_name}" để nhập.`,
            };
          }

          let targetItem;

          if (searchResult.items.length > 1) {
            const normalizeName = (str?: string | null) =>
              (str || '').toLowerCase().replace(/[\s()-]/g, '');
            const exactMatch = searchResult.items.find(
              (i) =>
                normalizeName(i.productPackage.displayName) ===
                normalizeName(params.product_name),
            );

            if (exactMatch) {
              targetItem = exactMatch;
            } else {
              return {
                aiIntent: 'choose_product',
                botReply: `Hệ thống tìm thấy nhiều sản phẩm liên quan đến "${params.product_name}". Vui lòng chọn sản phẩm chính xác bên dưới:`,
                data: {
                  originalIntent: intent,
                  quantity: params.quantity,
                  items: searchResult.items,
                },
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
              botReply: `⚠️ Sản phẩm "${pkg.displayName}" chưa được cài đặt Giá nhập. Vui lòng cập nhật giá trước!`,
            };
          }

          const quantityNum = Number(params.quantity);

          const draftPayload = {
            note: 'Nhập kho tự động qua AI Assistant',
            items: [
              {
                productPackageId: targetItem.productPackage.productPackageId,
                quantity: quantityNum, // ÉP KIỂU SỐ TẠI ĐÂY
                unitPrice: importPrice,
              },
            ],
          };

          const estimatedTotal = (params.quantity * importPrice).toLocaleString(
            'vi-VN',
          );

          return {
            aiIntent: 'confirm_import',
            botReply: `Bạn có muốn tạo phiếu **NHẬP KHO** cho **${params.quantity} ${pkg.displayName}** (Ước tính: ${estimatedTotal} VNĐ) không?\n\nVui lòng xác nhận bên dưới.`,
            data: draftPayload,
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
