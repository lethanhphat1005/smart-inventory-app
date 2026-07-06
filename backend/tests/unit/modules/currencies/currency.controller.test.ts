import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CurrencyController } from '../../../../src/modules/currencies/currency.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type { CurrencyDto } from '../../../../src/modules/currencies/currency.dto.js';

vi.mock('../../../../src/modules/currencies/currency.service.js', () => ({
  CurrencyService: class MockCurrencyService {},
}));

type MockCurrencyService = {
  getAllCurrencies: ReturnType<typeof vi.fn>;
};

const currencyFixture = (
  overrides: Partial<CurrencyDto> = {},
): CurrencyDto => ({
  code: 'USD',
  symbol: '$',
  name: 'US Dollar',
  ...overrides,
});

const createMockCurrencyService = (): MockCurrencyService => ({
  getAllCurrencies: vi.fn(),
});

describe('CurrencyController', () => {
  let currencyService: MockCurrencyService;
  let currencyController: CurrencyController;

  beforeEach(() => {
    currencyService = createMockCurrencyService();
    currencyController = new CurrencyController(currencyService as never);
  });

  it('returns all currencies', async () => {
    const currencies = [
      currencyFixture(),
      currencyFixture({
        code: 'VND',
        symbol: 'VND',
        name: 'Vietnamese Dong',
      }),
    ];
    const req = createRequest({});
    const res = createResponse<CurrencyDto[]>();

    currencyService.getAllCurrencies.mockResolvedValue(currencies);

    await currencyController.getCurrencies(req, res);

    expect(currencyService.getAllCurrencies).toHaveBeenCalledTimes(1);
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: currencies,
    });
  });

  it('returns an empty currency list', async () => {
    const req = createRequest({});
    const res = createResponse<CurrencyDto[]>();

    currencyService.getAllCurrencies.mockResolvedValue([]);

    await currencyController.getCurrencies(req, res);

    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: [],
    });
  });

  it('propagates service failures to the async route wrapper', async () => {
    const error = new Error('service unavailable');
    const req = createRequest({});
    const res = createResponse<CurrencyDto[]>();

    currencyService.getAllCurrencies.mockRejectedValue(error);

    await expect(currencyController.getCurrencies(req, res)).rejects.toThrow(
      error,
    );
    expect(res.status).not.toHaveBeenCalled();
    expect(res.json).not.toHaveBeenCalled();
  });
});
