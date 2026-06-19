import { z } from 'zod';

export const productParamsSchema = z.object({
  productId: z.uuid('Invalid productId'),
});

export const productPackageParamsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
});

export const createProductPackageBodySchema = z
  .array(
    z.object({
      package: z.object({
        unitId: z.uuid('Invalid unitId'),
        importPrice: z.coerce
          .number()
          .min(0, 'Import price must be greater than or equal to 0')
          .nullable()
          .optional(),
        sellingPrice: z.coerce
          .number()
          .min(0, 'Selling price must be greater than or equal to 0')
          .nullable()
          .optional(),
        variant: z
          .string()
          .trim()
          .max(255, 'Variant cannot exceed 255 characters')
          .optional()
          .default(''),
      }),
      inventory: z.object({
        quantity: z
          .number()
          .int()
          .min(0, 'Import price must be greater than or equal to 0')
          .default(0),
        reorderThreshold: z
          .number()
          .int()
          .min(0, 'Reorder threshold must be greater than or equal to 0')
          .nullable()
          .optional(),
        lastCount: z.number().int().min(0).nullable().optional(),
      }),
    }),
  )
  .min(1, 'At least one package is required');

export const updateProductPackageBodySchema = z
  .object({
    unitId: z.uuid('Invalid unitId'),
    variant: z
      .string()
      .trim()
      .max(255, 'Variant cannot exceed 255 characters')
      .nullable()
      .optional(),
    importPrice: z.coerce
      .number()
      .min(0, 'Import price must be greater than or equal to 0')
      .nullable()
      .optional(),
    sellingPrice: z.coerce
      .number()
      .min(0, 'Selling price must be greater than or equal to 0')
      .nullable()
      .optional(),
  })
  .refine(
    (data) => Object.keys(data).length > 0,
    'Request body cannot be empty',
  );

export const listPackageQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(50),
  sortBy: z
    .enum(['displayName', 'createdAt', 'updatedAt'])
    .optional()
    .default('displayName'),
  sortOrder: z.enum(['asc', 'desc']).optional().default('asc'),
  categoryId: z.string().uuid('Invalid categoryId').optional(),
});
