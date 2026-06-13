import { z } from 'zod';

export const paramsSchema = z.object({
  categoryId: z.uuid('Invalid categoryId'),
});

export const createCategoryBodySchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, 'Category name is required.')
    .max(100, 'Category name must not exceed 100 characters.'),
  description: z
    .string()
    .trim()
    .max(255, 'Description must not exceed 255 characters.')
    .nullable()
    .optional(),
});

export const updateCategoryBodySchema = z
  .object({
    name: z
      .string()
      .trim()
      .min(1, 'Category name must not be empty.')
      .max(100, 'Category name must not exceed 100 characters.')
      .optional(),
    description: z
      .string()
      .trim()
      .max(255, 'Description must not exceed 255 characters.')
      .nullable()
      .optional(),
  })
  .refine(
    (data) => Object.keys(data).length > 0,
    'Update request body cannot be empty',
  );
