import { z } from 'zod';

export const chatPayloadSchema = z.object({
  body: z.object({
    message: z
      .string()
      .trim()
      .min(1, 'Tin nhắn không được để trống')
      .max(100, 'Tin nhắn quá dài, vui lòng nhập tối đa 100 ký tự'),
  }),
});

export const confirmActionSchema = z.object({
  body: z.object({
    draftActionId: z.string().trim().min(1, 'Mã giao dịch nháp là bắt buộc'),
    isConfirmed: z.boolean(),
  }),
});
