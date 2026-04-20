import { z } from 'zod';

import { validateSchema } from '../../common/utils/index.js';

import type { NextFunction, Request, Response } from 'express';

const paramsSchema = z.object({
  storeId: z.uuid('Invalid storeId'),
});

const createStoreBodySchema = z.object({
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
});

const updateStoreBodySchema = z
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
  })
  .refine(
    (data) => Object.keys(data).length > 0,
    'Request body cannot be empty',
  );

export const validateCreateStore = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(createStoreBodySchema, req.body);
  next();
};

export const validateUpdateStore = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(updateStoreBodySchema, req.body);
  next();
};

export const validateGetStoreById = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  next();
};

export const validateDeleteStore = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.params = validateSchema(paramsSchema, req.params);
  next();
};

const joinStoreBodySchema = z.object({
  inviteCode: z.string().trim().min(1, 'Invite code is required'),
});

export const validateJoinStore = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  req.body = validateSchema(joinStoreBodySchema, req.body);
  next();
};
