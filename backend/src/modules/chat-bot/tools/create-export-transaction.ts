import type { ChatToolDefinition } from './tool.type.js';

export const CREATE_EXPORT_TRANSACTION = {
  type: 'function',
  function: {
    name: 'create_export',
    description:
      'Tạo phiếu xuất kho hoặc bán hàng. Luôn sử dụng mảng products ngay cả khi chỉ có 1 sản phẩm.',
    parameters: {
      type: 'object',
      properties: {
        products: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              product_name: { type: 'string', description: 'Tên sản phẩm' },
              quantity: { type: 'number', description: 'Số lượng' },
            },
            required: ['product_name', 'quantity'],
          },
          description: 'Danh sách sản phẩm cần xuất',
        },
      },
      required: ['products'],
    },
  },
} as ChatToolDefinition;
