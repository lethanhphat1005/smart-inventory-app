import type { ChatToolDefinition } from './tool.type.js';

export const ANALYZE_RESTOCK = {
  type: 'function',
  function: {
    name: 'analyze_restock',
    description:
      'Gọi tool này khi người dùng yêu cầu tư vấn nhập hàng, dự báo tồn kho, hoặc hỏi "Nên nhập thêm gì?", "Có sản phẩm nào bán chạy cần nhập không?", hoặc "Khách mua [Tên sản phẩm] thường mua kèm gì?".',
    parameters: {
      type: 'object',
      properties: {
        product_name: {
          type: 'string',
          description:
            'Tên sản phẩm (nếu có) mà người dùng muốn phân tích mua kèm. Bỏ trống nếu người dùng chỉ hỏi gợi ý nhập hàng chung chung toàn cửa hàng.',
        },
      },
      required: [],
    },
  },
} as ChatToolDefinition;
