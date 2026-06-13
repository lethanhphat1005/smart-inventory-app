export class CustomError extends Error {
  public readonly status: number;
  public readonly code?: string;
  public readonly details?: unknown;
  public readonly isOperational: boolean;

  constructor(options: {
    message: string;
    status: number;
    code?: string;
    details?: Record<string, unknown>;
    isOperational?: boolean; // true nếu lỗi thuộc business logic
  }) {
    super(options.message);

    this.name = 'CustomError';
    this.status = options.status;
    this.isOperational = options.isOperational ?? true;

    if (options?.code !== undefined) {
      this.code = options.code;
    }

    if (options?.details !== undefined) {
      this.details = options.details;
    }

    Error.captureStackTrace(this, this.constructor);
  }
}
