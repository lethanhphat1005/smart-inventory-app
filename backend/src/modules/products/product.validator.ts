import { z } from 'zod';

export const paramsSchema = z.object({
  productId: z.uuid('Invalid productId'),
});

export const createProductBodySchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, 'Product name cannot be empty')
    .max(255, 'Product name cannot be exeeded 255 characters'),
  imageUrl: z.string().trim().nullable().optional(),
  brand: z
    .string()
    .trim()
    .min(1, 'Invalid brand value')
    .max(255, 'Brand cannot be exeeded 255 characters')
    .nullable()
    .optional(),
  categoryId: z.uuid('Invalid categoryId'),
});

export const updateProductBodySchema = z
  .object({
    name: z
      .string()
      .trim()
      .min(1, 'Product name cannot be empty')
      .max(255, 'Product name cannot be exeeded 255 characters')
      .optional(),
    imageUrl: z.string().trim().nullable().optional(),
    brand: z
      .string()
      .trim()
      .min(1, 'Invalid brand value')
      .max(255, 'Brand cannot be exeeded 255 characters')
      .nullable()
      .optional(),
    categoryId: z.uuid('Invalid categoryId').optional(),
  })
  .refine(
    (data) => Object.keys(data).length > 0,
    'Request body cannot be empty',
  );

export const listProductsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(50),
  sortBy: z.enum(['name', 'createdAt', 'updatedAt']).optional().default('name'),
  sortOrder: z.enum(['asc', 'desc']).optional().default('desc'),
  categoryId: z.string().uuid('Invalid categoryId').optional(),
  brand: z.string().trim().min(1).max(255).optional(),
});
