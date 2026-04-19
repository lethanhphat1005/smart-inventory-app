import cron from 'node-cron';

import { smartAlertService } from '../modules/alerts/services/smart-alert.service.js';
import { smartDecisionService } from '../modules/alerts/smart-decision.module.js';

export const initCronJobs = () => {
  // 1. Vào 08:00 sáng: Phân tích và gợi ý nhập hàng (Planning)
  cron.schedule(
    // '*/1 * * * *',
    '0 8 * * *',
    async () => {
      console.info('[Cron] 08:00 AM - Generating reorder suggestions...');
      await smartDecisionService.generateReorderSuggestions();
    },
    {
      timezone: 'Asia/Ho_Chi_Minh',
    },
  );

  // 2. Vào 20:00 tối: Quét toàn bộ kho báo cáo hàng thấp (Review)
  cron.schedule(
    // '*/1 * * * *',
    '0 20 * * *',
    async () => {
      console.info('[Cron] Đang chạy kiểm tra tồn kho tự động...');
      await smartAlertService.scanAllStoresForLowStock();
    },
    {
      timezone: 'Asia/Ho_Chi_Minh',
    },
  );

  console.info('[Smart Cron Job] Đề xuất nhập hàng vào mỗi 8h hằng ngày!');
  console.info('[Smart Cron Job] Nhắc nhở hàng tồn kho vào mỗi 20h hằng ngày!');
};
