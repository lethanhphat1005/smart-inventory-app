import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CurrencyRepository } from '../../../../src/modules/currencies/currency.repository.js';

const createMockDb = () => ({
  currency: {
    findMany: vi.fn(),
  },
});

describe('CurrencyRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let currencyRepository: CurrencyRepository;

  beforeEach(() => {
    db = createMockDb();
    currencyRepository = new CurrencyRepository(db as never);
  });

  it('findAll selects public currency fields only', async () => {
    const currencies = [
      {
        code: 'USD',
        symbol: '$',
        name: 'US Dollar',
      },
    ];

    db.currency.findMany.mockResolvedValue(currencies);

    const result = await currencyRepository.findAll();

    expect(result).toEqual(currencies);
    expect(db.currency.findMany).toHaveBeenCalledWith({
      select: {
        code: true,
        symbol: true,
        name: true,
      },
    });
  });

  it('findAll returns an empty list when the database has no currencies', async () => {
    db.currency.findMany.mockResolvedValue([]);

    const result = await currencyRepository.findAll();

    expect(result).toEqual([]);
  });

  it('findAll propagates database failures', async () => {
    const error = new Error('database unavailable');

    db.currency.findMany.mockRejectedValue(error);

    await expect(currencyRepository.findAll()).rejects.toThrow(error);
  });
});
