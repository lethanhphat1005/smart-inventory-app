import { Router } from 'express';

import { asyncWrapper } from '../../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../../access-control/index.js';
import { authenticate } from '../../auth/index.js';
import { requireStoreContext } from '../../stores/index.js';
import { barcodesController } from '../barcodes.module.js';
import {
  validateConfirmBarcodeMapping,
  validateScanBarcode,
} from '../barcodes.validator.js';

const barcodeRouter = Router();

barcodeRouter.use(authenticate, requireStoreContext);

/**
 * FRONTEND FLOW: Barcode scanning & mapping
 *
 * Bước 1: Scan barcode
 *  - FE gọi: POST /api/barcodes/scan
 *
 *  Kết quả có 3 trường hợp: 'exact_match' | 'candidate_match' | 'not_found'
 *
 * Bước 2: Confirm mapping
 *  - FE gọi: POST /api/barcodes/confirm
 *
 *  Được gọi:
 *    - sau khi user chọn đúng package (candidate_match)
 *    - sau khi user search và chọn package
 *    - sau khi user tạo package mới (flow create-from-barcode)
 *
 *  Kết quả:
 *    - Backend lưu ProductPackageBarcode (isVerified = true)
 *    - Lần scan sau sẽ trở thành exact_match
 */

/**
 * API endpoint: POST /api/barcodes/scan
 * Quét barcode để tìm product package tương ứng trong hệ thống
 *
 * Body:
 *  - barcode: string (required) - mã barcode cần quét
 *  - type?: BarcodeType - loại barcode (EAN, UPC...), optional
 *
 * Response:
 *  - resolutionType: 'exact_match' | 'candidate_match' | 'not_found'
 *
 *  Nếu exact_match -> Backend đã có mapping:
 *    - productPackage: ProductPackageResponseDto
 *
 *  Nếu candidate_match -> Backend tìm được các package match gần đúng:
 *    - candidates: ProductPackageResponseDto[]
 *    - prefill?: {
 *        name?: string;
 *        brand?: string;
 *        packageText?: string;
 *      }
 *
 *  Nếu not_found -> Không có mapping và không có candidate match đủ tốt:
 *    - prefill?: {
 *        name?: string;
 *        brand?: string;
 *        packageText?: string;
 *      }
 *
 * API endpoint: POST /api/barcodes/confirm
 * Xác nhận và lưu mapping giữa barcode và productPackage
 *
 * Use case:
 *  - User quét barcode và chọn đúng package từ candidate list
 *  - Lưu lại mapping để lần sau scan có thể exact match ngay
 *
 * Body:
 *  - barcode: string (required) - mã barcode cần lưu
 *  - productPackageId: string (UUID, required) - package được chọn
 *  - type?: BarcodeType - loại barcode (optional)
 *
 * Notes:
 *  - Đây là nơi duy nhất tạo mapping từ barcode -> productPackage
 *    (ngoài flow create package by barcode)
 *  - Đảm bảo 1 barcode chỉ map tới 1 package duy nhất trong hệ thống
 */
barcodeRouter.post(
  '/scan',
  requirePermission(PERMISSION.PRODUCT_READ),
  validateScanBarcode,
  asyncWrapper(barcodesController.scanBarcode),
);

barcodeRouter.post(
  '/confirm',
  requirePermission(PERMISSION.PRODUCT_WRITE),
  validateConfirmBarcodeMapping,
  asyncWrapper(barcodesController.confirmBarcodeMapping),
);

export { barcodeRouter };
