import { describe, expect, it, vi } from 'vitest';

import { CurrencyController } from '../../../../src/modules/currencies/currency.controller.js';

const prismaMock = vi.hoisted(() => ({
  prisma: {
    currency: {},
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMock.prisma,
}));

describe('currency module wiring', () => {
  it('exports a currency controller instance', async () => {
    const module =
      await import('../../../../src/modules/currencies/currency.module.js');

    expect(module.currencyController).toBeInstanceOf(CurrencyController);
  });
});
