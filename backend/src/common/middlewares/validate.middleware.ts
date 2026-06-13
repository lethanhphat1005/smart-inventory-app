import { z } from 'zod';

import { validateSchema } from '../utils/validate-schema.util.js';

import type { Request, Response, NextFunction } from 'express';

// export const validator = (schema: ZodObject) => {
//   return (req: Request, _res: Response, next: NextFunction): void => {
//     try {
//       // Đóng gói request thành object khớp với cấu trúc Zod Schema của dự án
//       validateSchema(schema, {
//         body: req.body,
//         query: req.query,
//         params: req.params,
//       });

//       next(); // Nếu hợp lệ, cho luồng đi tiếp vào Controller
//     } catch (error) {
//       next(error); // Chuyển CustomError về cho Error Handler tổng xử lý
//     }
//   };
// };

export const validator = <T>(
  schema: z.ZodSchema<T>,
  source: 'body' | 'query' | 'params',
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
