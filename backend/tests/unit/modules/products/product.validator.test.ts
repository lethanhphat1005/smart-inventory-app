import { describe, expect, it } from 'vitest';

import {
  createProductBodySchema,
  listProductsQuerySchema,
  paramsSchema,
  updateProductBodySchema,
} from '../../../../src/modules/products/product.validator.js';

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('product validators', () => {
  describe('paramsSchema', () => {
    it('accepts a valid UUID productId', () => {
      const result = paramsSchema.parse({ productId: uuid });

      expect(result.productId).toBe(uuid);
    });

    it('rejects invalid productId format', () => {
      expect(() => paramsSchema.parse({ productId: 'not-a-uuid' })).toThrow(
        'Invalid productId',
      );
    });
  });

  describe('createProductBodySchema', () => {
    it('accepts valid product creation payload and trims strings', () => {
      const result = createProductBodySchema.parse({
        name: ' Milk ',
        imageUrl: ' products/milk.png ',
        brand: ' Dairy Co ',
        categoryId: uuid,
      });

      expect(result).toEqual({
        name: 'Milk',
        imageUrl: 'products/milk.png',
        brand: 'Dairy Co',
        categoryId: uuid,
      });
    });

    it('accepts nullable optional imageUrl and brand', () => {
      const result = createProductBodySchema.parse({
        name: 'Milk',
        imageUrl: null,
        brand: null,
        categoryId: uuid,
      });

      expect(result.imageUrl).toBeNull();
      expect(result.brand).toBeNull();
    });

    it('rejects missing required name', () => {
      expect(() =>
        createProductBodySchema.parse({
          categoryId: uuid,
        }),
      ).toThrow();
    });

    it('rejects an empty product name after trimming', () => {
      expect(() =>
        createProductBodySchema.parse({
          name: '   ',
          categoryId: uuid,
        }),
      ).toThrow('Product name cannot be empty');
    });

    it('rejects names longer than 255 characters', () => {
      expect(() =>
        createProductBodySchema.parse({
          name: 'a'.repeat(256),
          categoryId: uuid,
        }),
      ).toThrow('Product name cannot be exeeded 255 characters');
    });

    it('rejects invalid categoryId format', () => {
      expect(() =>
        createProductBodySchema.parse({
          name: 'Milk',
          categoryId: 'category-1',
        }),
      ).toThrow('Invalid categoryId');
    });

    it('rejects empty brand after trimming', () => {
      expect(() =>
        createProductBodySchema.parse({
          name: 'Milk',
          brand: '   ',
          categoryId: uuid,
        }),
      ).toThrow('Invalid brand value');
    });
  });

  describe('updateProductBodySchema', () => {
    it('accepts a valid partial update payload', () => {
      const result = updateProductBodySchema.parse({
        name: ' Updated Milk ',
        brand: null,
      });

      expect(result).toEqual({
        name: 'Updated Milk',
        brand: null,
      });
    });

    it('rejects an empty update payload', () => {
      expect(() => updateProductBodySchema.parse({})).toThrow(
        'Request body cannot be empty',
      );
    });

    it('rejects empty updated name after trimming', () => {
      expect(() =>
        updateProductBodySchema.parse({
          name: '   ',
        }),
      ).toThrow('Product name cannot be empty');
    });

    it('rejects invalid optional categoryId', () => {
      expect(() =>
        updateProductBodySchema.parse({
          categoryId: 'category-1',
        }),
      ).toThrow('Invalid categoryId');
    });
  });

  describe('listProductsQuerySchema', () => {
    it('coerces pagination and applies defaults', () => {
      const result = listProductsQuerySchema.parse({
        page: '2',
        limit: '25',
      });

      expect(result).toEqual({
        page: 2,
        limit: 25,
        sortBy: 'name',
        sortOrder: 'desc',
      });
    });

    it('accepts filters and trims brand', () => {
      const result = listProductsQuerySchema.parse({
        categoryId: uuid,
        brand: ' Dairy Co ',
        sortBy: 'createdAt',
        sortOrder: 'asc',
      });

      expect(result.categoryId).toBe(uuid);
      expect(result.brand).toBe('Dairy Co');
      expect(result.sortBy).toBe('createdAt');
      expect(result.sortOrder).toBe('asc');
    });

    it('rejects limits above 100', () => {
      expect(() => listProductsQuerySchema.parse({ limit: '101' })).toThrow();
    });

    it('rejects invalid sort fields', () => {
      expect(() =>
        listProductsQuerySchema.parse({ sortBy: 'activeStatus' }),
      ).toThrow();
    });
  });
});
