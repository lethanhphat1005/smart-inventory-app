import { vi } from 'vitest';

import type { MockRequest, MockResponse } from './index.js';
import type { Request } from 'express';

export const createRequest = (overrides: MockRequest): Request => {
  return overrides as Request;
};

export const createResponse = <T>(
  locals: Record<string, unknown> = {},
): MockResponse<T> => {
  const response = {
    status: vi.fn(),
    json: vi.fn(),
    locals,
  } as unknown as MockResponse<T>;

  response.status.mockReturnValue(response);
  response.json.mockReturnValue(response);

  return response;
};
