import type { ChatToolDefinition } from './tool.type.js';

export const GET_PRODUCT_INFO = {
  type: 'function',
  function: {
    name: 'get_product_info',
    description:
      'Gọi tool này khi người dùng muốn biết thông tin chi tiết, giá bán, hoặc số lượng tồn kho của MỘT sản phẩm cụ thể. ' +
      'LUẬT QUAN TRỌNG: Nếu người dùng dùng đại từ (nó, cái đó, loại này, thùng đó...), TUYỆT ĐỐI KHÔNG truyền đại từ vào tên sản phẩm. BẠN PHẢI xem lại lịch sử trò chuyện ở các câu trước để tìm và trích xuất tên sản phẩm chính xác.',
    parameters: {
      type: 'object',
      properties: {
        product_name: {
          type: 'string',
          description:
            'Tên sản phẩm cụ thể cần tra cứu (đã được giải quyết đại từ nếu có).',
        },
      },
      required: ['product_name'],
    },
  },
} as ChatToolDefinition;
