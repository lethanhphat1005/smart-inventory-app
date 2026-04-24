import type { ChatToolDefinition } from './tool.type.js';

export const CREATE_IMPORT_TRANSACTION = {
  type: 'function',
  function: {
    name: 'create_import',
    description:
      'Tạo phiếu nhập hàng vào kho. Luôn sử dụng mảng products ngay cả khi chỉ có 1 sản phẩm.',
    parameters: {
      type: 'object',
      properties: {
        products: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              product_name: { type: 'string' },
              quantity: { type: 'number' },
            },
            required: ['product_name', 'quantity'],
          },
        },
      },
      required: ['products'],
    },
  },
} as ChatToolDefinition;
