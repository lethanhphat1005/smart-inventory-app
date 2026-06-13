import { z } from 'zod';

// export const registerTokenSchema = z.object({
//   body: z.object({
//     token: z.string().trim().min(1, 'FCM Token is required'),
//   }),
// });

// export const removeTokenSchema = z.object({
//   body: z.object({
//     token: z.string().trim().min(1, 'FCM Token is required'),
//   }),
// });

export const registerTokenBodySchema = z.object({
  token: z.string().trim().min(1, 'FCM Token is required'),
});

export const removeTokenBodySchema = z.object({
  token: z.string().trim().min(1, 'FCM Token is required'),
});
