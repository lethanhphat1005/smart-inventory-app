import { Router } from 'express';

import { currencyController } from './currency.module.js';
import { asyncWrapper } from '../../common/middlewares/async-wrapper.middleware.js';
import { authenticate } from '../auth/index.js';

const currencyRouter = Router();

/**
 * API endpoint: GET /api/currencies
 * Lấy danh sách các tiền tệ trong hệ thống
 */
currencyRouter.get(
  '/',
  authenticate,
  asyncWrapper(currencyController.getCurrencies),
);

export { currencyRouter };
