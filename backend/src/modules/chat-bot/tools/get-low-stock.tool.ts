import type { ChatToolDefinition } from './tool.type.js';

export const GET_LOW_STOCK = {
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
} as ChatToolDefinition;
