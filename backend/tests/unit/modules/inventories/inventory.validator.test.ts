import { describe, expect, it, vi } from 'vitest';

import {
  batchAdjustInventoryBodySchema,
  createInventoryBodySchema,
  listInventoriesQuerySchema,
  paramsSchema,
  updateInventoryBodySchema,
  validateGetInventories,
} from '../../../../src/modules/inventories/validator/inventory.validator.js';

import type { NextFunction, Request, Response } from 'express';

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('inventory validators', () => {
  describe('paramsSchema', () => {
    it('accepts a valid productPackageId UUID', () => {
      expect(paramsSchema.parse({ productPackageId: uuid })).toEqual({
        productPackageId: uuid,
      });
    });

    it('rejects invalid productPackageId format', () => {
      expect(() =>
        paramsSchema.parse({ productPackageId: 'package-1' }),
      ).toThrow('Invalid productPackageId');
    });
  });

  describe('listInventoriesQuerySchema', () => {
    it('coerces pagination and applies defaults', () => {
      expect(listInventoriesQuerySchema.parse({ page: '2', limit: '25' }))
        .toEqual({
          page: 2,
          limit: 25,
          sortBy: 'updatedAt',
          sortOrder: 'desc',
        });
    });

    it('accepts filters and trims keyword', () => {
      const result = listInventoriesQuerySchema.parse({
        keyword: '  milk  ',
        categoryId: uuid,
        inventoryStatus: 'lowStock',
        sortBy: 'quantity',
        sortOrder: 'asc',
      });

      expect(result).toMatchObject({
        keyword: 'milk',
        categoryId: uuid,
        inventoryStatus: 'lowStock',
        sortBy: 'quantity',
        sortOrder: 'asc',
      });
    });

    it('rejects invalid pagination, sort, and inventory status values', () => {
      expect(() => listInventoriesQuerySchema.parse({ page: '0' })).toThrow();
      expect(() => listInventoriesQuerySchema.parse({ limit: '101' })).toThrow();
      expect(() =>
        listInventoriesQuerySchema.parse({ sortBy: 'createdAt' }),
      ).toThrow();
      expect(() =>
        listInventoriesQuerySchema.parse({ inventoryStatus: 'negative' }),
      ).toThrow();
    });
  });

  describe('updateInventoryBodySchema', () => {
    it('accepts reorderThreshold updates including null', () => {
      expect(updateInventoryBodySchema.parse({ reorderThreshold: 5 })).toEqual({
        reorderThreshold: 5,
      });
      expect(updateInventoryBodySchema.parse({ reorderThreshold: null }))
        .toEqual({ reorderThreshold: null });
    });

    it('rejects empty payloads and negative thresholds', () => {
      expect(() => updateInventoryBodySchema.parse({})).toThrow(
        'Request body cannot be empty',
      );
      expect(() =>
        updateInventoryBodySchema.parse({ reorderThreshold: -1 }),
      ).toThrow();
    });
  });

  describe('createInventoryBodySchema', () => {
    it('accepts valid payloads and defaults quantity to zero', () => {
      expect(
        createInventoryBodySchema.parse({
          productPackageId: uuid,
          reorderThreshold: null,
        }),
      ).toEqual({
        productPackageId: uuid,
        quantity: 0,
        reorderThreshold: null,
      });
    });

    it('rejects negative quantities and thresholds', () => {
      expect(() =>
        createInventoryBodySchema.parse({
          productPackageId: uuid,
          quantity: -1,
        }),
      ).toThrow();
      expect(() =>
        createInventoryBodySchema.parse({
          productPackageId: uuid,
          reorderThreshold: -1,
        }),
      ).toThrow();
    });
  });

  describe('batchAdjustInventoryBodySchema', () => {
    it('accepts valid batch adjustment items with nullable reason and note', () => {
      expect(
        batchAdjustInventoryBodySchema.parse({
          items: [
            {
              productPackageId: uuid,
              type: 'increase',
              quantity: 3,
              reason: null,
              note: 'cycle count',
            },
          ],
        }),
      ).toEqual({
        items: [
          {
            productPackageId: uuid,
            type: 'increase',
            quantity: 3,
            reason: null,
            note: 'cycle count',
          },
        ],
      });
    });

    it('rejects empty batches, invalid UUIDs, invalid types, and negative quantities', () => {
      expect(() => batchAdjustInventoryBodySchema.parse({ items: [] }))
        .toThrow('Danh sách điều chỉnh phải có ít nhất 1 sản phẩm');
      expect(() =>
        batchAdjustInventoryBodySchema.parse({
          items: [{ productPackageId: 'package-1', type: 'set', quantity: 1 }],
        }),
      ).toThrow('ID sản phẩm phải là định dạng UUID');
      expect(() =>
        batchAdjustInventoryBodySchema.parse({
          items: [{ productPackageId: uuid, type: 'remove', quantity: 1 }],
        }),
      ).toThrow();
      expect(() =>
        batchAdjustInventoryBodySchema.parse({
          items: [{ productPackageId: uuid, type: 'decrease', quantity: -1 }],
        }),
      ).toThrow('Số lượng không được nhỏ hơn 0');
    });
  });

  describe('validateGetInventories', () => {
    it('stores validated query on res.locals and calls next', () => {
      const req = {
        query: { page: '2', limit: '20', keyword: ' milk ' },
      } as unknown as Request;
      const res = { locals: {} } as Response;
      const next = vi.fn() as NextFunction;

      validateGetInventories(req, res, next);

      expect(res.locals.validatedQuery).toEqual({
        page: 2,
        limit: 20,
        sortBy: 'updatedAt',
        sortOrder: 'desc',
        keyword: 'milk',
      });
      expect(next).toHaveBeenCalledTimes(1);
    });
  });
});
