import { Router } from 'express';

import { searchController } from './search.module.js';
import {
  searchByKeywordQuerySchema,
  searchByPrefixQuerySchema,
} from './search.validator.js';
import {
  asyncWrapper,
  validatorToLocals,
} from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../store-member/index.js';

const searchRouter = Router();

searchRouter.use(authenticate, requireStoreContext);

/**
 * Search danh sách Product theo keyword (FTS, có phân trang)
 *
 * Query params:
 *  - keyword: string (required) - từ khóa tìm kiếm
 *  - page?: number (default: 1)
 *  - limit?: number (default: 50, max: 100)
 */
searchRouter.get(
  '/products',
  requirePermission(PERMISSION.PRODUCT_READ),
  validatorToLocals(searchByKeywordQuerySchema, 'query'),
  asyncWrapper(searchController.getProductsbyKeyword),
);

/**
 * Search danh sách ProductPackage theo keyword (FTS, có phân trang)
 *
 * Query params:
 *  - keyword: string (required) - từ khóa tìm kiếm
 *  - page?: number (default: 1)
 *  - limit?: number (default: 20, max: 50)
 */
searchRouter.get(
  '/product-packages',
  requirePermission(PERMISSION.PRODUCT_READ),
  validatorToLocals(searchByPrefixQuerySchema, 'query'),
  asyncWrapper(searchController.getProductPackagesbyKeyword),
);

/**
 * Autocomplete ô nhập product (debounce frontend ~300ms)
 *
 * Query params:
 *  - keyword: string (required)
 *  - page?: number (default: 1)
 *  - limit?: number (default: 20, max: 50)
 */
searchRouter.get(
  '/products/prefix',
  requirePermission(PERMISSION.PRODUCT_READ),
  validatorToLocals(searchByPrefixQuerySchema, 'query'),
  asyncWrapper(searchController.getProductsByPrefix),
);

export { searchRouter };
