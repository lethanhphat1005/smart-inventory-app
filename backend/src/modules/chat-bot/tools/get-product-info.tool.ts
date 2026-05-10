import type { ChatToolDefinition } from './tool.type.js';

export const GET_PRODUCT_INFO = {
  type: 'function',
  function: {
    name: 'get_product_info',
    description:
      'Hỏi thông tin, giá bán, số lượng tồn kho của một sản phẩm cụ thể. ' +
      'Nếu người dùng dùng đại từ (nó, cái đó, loại này...), HÃY XEM LẠI lịch sử trò chuyện ở các câu trước để tìm tên sản phẩm chính xác.',
    parameters: {
      type: 'object',
      properties: {
        product_name: {
          type: 'string',
          description: 'Tên sản phẩm cần tìm kiếm',
        },
      },
      required: ['product_name'],
    },
  },
} as ChatToolDefinition;
