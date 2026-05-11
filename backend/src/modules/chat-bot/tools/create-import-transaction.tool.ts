import type { ChatToolDefinition } from './tool.type.js';

export const CREATE_IMPORT_TRANSACTION = {
  type: 'function',
  function: {
    name: 'create_import',
    description:
      'MANDATORY: Gọi tool này để tạo phiếu nhập hàng vào kho. Bạn PHẢI trích xuất TÊN SẢN PHẨM và SỐ LƯỢNG từ câu nói của người dùng. ' +
      'Luôn luôn trả về tham số "products" dưới dạng MẢNG (Array) chứa các object, tuyệt đối không trả về object đơn lẻ. ' +
      'Nếu người dùng không nói rõ số lượng, mặc định quantity là 1. ' +
      'Nếu người dùng dùng đại từ (nó, cái đó, sản phẩm vừa rồi...), hãy xem lịch sử chat để tự nội suy ra tên sản phẩm thực tế.' +
      'CHÚ Ý QUAN TRỌNG: CHỈ trích xuất các sản phẩm MỚI được yêu cầu trong câu nói HIỆN TẠI. TUYỆT ĐỐI KHÔNG lặp lại các sản phẩm đã được thêm vào ở các lượt chat trước đó.',
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
                description: 'Tên sản phẩm đầy đủ cần nhập',
              },
              quantity: {
                type: 'number',
                description:
                  'Số lượng sản phẩm cần nhập (chỉ ghi số nguyên, mặc định là 1)',
              },
            },
            required: ['product_name', 'quantity'],
          },
          description: 'Danh sách các sản phẩm cần nhập',
        },
      },
      required: ['products'],
    },
  },
} as ChatToolDefinition;
