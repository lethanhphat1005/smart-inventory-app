import { z } from 'zod';

export const paramsSchema = z.object({
  storeId: z.uuid('Invalid storeId'),
});

export const createStoreBodySchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, 'Store name is required')
    .max(100, 'Store name must not exceed 100 characters'),

  address: z
    .string()
    .trim()
    .max(255, 'Address must not exceed 255 characters')
    .nullable()
    .optional(),

  timezone: z
    .string()
    .trim()
    .max(100, 'Timezone must not exceed 100 characters')
    .nullable()
    .optional(),

  currencyCode: z
    .string()
    .trim()
    .min(1, 'Currency code is required')
    .max(100, 'Currency code must not exceed 100 characters'),
});

export const updateStoreBodySchema = z
  .object({
    name: z
      .string()
      .trim()
      .min(1, 'Store name must not be empty')
      .max(100, 'Store name must not exceed 100 characters')
      .optional(),

    address: z
      .string()
      .trim()
      .max(255, 'Address must not exceed 255 characters')
      .nullable()
      .optional(),

    timezone: z
      .string()
      .trim()
      .max(100, 'Timezone must not exceed 100 characters')
      .nullable()
      .optional(),

    currencyCode: z
      .string()
      .trim()
      .max(100, 'Currency code must not exceed 100 characters')
      .nullable()
      .optional(),
  })
  .refine(
    (data) => Object.keys(data).length > 0,
    'Update request body cannot be empty',
  );

export const joinStoreBodySchema = z.object({
  inviteCode: z.string().trim().min(1, 'Invite code is required'),
});

export const hardDeleteStoreBodySchema = z.object({
  storeName: z
    .string()
    .trim()
    .min(1, 'Store name is required for confirmation'),
});
