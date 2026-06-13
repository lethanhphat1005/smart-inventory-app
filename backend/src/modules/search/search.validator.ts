import { z } from 'zod';

import { validateSchema } from '../../common/utils/index.js';

import type { NextFunction, Request, Response } from 'express';

export const searchByKeywordQuerySchema = z.object({
  keyword: z
    .string()
    .trim()
    .min(1, 'Keyword is required')
    .max(100, 'Keyword must be at most 100 characters'),
  page: z.coerce.number().int().min(1).optional().default(1),
  limit: z.coerce.number().int().min(1).max(100).optional().default(50),
});

export const searchByPrefixQuerySchema = z.object({
  prefix: z
    .string()
    .trim()
    .min(1, 'Prefix is required')
    .max(100, 'Prefix must be at most 100 characters'),
  limit: z.coerce.number().int().min(1).max(20).optional(),
});

export const validateGetProductsByKeyword = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  _res.locals.validatedQuery = validateSchema(
    searchByKeywordQuerySchema,
    req.query,
  );
  next();
};

export const validateGetProductsByPrefix = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  _res.locals.validatedQuery = validateSchema(
    searchByPrefixQuerySchema,
    req.query,
  );
  next();
};
