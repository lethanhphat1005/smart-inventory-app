import { beforeEach, describe, expect, it, vi } from 'vitest';

import { SmartDecisionService } from '../../../../src/modules/alerts/services/smart-decision.service.js';

const eventMocks = vi.hoisted(() => ({
  emit: vi.fn(),
}));

const prismaMocks = vi.hoisted(() => ({
  prisma: {
    inventory: {
      findMany: vi.fn(),
    },
    transactionDetail: {
      aggregate: vi.fn(),
    },
    store: {
      findMany: vi.fn(),
    },
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMocks.prisma,
}));

vi.mock('../../../../src/common/events/event-bus.js', async (importOriginal) => {
  const actual =
    await importOriginal<
      typeof import('../../../../src/common/events/event-bus.js')
    >();

  return {
    ...actual,
    eventBus: eventMocks,
  };
});

const createInventory = (overrides: Record<string, unknown> = {}) => ({
  inventoryId: 'inventory-1',
  productPackageId: 'package-1',
  quantity: 4,
  productPackage: {
    productId: 'product-1',
    displayName: 'Milk 1L',
    product: {
      productId: 'product-1',
      category: { name: 'Food' },
    },
  },
  ...overrides,
});

describe('SmartDecisionService', () => {
  let service: SmartDecisionService;

  beforeEach(() => {
    vi.clearAllMocks();
    service = new SmartDecisionService();
  });

  it('returns store-scoped reorder suggestions when sales velocity exceeds stock coverage', async () => {
    prismaMocks.prisma.inventory.findMany.mockResolvedValue([
      createInventory({ quantity: 1 }),
    ]);
    prismaMocks.prisma.transactionDetail.aggregate.mockResolvedValue({
      _sum: { quantity: 90 },
    });

    const result = await service.getStoreReorderSuggestions('store-1');

    expect(prismaMocks.prisma.inventory.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          activeStatus: 'active',
          productPackage: {
            product: { storeId: 'store-1' },
          },
        },
      }),
    );
    expect(prismaMocks.prisma.transactionDetail.aggregate).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          productPackageId: 'package-1',
          transaction: expect.objectContaining({
            type: 'export',
            status: 'completed',
            createdAt: { gte: expect.any(Date) },
          }),
        }),
      }),
    );
    expect(result).toEqual([
      {
        productId: 'product-1',
        productName: 'Milk 1L',
        currentStock: 1,
        suggestedQuantity: 50,
        suggestedThreshold: 9,
        reason: 'Based on an average sales velocity of 3.0 units/day.',
      },
    ]);
  });

  it('skips packages with no recent export sales', async () => {
    prismaMocks.prisma.inventory.findMany.mockResolvedValue([
      createInventory({ quantity: 0 }),
    ]);
    prismaMocks.prisma.transactionDetail.aggregate.mockResolvedValue({
      _sum: { quantity: null },
    });

    await expect(
      service.getStoreReorderSuggestions('store-1'),
    ).resolves.toEqual([]);
  });

  it('uses category-specific lead times and default product names', async () => {
    prismaMocks.prisma.inventory.findMany.mockResolvedValue([
      createInventory({
        inventoryId: 'inventory-electronic',
        productPackageId: 'package-electronic',
        quantity: 50,
        productPackage: {
          productId: 'product-electronic',
          displayName: null,
          product: {
            productId: 'product-electronic',
            category: { name: 'Electronic Accessories' },
          },
        },
      }),
      createInventory({
        inventoryId: 'inventory-digital',
        productPackageId: 'package-digital',
        quantity: 0,
        productPackage: {
          productId: 'product-digital',
          displayName: null,
          product: {
            productId: 'product-digital',
            category: { name: 'Digital License' },
          },
        },
      }),
    ]);
    prismaMocks.prisma.transactionDetail.aggregate.mockResolvedValue({
      _sum: { quantity: 30 },
    });

    const result = await service.getStoreReorderSuggestions('store-1');

    expect(result).toEqual([
      {
        productId: 'product-digital',
        productName: 'Product',
        currentStock: 0,
        suggestedQuantity: 14,
        suggestedThreshold: 0,
        reason: 'Based on an average sales velocity of 1.0 units/day.',
      },
    ]);
    expect(prismaMocks.prisma.transactionDetail.aggregate).toHaveBeenCalledTimes(
      2,
    );
  });

  it('applies apparel and furniture category rules when calculating suggestions', async () => {
    prismaMocks.prisma.inventory.findMany.mockResolvedValue([
      createInventory({
        inventoryId: 'inventory-apparel',
        productPackageId: 'package-apparel',
        quantity: 2,
        productPackage: {
          productId: 'product-apparel',
          displayName: 'Shirt',
          product: {
            productId: 'product-apparel',
            category: { name: 'Apparel' },
          },
        },
      }),
      createInventory({
        inventoryId: 'inventory-furniture',
        productPackageId: 'package-furniture',
        quantity: 2,
        productPackage: {
          productId: 'product-furniture',
          displayName: 'Chair',
          product: {
            productId: 'product-furniture',
            category: { name: 'Furniture' },
          },
        },
      }),
    ]);
    prismaMocks.prisma.transactionDetail.aggregate.mockResolvedValue({
      _sum: { quantity: 30 },
    });

    const result = await service.getStoreReorderSuggestions('store-1');

    expect(result).toEqual([
      expect.objectContaining({
        productId: 'product-apparel',
        suggestedThreshold: 6,
        suggestedQuantity: 18,
      }),
      expect.objectContaining({
        productId: 'product-furniture',
        suggestedThreshold: 14,
        suggestedQuantity: 26,
      }),
    ]);
  });

  it('emits batch reorder suggestion events only for stores with suggestions', async () => {
    prismaMocks.prisma.store.findMany.mockResolvedValue([
      { storeId: 'store-1' },
      { storeId: 'store-2' },
    ]);
    prismaMocks.prisma.inventory.findMany
      .mockResolvedValueOnce([createInventory({ quantity: 1 })])
      .mockResolvedValueOnce([createInventory({ quantity: 100 })]);
    prismaMocks.prisma.transactionDetail.aggregate.mockResolvedValue({
      _sum: { quantity: 90 },
    });

    await service.generateReorderSuggestions();

    expect(prismaMocks.prisma.store.findMany).toHaveBeenCalledWith({
      where: { activeStatus: 'active' },
      select: { storeId: true },
    });
    expect(eventMocks.emit).toHaveBeenCalledTimes(1);
    expect(eventMocks.emit).toHaveBeenCalledWith('BATCH_REORDER_SUGGESTION', {
      storeId: 'store-1',
      suggestions: [expect.objectContaining({ productId: 'product-1' })],
    });
  });

  it('propagates database failures during suggestion generation', async () => {
    prismaMocks.prisma.inventory.findMany.mockRejectedValue(
      new Error('database unavailable'),
    );

    await expect(
      service.getStoreReorderSuggestions('store-1'),
    ).rejects.toThrow('database unavailable');
  });
});
