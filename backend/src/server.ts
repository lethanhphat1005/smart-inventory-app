import express from 'express';

import {
  errorHandler,
  pinoLogger,
  rateLimiter,
} from './common/middlewares/index.js';
import { initFirebaseAdmin } from './config/firebase.config.js';
import { initCronJobs } from './cron/index.js';
import { smartDecisionRouter } from './modules/alerts/index.js';
import { auditLogRouter } from './modules/audit-log/audit-log.route.js';
import {
  barcodeRouter,
  productPackageBarcodeRouter,
} from './modules/barcode/index.js';
import { categoryRouter } from './modules/categories/index.js';
import { chatRouter } from './modules/chat-bot/index.js';
import { currencyRouter } from './modules/currencies/index.js';
import { healthRouter } from './modules/health-check/index.js';
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

const app = express();
const port = 3000;

app.use(express.json());

app.use(pinoLogger);

// Khởi tạo firebase khi khởi động server
initFirebaseAdmin();

// Khởi tạo corn jobs quét tự động 8 đến 22h và mỗi 2 tiếng 1 lần
initCronJobs();

app.use('/api/health', healthRouter);

app.use(
  '/api/stores',
  rateLimiter({ windowMs: 60 * 1000, max: 60 }),
  storeRouter,
);

app.use(
  '/api/barcodes',
  rateLimiter({ windowMs: 60 * 1000, max: 30 }),
  barcodeRouter,
);

app.use('/api/products', rateLimiter({ windowMs: 60 * 1000, max: 120 }), [
  productRouter,
  productPackageProductRouter,
]);

app.use(
  '/api/categories',
  rateLimiter({ windowMs: 60 * 1000, max: 60 }),
  categoryRouter,
);

app.use(
  '/api/auth',
  rateLimiter({ windowMs: 15 * 60 * 1000, max: 10 }),
  userProfileRouter,
);

app.use(
  '/api/product-packages',
  rateLimiter({ windowMs: 60 * 1000, max: 120 }),
  [productPackageRouter, productPackageBarcodeRouter],
);

app.use(
  '/api/inventories',
  rateLimiter({ windowMs: 60 * 1000, max: 120 }),
  inventoryRouter,
);

app.use(
  '/api/transactions',
  rateLimiter({ windowMs: 60 * 1000, max: 60 }),
  transactionRouter,
);

app.use(
  '/api/audit-logs',
  rateLimiter({ windowMs: 60 * 1000, max: 30 }),
  auditLogRouter,
);

app.use(
  '/api/notification',
  rateLimiter({ windowMs: 60 * 1000, max: 120 }),
  notificationRouter,
);

app.use(
  '/api/search',
  rateLimiter({ windowMs: 60 * 1000, max: 60 }),
  searchRouter,
);

app.use(
  '/api/units',
  rateLimiter({ windowMs: 60 * 1000, max: 120 }),
  unitRouter,
);

app.use(
  '/api/store-members',
  rateLimiter({ windowMs: 60 * 1000, max: 30 }),
  storeMemberRouter,
);

app.use(
  '/api/chat-bot',
  rateLimiter({ windowMs: 60 * 1000, max: 10 }),
  chatRouter,
);

app.use(
  '/api/smart-decisions',
  rateLimiter({ windowMs: 60 * 1000, max: 30 }),
  smartDecisionRouter,
);

app.use(
  '/api/currencies',
  rateLimiter({ windowMs: 60 * 1000, max: 120 }),
  currencyRouter,
);

app.use(errorHandler);

app.listen(port, () => {
  console.info(`Server is running on http://localhost:${port}`);
});
