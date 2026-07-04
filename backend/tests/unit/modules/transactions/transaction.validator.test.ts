import { describe, expect, it } from 'vitest';

import {
  createTransactionBodySchema,
  listTransactionsQuerySchema,
  paramsSchema,
} from '../../../../src/modules/transactions/transaction.validator.js';

const uuid = '550e8400-e29b-41d4-a716-446655440000';
const secondUuid = '660e8400-e29b-41d4-a716-446655440000';

describe('transaction validators', () => {
  describe('paramsSchema', () => {
    it('accepts a valid UUID transactionId', () => {
      const result = paramsSchema.parse({ transactionId: uuid });

      expect(result.transactionId).toBe(uuid);
    });

    it('rejects invalid transactionId format', () => {
      expect(() =>
        paramsSchema.parse({ transactionId: 'transaction-1' }),
      ).toThrow('Invalid transactionId');
    });
  });

  describe('listTransactionsQuerySchema', () => {
    it('coerces pagination and applies defaults', () => {
      const result = listTransactionsQuerySchema.parse({
        page: '2',
        limit: '25',
      });

      expect(result).toEqual({
        page: 2,
        limit: 25,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      });
    });

    it('accepts filters, sorting, and date range', () => {
      const result = listTransactionsQuerySchema.parse({
        sortBy: 'totalPrice',
        sortOrder: 'asc',
        type: 'export',
        userId: uuid,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      });

      expect(result).toMatchObject({
        sortBy: 'totalPrice',
        sortOrder: 'asc',
        type: 'export',
        userId: uuid,
        startDate: '2026-01-01',
        endDate: '2026-01-31',
      });
    });

    it('rejects limits above 100', () => {
      expect(() => listTransactionsQuerySchema.parse({ limit: '101' })).toThrow();
    });

    it('rejects invalid transaction type', () => {
      expect(() =>
        listTransactionsQuerySchema.parse({ type: 'transfer' }),
      ).toThrow();
    });

    it('rejects an end date before the start date', () => {
      expect(() =>
        listTransactionsQuerySchema.parse({
          startDate: '2026-02-01',
          endDate: '2026-01-01',
        }),
      ).toThrow('startDate must be less than or equal to endDate');
    });
  });

  describe('createTransactionBodySchema', () => {
    it('accepts a valid transaction payload and trims note', () => {
      const result = createTransactionBodySchema.parse({
        note: ' Supplier delivery ',
        items: [
          {
            productPackageId: uuid,
            quantity: '3',
            unitPrice: '12000',
          },
        ],
      });

      expect(result).toEqual({
        note: 'Supplier delivery',
        items: [
          {
            productPackageId: uuid,
            quantity: 3,
            unitPrice: 12000,
          },
        ],
      });
    });

    it('accepts nullable optional note', () => {
      const result = createTransactionBodySchema.parse({
        note: null,
        items: [{ productPackageId: uuid, quantity: 1, unitPrice: 0 }],
      });

      expect(result.note).toBeNull();
      expect(result.items[0]?.unitPrice).toBe(0);
    });

    it('rejects empty items', () => {
      expect(() =>
        createTransactionBodySchema.parse({
          items: [],
        }),
      ).toThrow('Items cannot be empty');
    });

    it('rejects duplicate productPackageId values', () => {
      expect(() =>
        createTransactionBodySchema.parse({
          items: [
            { productPackageId: uuid, quantity: 1, unitPrice: 1000 },
            { productPackageId: uuid, quantity: 2, unitPrice: 2000 },
          ],
        }),
      ).toThrow('Duplicate productPackageId in transaction items');
    });

    it('rejects non-positive quantities', () => {
      expect(() =>
        createTransactionBodySchema.parse({
          items: [{ productPackageId: uuid, quantity: 0, unitPrice: 1000 }],
        }),
      ).toThrow('Quantity must be greater than 0');
    });

    it('rejects invalid package ids', () => {
      expect(() =>
        createTransactionBodySchema.parse({
          items: [
            { productPackageId: 'package-1', quantity: 1, unitPrice: 1000 },
          ],
        }),
      ).toThrow('Invalid productPackageId');
    });

    it('accepts multiple distinct package items', () => {
      const result = createTransactionBodySchema.parse({
        items: [
          { productPackageId: uuid, quantity: 1, unitPrice: 1000 },
          { productPackageId: secondUuid, quantity: 2, unitPrice: 2000 },
        ],
      });

      expect(result.items).toHaveLength(2);
    });
  });
});
