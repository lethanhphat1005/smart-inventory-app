import type { ChatToolDefinition } from './tool.type.js';

export const QUERY_AUDIT_LOGS = {
  type: 'function',
  function: {
    name: 'query_audit_logs',
    description:
      'Gọi tool này khi người dùng hỏi về LỊCH SỬ THAO TÁC, QUẢN LÝ NHÂN SỰ, hoặc muốn biết AI ĐÃ LÀM GÌ (ví dụ: "Ai đã xóa sản phẩm?", "Ai tạo phiếu xuất?", "Lịch sử cập nhật...").',
    parameters: {
      type: 'object',
      properties: {
        action_type: {
          type: 'string',
          enum: ['create', 'update', 'delete', 'all'],
          description:
            'Loại thao tác. Nếu hỏi "xóa" -> delete, "tạo/lập/thêm" -> create, "sửa/cập nhật" -> update. Mặc định là all.',
        },
        keyword: {
          type: 'string',
          description:
            'Tên sản phẩm, mã phiếu, hoặc thực thể liên quan (ví dụ: "Nam Ngư", "phiếu 123"). Bỏ trống nếu không nhắc đến thực thể cụ thể.',
        },
        time_period: {
          type: 'string',
          description:
            'Khoảng thời gian người dùng nhắc đến (ví dụ: "hôm qua", "hôm nay", "tuần trước", "tháng này"). Nếu không nhắc đến, hãy bỏ trống.',
        },
      },
      required: ['action_type'],
    },
  },
} as ChatToolDefinition;
