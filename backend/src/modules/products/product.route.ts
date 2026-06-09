import { Router } from 'express';

import { productController } from './product.module.js';
import {
  validateGetProducts,
  validateCreateProduct,
  validateDeleteProduct,
  validateGetProductById,
  validateUpdateProduct,
} from './product.validator.js';
import { asyncWrapper } from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../store-member/index.js';

const productRouter = Router();

productRouter.use(authenticate, requireStoreContext);

/**
 * API endpoint: GET /api/products
 * Lấy danh sách sản phẩm theo cửa hàng (có phân trang, lọc và sắp xếp)
 *
 * Query params:
 *  - page?: number (default: 1)
 *  - limit?: number (default: 50, max: 100)
 *  - sortBy?: 'name' | 'createdAt' | 'updatedAt' (default: 'name')
 *  - sortOrder?: 'asc' | 'desc' (default: 'desc')
 *  - categoryId?: string (UUID) - lọc theo danh mục
 *  - brand?: string - lọc theo thương hiệu
 *
 * API endpoint: POST /api/products
 * Tạo sản phẩm mới cho cửa hàng hiện tại
 *
 * Body:
 *  - name: string (required) - tên sản phẩm
 *  - imageUrl?: string | null - ảnh đại diện sản phẩm
 *  - brand?: string | null - thương hiệu
 *  - categoryId: string (UUID, required) - danh mục của sản phẩm
 */
productRouter
  .route('/')
  .get(
    requirePermission(PERMISSION.PRODUCT_READ),
    validateGetProducts,
    asyncWrapper(productController.getProducts),
  )
  .post(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateCreateProduct,
    asyncWrapper(productController.createProduct),
  );

/**
 * API endpoint: GET /api/products/:productId
 * Lấy chi tiết một sản phẩm theo id
 *
 * Path params:
 *  - productId: string (UUID, required)
 *
 * API endpoint: PATCH /api/products/:productId
 * Cập nhật thông tin sản phẩm
 *
 * Path params:
 *  - productId: string (UUID, required)
 *
 * Body:
 *  - name?: string - tên sản phẩm
 *  - imageUrl?: string | null - ảnh đại diện sản phẩm
 *  - brand?: string | null - thương hiệu
 *  - categoryId?: string (UUID) - danh mục của sản phẩm
 *
 * API endpoint: DELETE /api/products/:productId
 * Xóa mềm sản phẩm theo id
 *
 * Path params:
 *  - productId: string (UUID, required)
 */
productRouter
  .route('/:productId')
  .get(
    requirePermission(PERMISSION.PRODUCT_READ),
    validateGetProductById,
    asyncWrapper(productController.getProductById),
  )
  .patch(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateUpdateProduct,
    asyncWrapper(productController.updateProduct),
  )
  .delete(
    requirePermission(PERMISSION.PRODUCT_WRITE),
    validateDeleteProduct,
    asyncWrapper(productController.softDeleteProduct),
  );

export { productRouter };
