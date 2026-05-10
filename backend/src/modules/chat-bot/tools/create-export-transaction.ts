import type { ChatToolDefinition } from './tool.type.js';

export const CREATE_EXPORT_TRANSACTION = {
  type: 'function',
  function: {
    name: 'create_export',
    description:
      'MANDATORY: Gọi tool này để tạo phiếu xuất kho hoặc bán hàng. Bạn PHẢI trích xuất TÊN SẢN PHẨM và SỐ LƯỢNG từ câu nói của người dùng. ' +
      'Luôn luôn trả về tham số "products" dưới dạng MẢNG (Array) chứa các object, tuyệt đối không trả về object đơn lẻ. ' +
      'Nếu người dùng không nói rõ số lượng, mặc định quantity là 1. ' +
      'Nếu người dùng dùng đại từ (nó, cái đó, sản phẩm vừa rồi...), hãy xem lịch sử chat để tự nội suy ra tên sản phẩm thực tế.',
    parameters: {
      type: 'object',
      properties: {
        products: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              product_name: {
                type: 'string',
                description: 'Tên sản phẩm đầy đủ (ví dụ: Coca Cola 500ml)',
              },
              quantity: {
                type: 'number',
                description:
                  'Số lượng sản phẩm cần xuất (chỉ ghi số nguyên, mặc định là 1)',
              },
            },
            required: ['product_name', 'quantity'],
          },
          description: 'Danh sách các sản phẩm cần xuất',
        },
      },
      required: ['products'],
    },
  },
} as ChatToolDefinition;
