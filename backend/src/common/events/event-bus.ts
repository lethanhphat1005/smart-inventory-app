import EventEmitter from 'events';

class AppEventBus extends EventEmitter {}

// Đảm bảo chỉ có 1 instance duy nhất (Singleton pattern)
// hoạt động trên toàn app
export const eventBus = new AppEventBus();

// Định nghĩa sẵn các tên sự kiện (Constants) để tái sử dụng,
// tránh gõ sai chính tả
export const appEvents = {
// --- Internal System Events ---
  INVENTORY_CHANGED: 'INVENTORY_CHANGED',
  BATCH_INVENTORY_CHANGED: 'BATCH_INVENTORY_CHANGED',
  LARGE_ORDER_CREATED: 'LARGE_ORDER_CREATED',
  INVENTORY_DISCREPANCY: 'INVENTORY_DISCREPANCY',
  ROLE_UPDATED: 'ROLE_UPDATED',
  BATCH_REORDER_SUGGESTION: 'BATCH_REORDER_SUGGESTION',

  // --- Notification Types ---
  LOW_STOCK: 'LOW_STOCK',
  BATCH_LOW_STOCK: 'BATCH_LOW_STOCK',
  REORDER_SUGGESTION: 'REORDER_SUGGESTION',
  IMPORT: 'IMPORT',
  EXPORT: 'EXPORT',
} as const;
