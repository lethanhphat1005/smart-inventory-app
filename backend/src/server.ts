import express from 'express';

import { errorHandler, pinoLogger } from './common/middlewares/index.js';
import { sendResponse } from './common/utils/index.js';
import { initFirebaseAdmin } from './config/firebase.config.js';
import { initCronJobs } from './cron/index.js';
import { smartDecisionRouter } from './modules/alerts/index.js';
import { auditLogRouter } from './modules/audit-log/audit-log.route.js';
import { barcodeRouter } from './modules/barcode/index.js';
import { categoryRouter } from './modules/categories/index.js';
import { inventoryRouter } from './modules/inventories/inventory.route.js';
import notificationRouter from './modules/notification/notification.route.js';
import {
  productPackageRouter,
  productPackageProductRouter,
} from './modules/product-packages/index.js';
import { unitRouter } from './modules/product-packages/routes/unit.route.js';
import { productRouter } from './modules/products/index.js';
import { searchRouter } from './modules/search/index.js';
import { storeMemberRouter } from './modules/store-member/store-member.route.js';
import { storeRouter } from './modules/stores/index.js';
import { transactionRouter } from './modules/transactions/index.js';
import { userProfileRouter } from './modules/user-profile/index.js';

import type { ApiResponse } from './common/types/index.js';
import type { Request, Response } from 'express';

const app = express();
const port = 3000;

app.use(express.json());

app.use(pinoLogger);

// Khởi tạo firebase khi khởi động server
initFirebaseAdmin();

// Khởi tạo corn jobs quét tự động 8 đến 22h và mỗi 2 tiếng 1 lần
initCronJobs();

app.get('/api/health', (_req: Request, res: Response<ApiResponse<null>>) => {
  sendResponse.success(res, null, { message: 'ok' });
});

app.use('/api/stores', storeRouter);
app.use('/api/barcodes', barcodeRouter);
app.use('/api/products', [productRouter, productPackageProductRouter]);
app.use('/api/categories', categoryRouter);
app.use('/api/auth', userProfileRouter);
app.use('/api/product-packages', productPackageRouter);
app.use('/api/inventories', inventoryRouter);
app.use('/api/transactions', transactionRouter);
app.use('/api/audit-logs', auditLogRouter);
app.use('/api/notification', notificationRouter);
app.use('/api/search', searchRouter);
app.use('/api/units', unitRouter);
app.use('/api/store-members', storeMemberRouter);
app.use('/api/smart-decisions', smartDecisionRouter);

app.use(errorHandler);

app.listen(port, () => {
  console.info(`Server is running on http://localhost:${port}`);
});
