import { z } from 'zod';

import { validateSchema } from '../../common/utils/index.js';

import type { NextFunction, Request, Response } from 'express';

const productParamsSchema = z.object({
  productId: z.uuid('Invalid productId'),
});

const productPackageParamsSchema = z.object({
  productPackageId: z.uuid('Invalid productPackageId'),
});

const createProductPackageBodySchema = z
  .object({
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
        .min(1, 'Variant cannot be empty')
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
  })
  .refine(
    (data) => Object.keys(data).length > 0,
    'Request body cannot be empty',
  );

const updateProductPackageBodySchema = z
  .object({
    unitId: z.uuid('Invalid unitId'),
    variant: z
      .string()
      .trim()
      .min(1, 'Variant cannot be empty')
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

export const validateGetPackagesByStore = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  _res.locals.validatedQuery = validateSchema(
    listPackageQuerySchema,
    req.query,
  );
  next();
};

export const validateCreateProductPackage = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productParamsSchema, req.params);
  req.body = validateSchema(createProductPackageBodySchema, req.body);
  next();
};

export const validateGetProductPackagesByProductId = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productParamsSchema, req.params);
  next();
};

export const validateGetProductPackageById = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productPackageParamsSchema, req.params);
  next();
};

export const validateUpdateProductPackage = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productPackageParamsSchema, req.params);
  req.body = validateSchema(updateProductPackageBodySchema, req.body);
  next();
};

export const validateDeleteProductPackage = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(productPackageParamsSchema, req.params);
  next();
};
