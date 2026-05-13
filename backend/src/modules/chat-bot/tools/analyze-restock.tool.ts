import type { ChatToolDefinition } from './tool.type.js';

export const ANALYZE_RESTOCK = {
  type: 'function',
  function: {
    name: 'analyze_restock',
    description:
      'MANDATORY: Gọi tool này khi người dùng yêu cầu "tư vấn nhập hàng", "mua kèm", "bán chạy", HOẶC trong tiếng Anh: "restock suggestions", "what to import", "frequently bought together", "buy along with", "cross-sell". ' +
      'LUẬT QUAN TRỌNG: BẮT BUỘC dùng tool này cho mọi câu hỏi về phân tích mua kèm (bought together) hoặc tư vấn nhập hàng.',
    parameters: {
      type: 'object',
      properties: {
        product_name: {
          type: ['string', 'null'],
          description:
            'Tên sản phẩm (nếu có) mà người dùng muốn phân tích mua kèm (cross-sell). Bỏ trống hoặc null nếu người dùng yêu cầu dự báo/tư vấn nhập hàng chung toàn cửa hàng.',
        },
      },
      required: [],
    },
  },
} as ChatToolDefinition;
