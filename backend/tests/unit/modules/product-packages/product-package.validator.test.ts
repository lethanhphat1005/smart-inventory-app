import { describe, expect, it } from 'vitest';

import {
  createProductPackageBodySchema,
  listPackageQuerySchema,
  productPackageParamsSchema,
  productParamsSchema,
  updateProductPackageBodySchema,
} from '../../../../src/modules/product-packages/product-package.validator.js';

const uuid = '550e8400-e29b-41d4-a716-446655440000';

describe('product package validators', () => {
  it('accepts valid product and package params', () => {
    expect(productParamsSchema.parse({ productId: uuid })).toEqual({
      productId: uuid,
    });
    expect(
      productPackageParamsSchema.parse({ productPackageId: uuid }),
    ).toEqual({ productPackageId: uuid });
  });

  it('rejects invalid params', () => {
    expect(() =>
      productParamsSchema.parse({ productId: 'not-a-uuid' }),
    ).toThrow('Invalid productId');
    expect(() =>
      productPackageParamsSchema.parse({ productPackageId: 'not-a-uuid' }),
    ).toThrow('Invalid productPackageId');
  });

  it('accepts valid create payloads, trims variant, and coerces prices', () => {
    const result = createProductPackageBodySchema.parse([
      {
        package: {
          unitId: uuid,
          importPrice: '1000',
          sellingPrice: '1500',
          variant: ' bottle ',
        },
        inventory: {
          quantity: 3,
          reorderThreshold: 1,
          lastCount: null,
        },
      },
    ]);

    expect(result).toEqual([
      {
        package: {
          unitId: uuid,
          importPrice: 1000,
          sellingPrice: 1500,
          variant: 'bottle',
        },
        inventory: {
          quantity: 3,
          reorderThreshold: 1,
          lastCount: null,
        },
      },
    ]);
  });

  it('rejects empty create arrays and invalid nested values', () => {
    expect(() => createProductPackageBodySchema.parse([])).toThrow(
      'At least one package is required',
    );
    expect(() =>
      createProductPackageBodySchema.parse([
        {
          package: {
            unitId: 'not-a-uuid',
            importPrice: -1,
          },
          inventory: {
            quantity: -1,
          },
        },
      ]),
    ).toThrow();
  });

  it('accepts valid update payloads with null optional values', () => {
    const result = updateProductPackageBodySchema.parse({
      unitId: uuid,
      variant: null,
      importPrice: null,
      sellingPrice: '2000',
    });

    expect(result).toEqual({
      unitId: uuid,
      variant: null,
      importPrice: null,
      sellingPrice: 2000,
    });
  });

  it('rejects empty update payloads because unitId is required by the schema', () => {
    expect(() => updateProductPackageBodySchema.parse({})).toThrow(
      'Invalid unitId',
    );
  });

  it('rejects invalid update values', () => {
    expect(() =>
      updateProductPackageBodySchema.parse({ unitId: 'not-a-uuid' }),
    ).toThrow('Invalid unitId');
    expect(() =>
      updateProductPackageBodySchema.parse({ unitId: uuid, sellingPrice: -1 }),
    ).toThrow('Selling price must be greater than or equal to 0');
  });

  it('coerces list query defaults and accepts filters', () => {
    const result = listPackageQuerySchema.parse({
      page: '2',
      limit: '25',
      sortBy: 'updatedAt',
      sortOrder: 'desc',
      categoryId: uuid,
    });

    expect(result).toEqual({
      page: 2,
      limit: 25,
      sortBy: 'updatedAt',
      sortOrder: 'desc',
      categoryId: uuid,
    });
  });

  it('rejects invalid list query values', () => {
    expect(() => listPackageQuerySchema.parse({ limit: '101' })).toThrow();
    expect(() =>
      listPackageQuerySchema.parse({ sortBy: 'sellingPrice' }),
    ).toThrow();
    expect(() =>
      listPackageQuerySchema.parse({ categoryId: 'not-a-uuid' }),
    ).toThrow('Invalid categoryId');
  });
});
