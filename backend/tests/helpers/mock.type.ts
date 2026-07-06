import { vi } from 'vitest';

import type {
  ApiResponse,
  CurrentUser,
  StoreContext,
} from '../../src/common/types/index.js';
import type { Request, Response } from 'express';

export type MockResponse<T> = Response<ApiResponse<T>> & {
  status: ReturnType<typeof vi.fn>;
  json: ReturnType<typeof vi.fn>;
};

export type MockRequest = Partial<Request> & {
  user?: CurrentUser;
  storeContext?: StoreContext;
};
