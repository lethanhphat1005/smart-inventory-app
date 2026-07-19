import { app } from './app.js';
import { initFirebaseAdmin } from './config/firebase.config.js';
import { initCronJobs } from './cron/index.js';

const port = 3000;

// Khởi tạo firebase khi khởi động server
await initFirebaseAdmin();

// Khởi tạo corn jobs quét tự động 8 đến 22h và mỗi 2 tiếng 1 lần
initCronJobs();

app.listen(port, () => {
  console.info(`Server is running on http://localhost:${port}`);
});
