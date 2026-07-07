import { beforeEach, describe, expect, it, vi } from 'vitest';

import { SmartAlertService } from '../../../../src/modules/alerts/services/smart-alert.service.js';

const eventMocks = vi.hoisted(() => ({
  on: vi.fn(),
}));

const messageMocks = vi.hoisted(() => ({
  getRandomMessage: vi.fn((templates: string[]) => templates[0] ?? ''),
}));

const prismaMocks = vi.hoisted(() => ({
  prisma: {
    inventory: {
      findUnique: vi.fn(),
      findMany: vi.fn(),
      fields: {
        reorderThreshold: 'reorderThreshold',
      },
    },
    storeMember: {
      findMany: vi.fn(),
    },
    transaction: {
      aggregate: vi.fn(),
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

vi.mock('../../../../src/modules/alerts/utils/message.util.js', () => ({
  getRandomMessage: messageMocks.getRandomMessage,
}));

const createNotificationService = () => ({
  createAndSendNotification: vi.fn(),
});

const createInventory = (overrides: Record<string, unknown> = {}) => ({
  inventoryId: 'inventory-1',
  quantity: 3,
  reorderThreshold: 5,
  productPackage: {
    productId: 'product-1',
    displayName: 'Milk 1L',
    product: {
      productId: 'product-1',
      storeId: 'store-1',
    },
  },
  ...overrides,
});

describe('SmartAlertService', () => {
  let notificationService: ReturnType<typeof createNotificationService>;
  let service: SmartAlertService;

  beforeEach(() => {
    vi.clearAllMocks();
    notificationService = createNotificationService();
    service = new SmartAlertService(notificationService as never);
    prismaMocks.prisma.storeMember.findMany.mockResolvedValue([
      { userId: 'owner-1' },
      { userId: 'manager-1' },
    ]);
  });

  it('registers listeners for all alert event sources', () => {
    expect(eventMocks.on).toHaveBeenCalledWith(
      'BATCH_INVENTORY_CHANGED',
      expect.any(Function),
    );
    expect(eventMocks.on).toHaveBeenCalledWith(
      'INVENTORY_DISCREPANCY',
      expect.any(Function),
    );
    expect(eventMocks.on).toHaveBeenCalledWith(
      'LARGE_ORDER_CREATED',
      expect.any(Function),
    );
    expect(eventMocks.on).toHaveBeenCalledWith(
      'ROLE_UPDATED',
      expect.any(Function),
    );
    expect(eventMocks.on).toHaveBeenCalledWith(
      'BATCH_REORDER_SUGGESTION',
      expect.any(Function),
    );
  });

  it('sends low-stock notifications only when inventory crosses below threshold', async () => {
    prismaMocks.prisma.inventory.findUnique.mockResolvedValue(createInventory());

    await service.checkLowStockRule('inventory-1', undefined, 4, 8);

    expect(prismaMocks.prisma.storeMember.findMany).toHaveBeenCalledWith({
      where: {
        storeId: 'store-1',
        role: { in: ['owner', 'manager'] },
        activeStatus: 'active',
      },
      select: { userId: true },
    });
    expect(notificationService.createAndSendNotification).toHaveBeenCalledTimes(
      2,
    );
    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '⚠️ Low Stock Alert',
      'Milk 1L is running low! Only 4 left in stock.',
      'LOW_STOCK',
      'product-1',
    );
  });

  it('uses provided store id and fallback product name for low-stock cron notifications', async () => {
    prismaMocks.prisma.inventory.findUnique.mockResolvedValue(
      createInventory({
        quantity: 0,
        reorderThreshold: null,
        productPackage: {
          productId: 'product-1',
          displayName: null,
          product: { productId: 'product-1', storeId: undefined },
        },
      }),
    );

    await service.checkLowStockRule('inventory-1', 'store-from-context');

    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-from-context',
      '⚠️ Low Stock Alert',
      'An unnamed product is running low! Only 0 left in stock.',
      'LOW_STOCK',
      'product-1',
    );
  });

  it('does not send low-stock notifications when store or target members are missing', async () => {
    prismaMocks.prisma.inventory.findUnique
      .mockResolvedValueOnce(
        createInventory({
          productPackage: {
            productId: 'product-1',
            displayName: 'Milk 1L',
            product: { productId: 'product-1', storeId: undefined },
          },
        }),
      )
      .mockResolvedValueOnce(createInventory());
    prismaMocks.prisma.storeMember.findMany.mockResolvedValueOnce([]);

    await service.checkLowStockRule('inventory-no-store');
    await service.checkLowStockRule('inventory-no-members');

    expect(notificationService.createAndSendNotification).not.toHaveBeenCalled();
  });

  it('does not send low-stock notifications for missing inventory, safe stock, or repeated low state', async () => {
    prismaMocks.prisma.inventory.findUnique
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce(createInventory({ quantity: 6 }))
      .mockResolvedValueOnce(createInventory());

    await service.checkLowStockRule('missing');
    await service.checkLowStockRule('safe');
    await service.checkLowStockRule('still-low', undefined, 3, 4);

    expect(notificationService.createAndSendNotification).not.toHaveBeenCalled();
  });

  it('scans all stores and sends one batch warning per store with low stock', async () => {
    prismaMocks.prisma.inventory.findMany.mockResolvedValue([
      createInventory({ inventoryId: 'inventory-1' }),
      createInventory({
        inventoryId: 'inventory-2',
        productPackage: {
          productId: 'product-2',
          displayName: 'Tea Box',
          product: { productId: 'product-2', storeId: 'store-1' },
        },
      }),
      createInventory({
        inventoryId: 'inventory-3',
        productPackage: {
          productId: 'product-3',
          displayName: 'Coffee',
          product: { productId: 'product-3', storeId: undefined },
        },
      }),
    ]);

    await service.scanAllStoresForLowStock();

    expect(prismaMocks.prisma.inventory.findMany).toHaveBeenCalledWith({
      where: {
        reorderThreshold: { not: null },
        quantity: { lte: 'reorderThreshold' },
        activeStatus: 'active',
      },
      include: {
        productPackage: { include: { product: true } },
      },
    });
    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '⚠️ Inventory Warning',
      expect.stringContaining('Milk 1L and Tea Box'),
      'BATCH_LOW_STOCK',
      undefined,
    );
  });

  it('uses single and multi-item batch templates during scheduled low-stock scans', async () => {
    prismaMocks.prisma.inventory.findMany
      .mockResolvedValueOnce([createInventory()])
      .mockResolvedValueOnce([
        createInventory(),
        createInventory({
          inventoryId: 'inventory-2',
          productPackage: {
            productId: 'product-2',
            displayName: 'Tea Box',
            product: { productId: 'product-2', storeId: 'store-1' },
          },
        }),
        createInventory({
          inventoryId: 'inventory-3',
          productPackage: {
            productId: 'product-3',
            displayName: 'Coffee',
            product: { productId: 'product-3', storeId: 'store-1' },
          },
        }),
      ]);

    await service.scanAllStoresForLowStock();
    await service.scanAllStoresForLowStock();

    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '⚠️ Inventory Warning',
      'The item Milk 1L is critically low. Please restock soon!',
      'BATCH_LOW_STOCK',
      undefined,
    );
    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '⚠️ Inventory Warning',
      '3 items need restocking (e.g., Milk 1L, Tea Box, ...).',
      'BATCH_LOW_STOCK',
      undefined,
    );
  });

  it('does not scan members when scheduled low-stock scan finds no inventory', async () => {
    prismaMocks.prisma.inventory.findMany.mockResolvedValue([]);

    await service.scanAllStoresForLowStock();

    expect(prismaMocks.prisma.storeMember.findMany).not.toHaveBeenCalled();
  });

  it('sends single-item batch low-stock alerts and skips items that did not cross threshold', async () => {
    prismaMocks.prisma.inventory.findMany.mockResolvedValue([
      createInventory(),
      createInventory({
        inventoryId: 'inventory-safe',
        reorderThreshold: 5,
        productPackage: {
          productId: 'product-safe',
          displayName: 'Tea',
          product: { productId: 'product-safe', storeId: 'store-1' },
        },
      }),
    ]);

    await service.checkBatchLowStockRule({
      storeId: 'store-1',
      items: [
        { inventoryId: 'inventory-1', oldQuantity: 8, newQuantity: 4 },
        { inventoryId: 'inventory-safe', oldQuantity: 8, newQuantity: 6 },
      ],
    });

    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '⚠️ Low Stock Alert',
      'Milk 1L is running low (4 units left). Please restock soon!',
      'LOW_STOCK',
      'product-1',
    );
  });

  it('returns from batch low-stock checks when no fetched item crossed threshold', async () => {
    prismaMocks.prisma.inventory.findMany.mockResolvedValue([
      createInventory({
        inventoryId: 'inventory-unmatched',
      }),
    ]);

    await service.checkBatchLowStockRule({
      storeId: 'store-1',
      items: [{ inventoryId: 'inventory-1', oldQuantity: 8, newQuantity: 4 }],
    });

    expect(notificationService.createAndSendNotification).not.toHaveBeenCalled();
  });

  it('sends discrepancy notifications only for abnormal adjustment differences', async () => {
    await service.checkDiscrepancyRule({
      storeId: 'store-1',
      adjustmentId: 'adjustment-1',
      items: [
        { productName: 'Milk', systemQuantity: 100, actualQuantity: 94 },
        { productName: 'Tea', systemQuantity: 20, actualQuantity: 19 },
        { productName: 'Coffee', systemQuantity: 0, actualQuantity: 3 },
      ],
    });

    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '⚠️ Inventory Discrepancy Alert',
      'Detected abnormal discrepancies for Milk and Coffee. Please review the adjustment record.',
      'INVENTORY_DISCREPANCY',
      'adjustment-1',
    );
  });

  it('formats single discrepancy notifications as loss or surplus', async () => {
    await service.checkDiscrepancyRule({
      storeId: 'store-1',
      adjustmentId: 'adjustment-loss',
      items: [{ productName: 'Milk', systemQuantity: 20, actualQuantity: 10 }],
    });
    await service.checkDiscrepancyRule({
      storeId: 'store-1',
      adjustmentId: 'adjustment-surplus',
      items: [{ productName: 'Tea', systemQuantity: 0, actualQuantity: 3 }],
    });

    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '⚠️ Inventory Discrepancy Alert',
      'Detected a loss of 10 units for Milk during the latest inventory adjustment.',
      'INVENTORY_DISCREPANCY',
      'adjustment-loss',
    );
    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '⚠️ Inventory Discrepancy Alert',
      'Detected a surplus of 3 units for Tea during the latest inventory adjustment.',
      'INVENTORY_DISCREPANCY',
      'adjustment-surplus',
    );
  });

  it('formats discrepancy summaries for more than two abnormal items', async () => {
    await service.checkDiscrepancyRule({
      storeId: 'store-1',
      adjustmentId: 'adjustment-1',
      items: [
        { productName: 'Milk', systemQuantity: 100, actualQuantity: 94 },
        { productName: 'Tea', systemQuantity: 100, actualQuantity: 94 },
        { productName: 'Coffee', systemQuantity: 100, actualQuantity: 94 },
      ],
    });

    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '⚠️ Inventory Discrepancy Alert',
      'Detected abnormal discrepancies for 3 items (including Milk, Tea...). Please review the adjustment record.',
      'INVENTORY_DISCREPANCY',
      'adjustment-1',
    );
  });

  it('does not notify discrepancies when there are no abnormal items or no target members', async () => {
    await service.checkDiscrepancyRule({
      storeId: 'store-1',
      adjustmentId: 'adjustment-1',
      items: [{ productName: 'Milk', systemQuantity: 100, actualQuantity: 98 }],
    });
    prismaMocks.prisma.storeMember.findMany.mockResolvedValue([]);
    await service.checkDiscrepancyRule({
      storeId: 'store-1',
      adjustmentId: 'adjustment-2',
      items: [{ productName: 'Tea', systemQuantity: 0, actualQuantity: 3 }],
    });

    expect(notificationService.createAndSendNotification).not.toHaveBeenCalled();
  });

  it('uses cold-start and dynamic thresholds for unusual large transactions', async () => {
    prismaMocks.prisma.transaction.aggregate
      .mockResolvedValueOnce({
        _avg: { totalPrice: null },
        _count: { transactionId: 4 },
      })
      .mockResolvedValueOnce({
        _avg: { totalPrice: { toString: () => '1000' } },
        _count: { transactionId: 5 },
      });

    await service.checkTransactionRule({
      storeId: 'store-1',
      transactionId: 'transaction-1',
      type: 'import',
      totalPrice: 500,
      itemCount: 2,
    });
    await service.checkTransactionRule({
      storeId: 'store-1',
      transactionId: 'transaction-2',
      type: 'export',
      totalPrice: 1600,
      itemCount: 3,
    });

    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '📦 Unusual Large Import Detected',
      expect.stringContaining('500'),
      'IMPORT',
      'transaction-1',
    );
    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '🚚 Unusual Large Export Detected',
      expect.stringContaining('1,600'),
      'EXPORT',
      'transaction-2',
    );
  });

  it('does not notify normal transactions', async () => {
    prismaMocks.prisma.transaction.aggregate.mockResolvedValue({
      _avg: { totalPrice: { toString: () => '1000' } },
      _count: { transactionId: 5 },
    });

    await service.checkTransactionRule({
      storeId: 'store-1',
      transactionId: 'transaction-1',
      type: 'export',
      totalPrice: 100,
      itemCount: 1,
    });

    expect(notificationService.createAndSendNotification).not.toHaveBeenCalled();
  });

  it('notifies the target user when their role changes', async () => {
    await service.checkRoleUpdatedRule({
      targetUserId: 'user-1',
      storeId: 'store-1',
      oldRole: 'staff',
      newRole: 'manager',
    });

    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'user-1',
      'store-1',
      '🔒 Permissions Updated',
      'Your role has been updated from STAFF to MANAGER. Please log in again to apply changes.',
      'ROLE_UPDATED',
      undefined,
    );
  });

  it('converts batch reorder suggestion events into summary notifications', async () => {
    const reorderHandler = eventMocks.on.mock.calls.find(
      ([eventName]) => eventName === 'BATCH_REORDER_SUGGESTION',
    )?.[1] as (payload: {
      storeId: string;
      suggestions: Array<{ productName: string; suggestedQuantity: number }>;
    }) => Promise<void>;

    await reorderHandler({
      storeId: 'store-1',
      suggestions: [
        { productName: 'Milk', suggestedQuantity: 10 },
        { productName: 'Tea', suggestedQuantity: 5 },
        { productName: 'Coffee', suggestedQuantity: 3 },
      ],
    });

    await vi.waitFor(() =>
      expect(
        notificationService.createAndSendNotification,
      ).toHaveBeenCalledWith(
        'owner-1',
        'store-1',
        '💡 Daily Reorder Summary',
        'Recommendation: 3 items need restocking (including Milk, Tea...). Tap to view details.',
        'REORDER_SUGGESTION',
        undefined,
      ),
    );
  });

  it('formats single and two-item reorder suggestion notifications', async () => {
    const reorderHandler = eventMocks.on.mock.calls.find(
      ([eventName]) => eventName === 'BATCH_REORDER_SUGGESTION',
    )?.[1] as (payload: {
      storeId: string;
      suggestions: Array<{ productName: string; suggestedQuantity: number }>;
    }) => Promise<void>;

    await reorderHandler({
      storeId: 'store-1',
      suggestions: [{ productName: 'Milk', suggestedQuantity: 10 }],
    });
    await reorderHandler({
      storeId: 'store-1',
      suggestions: [
        { productName: 'Milk', suggestedQuantity: 10 },
        { productName: 'Tea', suggestedQuantity: 5 },
      ],
    });

    await vi.waitFor(() =>
      expect(
        notificationService.createAndSendNotification,
      ).toHaveBeenCalledWith(
        'owner-1',
        'store-1',
        '💡 Smart Reorder Suggestion',
        'Recommendation: Restock 10 units for Milk.',
        'REORDER_SUGGESTION',
        undefined,
      ),
    );
    expect(notificationService.createAndSendNotification).toHaveBeenCalledWith(
      'owner-1',
      'store-1',
      '💡 Smart Reorder Suggestion',
      'Recommendation: Restock required for Milk and Tea. Tap to view details.',
      'REORDER_SUGGESTION',
      undefined,
    );
  });

  it('does not notify reorder suggestions when no target members exist', async () => {
    const reorderHandler = eventMocks.on.mock.calls.find(
      ([eventName]) => eventName === 'BATCH_REORDER_SUGGESTION',
    )?.[1] as (payload: {
      storeId: string;
      suggestions: Array<{ productName: string; suggestedQuantity: number }>;
    }) => Promise<void>;

    prismaMocks.prisma.storeMember.findMany.mockResolvedValue([]);

    await reorderHandler({
      storeId: 'store-1',
      suggestions: [{ productName: 'Milk', suggestedQuantity: 10 }],
    });

    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(notificationService.createAndSendNotification).not.toHaveBeenCalled();
  });
});
