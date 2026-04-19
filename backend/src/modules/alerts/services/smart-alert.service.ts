import { appEvents, eventBus } from '../../../common/events/event-bus.js';
import { prisma } from '../../../db/prismaClient.js';
import { NotificationRepository } from '../../notification/repositories/notification.repository.js';
import { NotificationService } from '../../notification/services/notification.service.js';
import { getRandomMessage } from '../utils/message.util.js';

import type {
  BatchReorderSuggestionPayload,
  DiscrepancyPayload,
  LowStockInventoryItem,
} from '../../../common/events/event-payloads.js';

export class SmartAlertService {
  constructor(private readonly notificationService: NotificationService) {
    this.initEventListeners();
  }

  private initEventListeners() {
    eventBus.on(
      appEvents.INVENTORY_CHANGED,
      (payload: {
        inventoryId: string;
        storeId: string;
        oldQuantity?: number;
        newQuantity?: number;
      }) => {
        this.checkLowStockRule(
          payload.inventoryId,
          payload.storeId,
          payload.newQuantity,
          payload.oldQuantity,
        ).catch((err) => console.error('Lỗi khi check rules:', err));
      },
    );

    eventBus.on(
      appEvents.BATCH_INVENTORY_CHANGED,
      (payload: {
        storeId: string;
        items: Array<{
          inventoryId: string;
          oldQuantity: number;
          newQuantity: number;
        }>;
      }) => {
        this.checkBatchLowStockRule(payload).catch((err) =>
          console.error('Lỗi khi check batch rules:', err),
        );
      },
    );

    eventBus.on(
      appEvents.INVENTORY_DISCREPANCY,
      (payload: {
        storeId: string;
        adjustmentId: string;
        items: Array<{
          productName: string;
          systemQuantity: number;
          actualQuantity: number;
        }>;
      }) => {
        this.checkDiscrepancyRule(payload).catch((err) =>
          console.error('Lỗi khi check discrepancy rules:', err),
        );
      },
    );

    eventBus.on(
      appEvents.LARGE_ORDER_CREATED,
      (payload: {
        storeId: string;
        transactionId: string;
        type: string;
        totalPrice: number;
        itemCount: number;
      }) => {
        this.checkTransactionRule(payload).catch((err) =>
          console.error('Lỗi khi check rules giao dịch:', err),
        );
      },
    );

    eventBus.on(
      appEvents.ROLE_UPDATED,
      (payload: {
        targetUserId: string;
        storeId: string;
        oldRole: string;
        newRole: string;
      }) => {
        this.checkRoleUpdatedRule(payload).catch((err) =>
          console.error('Lỗi khi xử lý thông báo đổi role:', err),
        );
      },
    );

    eventBus.on(
      appEvents.BATCH_REORDER_SUGGESTION,
      (payload: BatchReorderSuggestionPayload) => {
        this.handleBatchReorderSuggestion(payload).catch((err) =>
          console.error('Error handling batch reorder suggestion:', err),
        );
      },
    );
  }

  public async checkLowStockRule(
    inventoryId: string,
    providedStoreId?: string,
    newQuantity?: number,
    oldQuantity?: number,
  ) {
    const inventory = await prisma.inventory.findUnique({
      where: { inventoryId: inventoryId },
      include: {
        productPackage: {
          include: {
            product: true,
          },
        },
      },
    });

    if (!inventory) {
      return;
    }

    const threshold = inventory.reorderThreshold ?? 0;
    const currentQty = newQuantity ?? inventory.quantity;

    if (oldQuantity !== undefined) {
      // Dành cho Real-time: Chỉ báo động khi VỪA RỚT QUA NGƯỠNG
      const isSafe = oldQuantity > threshold;
      const isNowLow = currentQty <= threshold;

      // Nếu trước đó đã thấp sẵn rồi (isSafe = false)
      // thì KHÔNG gửi nữa (Chống Spam)
      if (!(isSafe && isNowLow)) {
        return;
      }
    } else {
      // Dành cho Cron Job (quét tự động không có oldQuantity):
      // Lấy tất cả kho <= ngưỡng
      if (currentQty > threshold) {
        return;
      }
    }

    // Lấy storeId
    const storeId =
      providedStoreId || inventory.productPackage?.product?.storeId;

    if (!storeId) {
      return;
    }

    // Lấy danh sách Chủ và Quản lý của cửa hàng này
    const targetMembers = await this.getTargetMembers(storeId);

    if (targetMembers.length === 0) {
      return;
    }

    // Lấy tên của từng product package để gửi thông báo chính xác!
    const productName =
      inventory.productPackage?.displayName ?? 'An unnamed product';

    const bodyTemplates = [
      `${productName} is running low! Only ${currentQty} left in stock.`,
      `Action required: ${productName} has dropped to ${currentQty} units.`,
      `Restock reminder: You have ${currentQty} units of ${productName} remaining.`,
      `Heads up! ${productName} has reached its reorder threshold (${currentQty} left).`,
    ];

    const bodyText = getRandomMessage(bodyTemplates);

    // Dùng Promise.all để gửi đồng loạt không bị nghẽn
    await Promise.allSettled(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          storeId,
          '⚠️ Low Stock Alert',
          bodyText,
          appEvents.LOW_STOCK,
          inventory.productPackage?.productId,
        ),
      ),
    );
  }

  public async scanAllStoresForLowStock() {
    console.info('[Cron] Đang quét toàn hệ thống tìm hàng tồn kho thấp...');

    const lowInventories = await prisma.inventory.findMany({
      where: {
        reorderThreshold: { not: null },
        quantity: { lte: prisma.inventory.fields.reorderThreshold },
        activeStatus: 'active',
      },
      include: {
        productPackage: { include: { product: true } },
      },
    });

    if (lowInventories.length === 0) {
      console.info(
        '[Cron] Không phát hiện sản phẩm nào có tồn kho thấp. Đã dừng quy trình quét.',
      );

      return;
    }

    const storeDeficits: Record<string, LowStockInventoryItem[]> = {};

    for (const inv of lowInventories) {
      const storeId = inv.productPackage?.product?.storeId;

      if (storeId) {
        if (!storeDeficits[storeId]) {
          storeDeficits[storeId] = [];
        }
        storeDeficits[storeId].push(inv as LowStockInventoryItem);
      }
    }

    // Duyệt qua từng storeId và gửi 1 thông báo tổng hợp
    for (const [storeId, inventories] of Object.entries(storeDeficits)) {
      await this.processBatchNotification(storeId, inventories);
    }
  }

  // Hàm mới xử lý gửi thông báo gộp (Không đụng chạm tới checkLowStockRule)
  private async processBatchNotification(
    storeId: string,
    inventories: LowStockInventoryItem[],
  ) {
    const targetMembers = await this.getTargetMembers(storeId);

    if (targetMembers.length === 0) {
      return;
    }

    const totalLowStock = inventories.length;

    // Lấy mảng tên các sản phẩm hợp lệ
    const sampleNamesArray = inventories
      .map((inv) => inv.productPackage?.displayName)
      .filter(Boolean);

    let bodyText = '';
    let bodyTemplates: string[] = [];

    // Phân loại nội dung thông báo dựa trên số lượng & tạo mảng templates
    if (totalLowStock === 1) {
      const name = sampleNamesArray[0] || 'A product';

      bodyTemplates = [
        `The item ${name} is critically low. Please restock soon!`,
        `Inventory alert: ${name} is almost out of stock.`,
        `Restock needed: ${name} has dropped below the safe limit.`,
      ];
    } else if (totalLowStock === 2) {
      const names = sampleNamesArray.join(' and ');

      bodyTemplates = [
        `${names} are running low on stock. Please review.`,
        `Action required: Stock is low for both ${names}.`,
        `Restock reminder: It's time to order more ${names}.`,
      ];
    } else {
      const names = sampleNamesArray.slice(0, 2).join(', ');

      bodyTemplates = [
        `${totalLowStock} items need restocking (e.g., ${names}, ...).`,
        `Multiple items are low on stock! (${totalLowStock} total, including ${names}, ...).`,
        `Inventory warning: ${totalLowStock} products have hit their reorder point (like ${names}, ...).`,
      ];
    }

    bodyText = getRandomMessage(bodyTemplates);

    await Promise.all(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          storeId,
          '⚠️ Inventory Warning',
          bodyText,
          appEvents.BATCH_LOW_STOCK,
          undefined,
        ),
      ),
    );
  }

  public async checkBatchLowStockRule(payload: {
    storeId: string;
    items: Array<{
      inventoryId: string;
      oldQuantity: number;
      newQuantity: number;
    }>;
  }) {
    const inventoryIds = payload.items.map((item) => item.inventoryId);

    const inventories = await prisma.inventory.findMany({
      where: { inventoryId: { in: inventoryIds } },
      include: {
        productPackage: { include: { product: true } },
      },
    });

    const lowStockItems: LowStockInventoryItem[] = [];

    for (const inv of inventories) {
      const threshold = inv.reorderThreshold ?? 0;
      const payloadItem = payload.items.find(
        (i) => i.inventoryId === inv.inventoryId,
      );

      if (!payloadItem) {
        continue;
      }

      const isSafe = payloadItem.oldQuantity > threshold;
      const isNowLow = payloadItem.newQuantity <= threshold;

      if (isSafe && isNowLow) {
        // Gán quantity mới vào object để gửi đi nếu cần
        const itemToAlert = { ...inv, quantity: payloadItem.newQuantity };

        lowStockItems.push(itemToAlert as LowStockInventoryItem);
      }
    }

    if (lowStockItems.length === 0) {
      return;
    }

    if (lowStockItems.length === 1) {
      const inv = lowStockItems[0]!;
      const productName = inv.productPackage?.displayName ?? 'Product';

      const bodyText = `${productName} is running low (${inv.quantity} units left). Please restock soon!`;

      const targetMembers = await this.getTargetMembers(payload.storeId);

      await Promise.all(
        targetMembers.map((member) =>
          this.notificationService.createAndSendNotification(
            member.userId,
            payload.storeId,
            '⚠️ Low Stock Alert',
            bodyText,
            appEvents.LOW_STOCK,
            inv.productPackage?.product?.productId,
          ),
        ),
      );
    } else {
      await this.processBatchNotification(payload.storeId, lowStockItems);
    }
  }

  private async getTargetMembers(storeId: string) {
    return await prisma.storeMember.findMany({
      where: {
        storeId: storeId,
        role: { in: ['owner', 'manager'] },
        activeStatus: 'active',
      },
      select: { userId: true },
    });
  }

  public async checkDiscrepancyRule(payload: DiscrepancyPayload) {
    const { storeId, adjustmentId, items } = payload;

    // Lọc ra các item có độ lệch bất thường (Ví dụ: lệch từ 5 đơn vị trở lên)
    const abnormalItems = items.filter(
      (item) => Math.abs(item.systemQuantity - item.actualQuantity) >= 5,
    );

    // Nếu không có sản phẩm nào lệch quá ngưỡng, dừng lại không báo
    if (abnormalItems.length === 0) {
      return;
    }

    const targetMembers = await this.getTargetMembers(storeId);

    if (targetMembers.length === 0) {
      return;
    }

    const totalAbnormal = abnormalItems.length;
    let bodyText = '';
    const title = '⚠️ Inventory Discrepancy Alert';

    // Xử lý nội dung hiển thị: 1 sản phẩm vs Nhiều sản phẩm
    if (totalAbnormal === 1) {
      const item = abnormalItems[0]!;
      const discrepancy = Math.abs(item.systemQuantity - item.actualQuantity);
      const actionWord =
        item.actualQuantity < item.systemQuantity ? 'loss' : 'surplus';

      bodyText = `Detected a ${actionWord} of ${discrepancy} units for ${item.productName} during the latest inventory adjustment.`;
    } else if (totalAbnormal === 2) {
      const names = abnormalItems.map((i) => i.productName).join(' and ');

      bodyText = `Detected abnormal discrepancies for ${names}. Please review the adjustment record.`;
    } else {
      const names = abnormalItems
        .slice(0, 2)
        .map((i) => i.productName)
        .join(', ');

      bodyText = `Detected abnormal discrepancies for ${totalAbnormal} items (including ${names}...). Please review the adjustment record.`;
    }

    // Bắn thông báo
    await Promise.all(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          storeId,
          title,
          bodyText,
          appEvents.INVENTORY_DISCREPANCY,
          adjustmentId,
        ),
      ),
    );
  }

  public async checkTransactionRule(payload: {
    storeId: string;
    transactionId: string;
    type: string;
    totalPrice: number;
    itemCount: number;
  }) {
    if (payload.totalPrice < 50) {
      return;
    }

    const targetMembers = await this.getTargetMembers(payload.storeId);

    if (targetMembers.length === 0) {
      return;
    }

    // Chuẩn bị nội dung
    const isImport = payload.type === 'import';
    const actionType = isImport ? 'import' : 'export';
    const notiType = isImport ? appEvents.IMPORT : appEvents.EXPORT;

    const title = isImport
      ? '📦 Stock Import Completed'
      : '🚚 Stock Export Completed';

    // Format tiền tệ VNĐ (thêm dấu phẩy)
    const formattedPrice = new Intl.NumberFormat('en-US').format(
      payload.totalPrice,
    );
    const bodyText = `A successful ${actionType} transaction was recorded. Total value: ${formattedPrice} Dollar (${payload.itemCount} items).`;

    // Gửi thông báo
    await Promise.all(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          payload.storeId,
          title,
          bodyText,
          notiType,
          payload.transactionId,
        ),
      ),
    );
  }

  public async checkRoleUpdatedRule(payload: {
    targetUserId: string;
    storeId: string;
    oldRole: string;
    newRole: string;
  }) {
    // Chữ in hoa cho đẹp (vd: từ 'staff' -> 'MANAGER')
    const oldRoleCap = payload.oldRole.toUpperCase();
    const newRoleCap = payload.newRole.toUpperCase();

    const title = '🔒 Permissions Updated';
    const bodyText = `Your role has been updated from ${oldRoleCap} to ${newRoleCap}. Please log in again to apply changes.`;

    // Gửi thông báo đích danh cho người bị đổi quyền
    await this.notificationService.createAndSendNotification(
      payload.targetUserId, // Gửi đúng cho 1 người này
      payload.storeId,
      title,
      bodyText,
      appEvents.ROLE_UPDATED,
      undefined,
    );
  }

  private async handleBatchReorderSuggestion(
    payload: BatchReorderSuggestionPayload,
  ) {
    const targetMembers = await this.getTargetMembers(payload.storeId);

    if (targetMembers.length === 0) {
      return;
    }

    const totalSuggestions = payload.suggestions.length;
    let title = '💡 Smart Reorder Suggestion';
    let bodyText = '';

    // Logic sinh văn bản thông minh chống Spam
    if (totalSuggestions === 1) {
      const item = payload.suggestions[0]!;

      bodyText = `Recommendation: Restock ${item.suggestedQuantity} units for ${item.productName}.`;
    } else if (totalSuggestions === 2) {
      const names = payload.suggestions.map((s) => s.productName).join(' and ');

      bodyText = `Recommendation: Restock required for ${names}. Tap to view details.`;
    } else {
      const names = payload.suggestions
        .slice(0, 2)
        .map((s) => s.productName)
        .join(', ');

      bodyText = `Recommendation: ${totalSuggestions} items need restocking (including ${names}...). Tap to view details.`;
      title = '💡 Daily Reorder Summary';
    }

    await Promise.all(
      targetMembers.map((member) =>
        this.notificationService.createAndSendNotification(
          member.userId,
          payload.storeId,
          title,
          bodyText,
          appEvents.REORDER_SUGGESTION,
          undefined,
        ),
      ),
    );
  }
}

export const smartAlertService = new SmartAlertService(
  new NotificationService(new NotificationRepository()),
);
