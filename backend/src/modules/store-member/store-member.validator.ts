import { z } from 'zod';

export const paramsSchema = z.object({
  userId: z.string().uuid(),
});

export const updateStoreMemberRoleBodySchema = z.object({
  role: z.enum(['manager', 'staff']),
});
