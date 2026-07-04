import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CurrencyService } from '../../../../src/modules/currencies/currency.service.js';

import type { CurrencyDto } from '../../../../src/modules/currencies/currency.dto.js';

type MockCurrencyRepository = {
  findAll: ReturnType<typeof vi.fn>;
};

const currencyFixture = (
  overrides: Partial<CurrencyDto> = {},
): CurrencyDto => ({
  code: 'USD',
  symbol: '$',
  name: 'US Dollar',
  ...overrides,
});

const createMockCurrencyRepository = (): MockCurrencyRepository => ({
  findAll: vi.fn(),
});

describe('CurrencyService', () => {
  let currencyRepository: MockCurrencyRepository;
  let currencyService: CurrencyService;

  beforeEach(() => {
    currencyRepository = createMockCurrencyRepository();
    currencyService = new CurrencyService(currencyRepository as never);
  });

  it('getAllCurrencies delegates to the currency repository', async () => {
    const currencies = [
      currencyFixture(),
      currencyFixture({
        code: 'VND',
        symbol: 'VND',
        name: 'Vietnamese Dong',
      }),
    ];

    currencyRepository.findAll.mockResolvedValue(currencies);

    const result = await currencyService.getAllCurrencies();

    expect(result).toEqual(currencies);
    expect(currencyRepository.findAll).toHaveBeenCalledTimes(1);
    expect(currencyRepository.findAll).toHaveBeenCalledWith();
  });

  it('getAllCurrencies returns an empty list when no currencies exist', async () => {
    currencyRepository.findAll.mockResolvedValue([]);

    const result = await currencyService.getAllCurrencies();

    expect(result).toEqual([]);
    expect(currencyRepository.findAll).toHaveBeenCalledTimes(1);
  });

  it('getAllCurrencies propagates repository failures', async () => {
    const error = new Error('database unavailable');

    currencyRepository.findAll.mockRejectedValue(error);

    await expect(currencyService.getAllCurrencies()).rejects.toThrow(error);
  });
});
