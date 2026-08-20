import cron from 'node-cron';

import {
  smartDecisionService,
  smartAlertService,
} from '../modules/alerts/index-cron.js';

export const initCronJobs = () => {
  // 1. Vào 08:00 sáng: Phân tích và gợi ý nhập hàng (Planning)
  cron.schedule(
    '0 8 * * *',
    async () => {
      // console.info('[Cron] 08:00 AM - Generating reorder suggestions...');
      await smartDecisionService.generateReorderSuggestions();
    },
    {
      timezone: 'Asia/Ho_Chi_Minh',
    },
  );

  // 2. Vào 20:00 tối: Quét toàn bộ kho báo cáo hàng thấp (Review)
  cron.schedule(
    '0 20 * * *',
    async () => {
      // console.info('[Cron] Đang chạy kiểm tra tồn kho tự động...');
      await smartAlertService.scanAllStoresForLowStock();
    },
    {
      timezone: 'Asia/Ho_Chi_Minh',
    },
  );

  console.info('[Smart Cron Job] Suggested restock time: 8:00 AM every day');
  console.info('[Smart Cron Job] Inventory reminder at 8:00 PM every day');
};
