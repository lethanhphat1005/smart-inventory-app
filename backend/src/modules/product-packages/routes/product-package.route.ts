import { Router } from 'express';

import { asyncWrapper } from '../../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../../access-control/index.js';
import { authenticate } from '../../auth/index.js';
import { requireStoreContext } from '../../stores/index.js';
import { productPackageController } from '../modules/product-package.module.js';
import {
  validateCreateProductPackage,
  validateDeleteProductPackage,
  validateGetProductPackageById,
  validateGetProductPackagesByProductId,
  validateUpdateProductPackage,
  validateGetPackagesByStore,
} from '../product-package.validator.js';

const productPackageRouter = Router();
const productPackageProductRouter = Router();

productPackageRouter.use(authenticate, requireStoreContext);
productPackageProductRouter.use(authenticate, requireStoreContext);

/**
 * API endpoint: GET /api/product-packages
 * Lấy danh sách gói sản phẩm trong cửa hàng (có phân trang, lọc và sắp xếp)
 *
 * Query params:
 *  - page?: number (default: 1)
 *  - limit?: number (default: 50, max: 100)
 *  - sortBy?:
 *      'displayName' | 'createdAt' | 'updatedAt' (default: 'displayName')
 *  - sortOrder?: 'asc' | 'desc' (default: 'asc')
 *  - categoryId?: string (UUID) - lọc theo danh mục sản phẩm
 */
productPackageRouter.get(
  '/',
  requirePermission(PERMISSION.PRODUCT_READ),
  validateGetPackagesByStore,
  asyncWrapper(productPackageController.getProductPackagesByStore),
);

/**
 * API endpoint: GET /api/products/:productId/packages
 * Lấy danh sách package của một sản phẩm
 *
 * Path params:
 *  - productId: string (UUID, required)
 *
 * API endpoint: POST /api/products/:productId/packages
 * Tạo package và inventory mới cho sản phẩm
 *
 * Path params:
 *  - productId: string (UUID, required)
 *
 * Frontend flow khi user nhập/scan barcode:
 *  1. Gọi API này để tạo productPackage trước
 *  2. Sau khi tạo thành công (có productPackageId),
 *     gọi tiếp API:
 *     POST /api/product-packages/:productPackageId/barcodes
 *     (xem api comment tại product-package-barcode.route.ts)
 *
 * Body:
 *  - package: object (required)
 *    - unitId: string (UUID, required) - đơn vị tính của package
 *    - importPrice?: number | null - giá nhập
 *    - sellingPrice?: number | null - giá bán
 *    - variant?: string | null - biến thể của package
 *  - inventory: object (required)
 *    - quantity: number (integer, default: 0) - số lượng tồn kho ban đầu
 *    - reorderThreshold?: number | null - ngưỡng cảnh báo
 */
productPackageProductRouter
  .route('/:productId/packages')
  .get(
    requirePermission(PERMISSION.PRODUCT_READ),
    validateGetProductPackagesByProductId,
    asyncWrapper(productPackageController.getProductPackagesByProductId),
  )
  .post(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateCreateProductPackage,
    asyncWrapper(productPackageController.createProductPackage),
  );

/**
 * API endpoint: GET /api/product-packages/:productPackageId
 * Lấy chi tiết một package theo id
 *
 * Path params:
 *  - productPackageId: string (UUID, required)
 *
 * API endpoint: PATCH /api/product-packages/:productPackageId
 * Cập nhật thông tin package
 *
 * Path params:
 *  - productPackageId: string (UUID, required)
 *
 * Body:
 *  - importPrice?: number | null - giá nhập
 *  - sellingPrice?: number | null - giá bán
 *  - variant?: string | null - biến thể của package
 *  - unitId?: string - đơn vị tính của package
 *
 * API endpoint: DELETE /api/product-packages/:productPackageId
 * Xóa mềm package theo id
 *
 * Path params:
 *  - productPackageId: string (UUID, required)
 */
productPackageRouter
  .route('/:productPackageId')
  .get(
    requirePermission(PERMISSION.PRODUCT_READ),
    validateGetProductPackageById,
    asyncWrapper(productPackageController.getProductPackageById),
  )
  .patch(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateUpdateProductPackage,
    asyncWrapper(productPackageController.updateProductPackage),
  )
  .delete(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateDeleteProductPackage,
    asyncWrapper(productPackageController.softDeleteProductPackage),
  );

export { productPackageRouter, productPackageProductRouter };
