import { z } from 'zod';

export const chatPayloadSchema = z.object({
  body: z.object({
    message: z
      .string()
      .trim()
      .min(1, 'Message cannot be empty')
      .max(100, 'Message cannot exceed 100 characters'),
  }),
});

export const confirmActionSchema = z.object({
  body: z.object({
    draftActionId: z.string().trim().min(1, 'Draft action ID is required'),
    isConfirmed: z.boolean(),
  }),
});
