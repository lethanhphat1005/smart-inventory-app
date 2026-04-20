import { Router } from 'express';

import { asyncWrapper } from '../../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../../access-control/index.js';
import { authenticate } from '../../auth/index.js';
import { requireStoreContext } from '../../stores/index.js';
import { productPackageBarcodeController } from '../barcodes.module.js';
import {
  validateCreateProductPackageBarcodeMapping,
  validateRemoveProductPackageBarcodeMapping,
} from '../barcodes.validator.js';

const productPackageBarcodeRouter = Router();

productPackageBarcodeRouter.use(authenticate, requireStoreContext);

/**
 * API endpoint: POST /api/product-packages/:productPackageId/barcodes
 * Gắn barcode vào 1 productPackage đã tồn tại hoặc mới tạo
 *
 * Params:
 *  - productPackageId: string (UUID, required) - ID của package cần gắn barcode
 *
 * Body:
 *  - barcode: string (required) - mã barcode cần map
 *  - type?: BarcodeType - loại barcode (optional)
 */
productPackageBarcodeRouter.post(
  '/:productPackageId/barcodes',
  requirePermission(PERMISSION.PRODUCT_WRITE),
  validateCreateProductPackageBarcodeMapping,
  asyncWrapper(productPackageBarcodeController.createPackageBarcode),
);

/**
 * API endpoint:
 *  DELETE /api/product-packages/:productPackageId/barcodes/:barcode
 * Gỡ map và hard delete barcode khỏi 1 productPackage
 *
 * Params:
 *  - productPackageId: string (UUID, required) - ID của package
 *  - barcode: string (required) - mã barcode cần xóa
 */
productPackageBarcodeRouter.delete(
  '/:productPackageId/barcodes/:barcode',
  requirePermission(PERMISSION.PRODUCT_WRITE),
  validateRemoveProductPackageBarcodeMapping,
  asyncWrapper(productPackageBarcodeController.deletePackageBarcode),
);

export { productPackageBarcodeRouter };
