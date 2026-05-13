import type { ChatToolDefinition } from './tool.type.js';

export const CREATE_EXPORT_TRANSACTION = {
  type: 'function',
  function: {
    name: 'create_export',
    description:
      'MANDATORY: Gọi tool này để tạo phiếu XUẤT KHO hoặc BÁN HÀNG. ' +
      'LUẬT QUAN TRỌNG: ' +
      '1. Luôn trả về tham số "products" là một MẢNG (Array). ' +
      '2. CHỈ trích xuất các sản phẩm MỚI được yêu cầu trong câu nói HIỆN TẠI. TUYỆT ĐỐI KHÔNG lặp lại các sản phẩm đã được xử lý ở các lượt chat trước. ' +
      '3. Nếu người dùng dùng đại từ (nó, cái đó, loại này...), BẠN PHẢI xem lịch sử chat để nội suy ra tên sản phẩm thực tế.',
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
                description:
                  'Tên sản phẩm đầy đủ cần xuất (ví dụ: Coca Cola 500ml).',
              },
              quantity: {
                type: 'number',
                description:
                  'Số lượng cần xuất. CHỈ điền con số nếu người dùng ĐÃ NÊU RÕ. NẾU NGƯỜI DÙNG KHÔNG CUNG CẤP SỐ LƯỢNG, TUYỆT ĐỐI BỎ TRỐNG (KHÔNG tự đoán, KHÔNG mặc định là 1).',
              },
            },
            required: ['product_name'],
          },
          description: 'Danh sách các sản phẩm cần xuất',
        },
      },
      required: ['products'],
    },
  },
} as ChatToolDefinition;
