import { z } from 'zod';

// export const removeStoreMemberSchema = z.object({
//   params: z.object({
//     userId: z.string().uuid(),
//   }),
// });

// export const updateStoreMemberRoleSchema = z.object({
//   params: z.object({
//     userId: z.string().uuid(),
//   }),
//   body: z.object({
//     role: z.enum(['manager', 'staff']),
//   }),
// });

// export const getStoreMembersSchema = z.object({
//   params: z.object({
//     storeId: z.string().uuid('Invalid Store ID format'),
//   }),
//   query: z.object({
//     page: z.coerce.number().int().min(1).default(1),
//     limit: z.coerce.number().int().min(1).max(100).default(10),
//     search: z.string().trim().optional(),
//   }),
// });

export const paramsSchema = z.object({
  userId: z.string().uuid(),
});

export const updateStoreMemberRoleBodySchema = z.object({
  role: z.enum(['manager', 'staff']),
});

export const getStoreMembersQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  search: z.string().trim().optional(),
});
