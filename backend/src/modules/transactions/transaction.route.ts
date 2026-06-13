import { Router } from 'express';

import { transactionController } from './transaction.module.js';
import {
  paramsSchema,
  listTransactionsQuerySchema,
  createTransactionBodySchema,
} from './transaction.validator.js';
import {
  asyncWrapper,
  validator,
  validatorToLocals,
} from '../../common/middlewares/index.js';
import { PERMISSION, requirePermission } from '../access-control/index.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../store-member/index.js';

const transactionRouter = Router();

transactionRouter.use(authenticate, requireStoreContext);

/**
 * API endpoint: GET /api/transactions
 * Lấy danh sách phiếu giao dịch theo store, có phân trang
 *
 * Query:
 *  - page?: number
 *  - limit?: number
 *  - sortBy?: 'createdAt' | 'totalPrice'
 *  - sortOrder?: 'asc' | 'desc'
 *  - type?: 'import' | 'export'
 *  - userId?: uuid, string
 */
transactionRouter.get(
  '/',
  requirePermission(PERMISSION.TRANSACTION_READ),
  validatorToLocals(listTransactionsQuerySchema, 'query'),
  asyncWrapper(transactionController.getTransactions),
);

/**
 * API endpoint: GET /api/transactions/:transactionId
 * Lấy chi tiết 1 phiếu giao dịch
 *
 * Params:
 *  - transactionId: string (uuid)
 */
transactionRouter.get(
  '/:transactionId',
  requirePermission(PERMISSION.TRANSACTION_READ),
  validator(paramsSchema, 'params'),
  asyncWrapper(transactionController.getTransactionById),
);

/**
 * API endpoint: POST /api/transactions/import
 * Tạo phiếu nhập kho thủ công
 *
 * Body:
 *  - note?: string | null
 *  - items: {
 *      productPackageId: string;
 *      quantity: number;
 *      unitPrice: number;
 *    }[]
 */
transactionRouter.post(
  '/import',
  requirePermission(PERMISSION.TRANSACTION_WRITE),
  validator(createTransactionBodySchema, 'body'),
  asyncWrapper(transactionController.createImportTransaction),
);

/**
 * API endpoint: POST /api/transactions/export
 * Tạo phiếu xuất kho thủ công
 *
 * Body:
 *  - note?: string | null
 *  - items: {
 *      productPackageId: string;
 *      quantity: number;
 *      unitPrice: number;
 *    }[]
 */
transactionRouter.post(
  '/export',
  requirePermission(PERMISSION.TRANSACTION_WRITE),
  validator(createTransactionBodySchema, 'body'),
  asyncWrapper(transactionController.createExportTransaction),
);

export { transactionRouter };
