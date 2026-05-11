import type { ChatToolDefinition } from './tool.type.js';

export const GET_LOW_STOCK = {
  type: 'function',
  function: {
    name: 'get_low_stock',
    description:
      'Gọi tool này khi người dùng hỏi về: danh sách sản phẩm sắp hết hàng, cảnh báo tồn kho, hàng đã hết, hoặc cần nhập thêm hàng gì. Không yêu cầu tham số.',
    parameters: {
      type: 'object',
      properties: {},
    },
  },
} as ChatToolDefinition;
