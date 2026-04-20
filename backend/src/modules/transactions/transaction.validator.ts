import { z } from 'zod';

import { validateSchema } from '../../common/utils/index.js';

import type { NextFunction, Request, Response } from 'express';

const paramsSchema = z.object({
  transactionId: z.uuid('Invalid transactionId'),
});

export const listTransactionsQuerySchema = z
  .object({
    page: z.coerce.number().int().min(1).optional().default(1),
    limit: z.coerce.number().int().min(1).max(100).optional().default(50),
    sortBy: z.enum(['createdAt', 'totalPrice']).optional().default('createdAt'),
    sortOrder: z.enum(['asc', 'desc']).optional().default('desc'),
    type: z.enum(['import', 'export']).optional(),
    userId: z.uuid().trim().optional(),
    startDate: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/)
      .optional(),
    endDate: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/)
      .optional(),
  })
  .refine(
    (data) => {
      if (!data.startDate || !data.endDate) {
        return true;
      }

      return data.startDate <= data.endDate;
    },
    {
      message: 'startDate must be less than or equal to endDate',
      path: ['startDate'],
    },
  );

const createTransactionBodySchema = z
  .object({
    note: z.string().trim().max(1000).nullable().optional(),
    items: z
      .array(
        z.object({
          productPackageId: z.uuid('Invalid productPackageId'),
          quantity: z.coerce
            .number()
            .int()
            .positive('Quantity must be greater than 0'),
          unitPrice: z.coerce
            .number()
            .min(0, 'Unit price must be greater than or equal to 0'),
        }),
      )
      .min(1, 'Items cannot be empty'),
  })
  .superRefine((data, ctx) => {
    const productPackageIds = new Set<string>();

    data.items.forEach((item, index) => {
      if (productPackageIds.has(item.productPackageId)) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: 'Duplicate productPackageId in transaction items',
          path: ['items', index, 'productPackageId'],
        });
      }

      productPackageIds.add(item.productPackageId);
    });
  });

export const validateGetTransactions = (
  req: Request,
  res: Response,
  next: NextFunction,
): void => {
  res.locals.validatedQuery = validateSchema(
    listTransactionsQuerySchema,
    req.query,
  );
  next();
};

export const validateGetTransactionById = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  next();
};

export const validateCreateImportTransaction = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(createTransactionBodySchema, req.body);
  next();
};

export const validateCreateExportTransaction = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(createTransactionBodySchema, req.body);
  next();
};
