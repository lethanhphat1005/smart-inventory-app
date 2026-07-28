import { z } from 'zod';

import { validateSchema } from '../utils/validate-schema.util.js';

import type { Request, Response, NextFunction } from 'express';

export const validator = <T>(
  schema: z.ZodSchema<T>,
  source: 'body' | 'params',
) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      req[source] = validateSchema(
        schema,
        req[source],
      ) as (typeof req)[typeof source];

      next();
    } catch (error) {
      next(error);
    }
  };
};

// dùng cho validator query
export const validatorToLocals = <T>(
  schema: z.ZodSchema<T>,
  source: 'body' | 'query' | 'params',
  localKey: string = 'validatedQuery',
) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      res.locals[localKey] = validateSchema(schema, req[source]);

      next();
    } catch (error) {
      next(error);
    }
  };
};
