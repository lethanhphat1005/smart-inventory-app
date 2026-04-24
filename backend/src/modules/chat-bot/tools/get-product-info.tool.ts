import type { ChatToolDefinition } from './tool.type.js';

export const GET_PRODUCT_INFO = {
  type: 'function',
  function: {
    name: 'get_product_info',
    description:
      'Hỏi thông tin, giá bán, số lượng tồn kho của một sản phẩm cụ thể.',
    parameters: {
      type: 'object',
      properties: {
        product_name: { type: 'string', description: 'Tên sản phẩm cần tìm' },
      },
      required: ['product_name'],
    },
  },
} as ChatToolDefinition;
