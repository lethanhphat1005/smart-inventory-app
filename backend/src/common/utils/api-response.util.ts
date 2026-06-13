import type { ApiErrorResponse, ApiSuccessResponse } from '../types/index.js';
import type { Response } from 'express';

export const sendResponse = {
  success: <T>(
    res: Response,
    data: T,
    options?: {
      status?: number;
      message?: string;
      meta?: Record<string, unknown>;
    },
  ) => {
    const response: ApiSuccessResponse<T> = {
      success: true,
      data,
    };

    if (options?.message !== undefined) {
      response.message = options.message;
    }

    if (options?.meta !== undefined) {
      response.meta = options.meta;
    }

    return res.status(options?.status ?? 200).json(response);
  },

  error: <T = unknown>(
    res: Response,
    status: number,
    message: string,
    options?: {
      code?: string;
      errors?: Record<string, unknown>;
      data?: T;
    },
  ) => {
    const response: ApiErrorResponse = {
      success: false,
      status,
      message,
    };

    if (options?.code !== undefined) {
      response.code = options.code;
    }

    if (options?.errors !== undefined) {
      response.errors = options.errors;
    }

    if (options?.data !== undefined) {
      response.data = options.data;
    }

    return res.status(status).json(response);
  },
};
