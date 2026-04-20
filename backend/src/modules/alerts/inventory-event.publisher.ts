import { appEvents, eventBus } from '../../common/events/event-bus.js';

import type {
  BatchInventoryPayload,
  DiscrepancyPayload,
  SingleInventoryPayload,
} from '../../common/events/event-payloads.js';

export class InventoryEventPublisher {
  // Phát sự kiện đơn lẻ
  public emitInventoryChanged(payload: SingleInventoryPayload): void {
    console.info(
      `[Event Publisher] Bắn sự kiện INVENTORY_CHANGED cho kho ${payload.inventoryId}. Từ ${payload.oldQuantity} -> ${payload.newQuantity}`,
    );
    eventBus.emit(appEvents.INVENTORY_CHANGED, payload);
  }

  // Hàm phát sự kiện gộp
  public emitBatchInventoryChanged(payload: BatchInventoryPayload): void {
    console.info(
      `[Event Publisher] Bắn sự kiện BATCH_INVENTORY_CHANGED cho cửa hàng ${payload.storeId} với ${payload.items.length} sản phẩm.`,
    );
    eventBus.emit(appEvents.BATCH_INVENTORY_CHANGED, payload);
  }

  public emitInventoryDiscrepancy(payload: DiscrepancyPayload): void {
    console.info(
      `[Event Publisher] Bắn sự kiện Lệch kho cho ${payload.items.length} sản phẩm (Phiếu: ${payload.adjustmentId}).`,
    );
    eventBus.emit(appEvents.INVENTORY_DISCREPANCY, payload);
  }
}
