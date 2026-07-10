import { beforeEach, describe, expect, it, vi } from 'vitest';

import { InventoryEventPublisher } from '../../../../src/modules/alerts/inventory-event.publisher.js';

const eventMocks = vi.hoisted(() => ({
  emit: vi.fn(),
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

describe('InventoryEventPublisher', () => {
  let publisher: InventoryEventPublisher;

  beforeEach(() => {
    vi.clearAllMocks();
    publisher = new InventoryEventPublisher();
  });

  it('emits batch inventory changed payloads', () => {
    const payload = {
      storeId: 'store-1',
      items: [{ inventoryId: 'inventory-1', oldQuantity: 8, newQuantity: 4 }],
    };

    publisher.emitBatchInventoryChanged(payload);

    expect(eventMocks.emit).toHaveBeenCalledWith(
      'BATCH_INVENTORY_CHANGED',
      payload,
    );
  });

  it('emits inventory discrepancy payloads', () => {
    const payload = {
      storeId: 'store-1',
      adjustmentId: 'adjustment-1',
      items: [
        {
          productName: 'Milk',
          systemQuantity: 10,
          actualQuantity: 4,
        },
      ],
    };

    publisher.emitInventoryDiscrepancy(payload);

    expect(eventMocks.emit).toHaveBeenCalledWith(
      'INVENTORY_DISCREPANCY',
      payload,
    );
  });
});
