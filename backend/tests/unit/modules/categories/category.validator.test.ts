import { describe, expect, it } from 'vitest';

import {
  createCategoryBodySchema,
  paramsSchema,
  updateCategoryBodySchema,
} from '../../../../src/modules/categories/category.validator.js';

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('category validators', () => {
  describe('paramsSchema', () => {
    it('accepts a valid UUID categoryId', () => {
      const result = paramsSchema.parse({ categoryId: uuid });

      expect(result.categoryId).toBe(uuid);
    });

    it('rejects invalid categoryId format', () => {
      expect(() => paramsSchema.parse({ categoryId: 'category-1' })).toThrow(
        'Invalid categoryId',
      );
    });
  });

  describe('createCategoryBodySchema', () => {
    it('accepts a valid payload and trims strings', () => {
      const result = createCategoryBodySchema.parse({
        name: ' Dairy ',
        description: ' Milk products ',
      });

      expect(result).toEqual({
        name: 'Dairy',
        description: 'Milk products',
      });
    });

    it('accepts nullable and omitted description', () => {
      expect(
        createCategoryBodySchema.parse({
          name: 'Dairy',
          description: null,
        }).description,
      ).toBeNull();

      expect(createCategoryBodySchema.parse({ name: 'Dairy' })).toEqual({
        name: 'Dairy',
      });
    });

    it('rejects missing name', () => {
      expect(() => createCategoryBodySchema.parse({})).toThrow();
    });

    it('rejects empty name after trimming', () => {
      expect(() => createCategoryBodySchema.parse({ name: '   ' })).toThrow(
        'Category name is required.',
      );
    });

    it('rejects names longer than 100 characters', () => {
      expect(() =>
        createCategoryBodySchema.parse({ name: 'a'.repeat(101) }),
      ).toThrow('Category name must not exceed 100 characters.');
    });

    it('rejects descriptions longer than 255 characters', () => {
      expect(() =>
        createCategoryBodySchema.parse({
          name: 'Dairy',
          description: 'a'.repeat(256),
        }),
      ).toThrow('Description must not exceed 255 characters.');
    });
  });

  describe('updateCategoryBodySchema', () => {
    it('accepts a partial update and trims strings', () => {
      const result = updateCategoryBodySchema.parse({
        name: ' Frozen ',
        description: ' Frozen goods ',
      });

      expect(result).toEqual({
        name: 'Frozen',
        description: 'Frozen goods',
      });
    });

    it('accepts nullable optional description', () => {
      const result = updateCategoryBodySchema.parse({
        description: null,
      });

      expect(result.description).toBeNull();
    });

    it('rejects an empty update body', () => {
      expect(() => updateCategoryBodySchema.parse({})).toThrow(
        'Update request body cannot be empty',
      );
    });

    it('rejects empty updated name after trimming', () => {
      expect(() =>
        updateCategoryBodySchema.parse({
          name: '   ',
        }),
      ).toThrow('Category name must not be empty.');
    });
  });
});
