import { Router } from 'express';

import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { inventoryController } from '../inventories/inventory.module.js';
import {
  validateCreateInventory,
  validateDeleteInventory,
  validateGetInventories,
  validateGetInventoryByProductPackageId,
  validateGetLowStockInventories,
  validateUpdateInventory,
  validateBatchAdjustInventory,
} from '../inventories/validator/inventory.validator.js';
import { requireStoreContext } from '../stores/index.js';

const inventoryRouter = Router();

inventoryRouter.use(authenticate, requireStoreContext);

/**
 * API endpoint: GET /api/inventories
 * Lấy danh sách tồn kho của cửa hàng (có phân trang, lọc và sắp xếp)
 *
 * Query params:
 *  - page?: number (default: 1)
 *  - limit?: number (default: 10, max: 100)
 *  - sortBy?:
 *      'updatedAt'
 *      | 'quantity'
 *      | 'reorderThreshold'
 *      | 'lastCount' (default: 'updatedAt')
 *  - sortOrder?: 'asc' | 'desc' (default: 'desc')
 *  - keyword?: string - từ khóa tìm kiếm
 *  - categoryId?: string - lọc theo danh mục
 *  - inventoryStatus?:
 *      'inStock' | 'lowStock' | 'outOfStock' - lọc theo trạng thái tồn kho
 *
 * API endpoint: POST /api/inventories
 * Tạo bản ghi tồn kho cho một product package
 *
 * Body:
 *  - productPackageId: string (required) - id của product package
 *  - quantity?: number (default: 0) - số lượng tồn ban đầu
 *  - reorderThreshold?: number | null - ngưỡng cảnh báo sắp hết hàng
 *  - lastCount?: number | null - số lượng kiểm kê gần nhất
 */
inventoryRouter.get(
  '/',
  requirePermission(PERMISSION.INVENTORY_READ),
  validateGetInventories,
  asyncWrapper(inventoryController.getInventories),
);
inventoryRouter.post(
  '/',
  requirePermission(PERMISSION.INVENTORY_WRITE),
  validateCreateInventory,
  asyncWrapper(inventoryController.createInventory),
);

/**
 * API endpoint: GET /api/inventories/low-stock
 * Lấy danh sách tồn kho đang chạm hoặc dưới ngưỡng cảnh báo
 *
 * Query params:
 *  - page?: number (default: 1)
 *  - limit?: number (default: 10, max: 100)
 *  - sortBy?:
 *      'updatedAt'
 *      | 'quantity'
 *      | 'reorderThreshold'
 *      | 'lastCount' (default: 'updatedAt')
 *  - sortOrder?: 'asc' | 'desc' (default: 'desc')
 *  - keyword?: string - từ khóa tìm kiếm
 *  - categoryId?: string - lọc theo danh mục
 *  - inventoryStatus?:
 *      'inStock' | 'lowStock' | 'outOfStock'
 */
inventoryRouter.get(
  '/low-stock',
  requirePermission(PERMISSION.INVENTORY_READ),
  validateGetLowStockInventories,
  asyncWrapper(inventoryController.getLowStockInventories),
);

/**
 * API endpoint: GET /api/inventories/product-packages/:productPackageId
 * Lấy chi tiết tồn kho theo product package id
 *
 * Path params:
 *  - productPackageId: string (UUID, required)
 *
 * API endpoint: PATCH /api/inventories/product-packages/:productPackageId
 * Cập nhật cấu hình tồn kho, không thay đổi số lượng tồn thực tế
 *
 * Path params:
 *  - productPackageId: string (UUID, required)
 *
 * Body:
 *  - reorderThreshold?: number | null - ngưỡng cảnh báo sắp hết hàng
 *
 * API endpoint: DELETE /api/inventories/product-packages/:productPackageId
 * Xóa mềm bản ghi tồn kho theo product package id
 *
 * Path params:
 *  - productPackageId: string (UUID, required)
 */
inventoryRouter
  .route('/product-packages/:productPackageId')
  .get(
    requirePermission(PERMISSION.INVENTORY_READ),
    validateGetInventoryByProductPackageId,
    asyncWrapper(inventoryController.getInventoryByProductPackageId),
  )
  .patch(
    requirePermission(PERMISSION.INVENTORY_WRITE),
    validateUpdateInventory,
    asyncWrapper(inventoryController.updateInventory),
  )
  .delete(
    requirePermission(PERMISSION.INVENTORY_WRITE),
    validateDeleteInventory,
    asyncWrapper(inventoryController.deleteInventory),
  );

/**
 * API endpoint: POST /api/inventories/adjustments
 * Điều chỉnh số lượng tồn kho hàng loạt (Batch)
 * cho một hoặc nhiều product package
 *
 * Body:
 * - items: Mảng (array) chứa các đối tượng cần điều chỉnh. Mỗi đối tượng gồm:
 * + productPackageId: string (UUID, required) - ID của sản phẩm
 * + type: 'set' | 'increase' | 'decrease' (required) - kiểu điều chỉnh tồn kho
 * + quantity: number (required) - số lượng áp dụng cho thao tác điều chỉnh
 * + reason?: string | null - lý do điều chỉnh (không bắt buộc)
 * + note?: string | null - ghi chú thêm (không bắt buộc)
 */
inventoryRouter.post(
  '/adjustments',
  requirePermission(PERMISSION.INVENTORY_WRITE),
  validateBatchAdjustInventory,
  asyncWrapper(inventoryController.adjustInventories),
);

export { inventoryRouter };
