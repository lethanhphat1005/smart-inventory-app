import type { OpenAI } from 'openai';

export const CHATBOT_TOOLS: OpenAI.Chat.Completions.ChatCompletionTool[] = [
  {
    type: 'function',
    function: {
      name: 'get_low_stock',
      description:
        'Xem danh sách các sản phẩm sắp hết hàng hoặc đã hết hàng trong kho cần nhập thêm.',
      parameters: { type: 'object', properties: {} },
    },
  },
  {
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
  },
  {
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
  },
  {
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
  },
];
