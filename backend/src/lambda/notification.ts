import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../common/errors/custom-error.js';
import { logger, loadCronSecretsToEnvironment } from '../common/utils/index.js';
import { initFirebaseAdmin } from '../config/firebase.config.js';

// load secret từ SSM Parameter vào biến môi trường khi khởi tạo server
await loadCronSecretsToEnvironment();

// Khởi tạo firebase
await initFirebaseAdmin();

// Chỉ import các service sau khi database và Firebase đã sẵn sàng
const [{ smartAlertService }, { smartDecisionService }] = await Promise.all([
  import('../modules/alerts/services/smart-alert.service.js'),
  import('../modules/alerts/smart-decision.module.js'),
]);

type NotificationJobEvent = {
  job: 'generate-reorder-suggestions' | 'scan-low-stock';
};

export const handler = async (event: NotificationJobEvent): Promise<void> => {
  logger.info({ job: event.job }, '[EventBridge Notification] Job started');

  switch (event.job) {
    case 'generate-reorder-suggestions':
      await smartDecisionService.generateReorderSuggestions();
      break;

    case 'scan-low-stock':
      await smartAlertService.scanAllStoresForLowStock();
      break;

    default:
      throw new CustomError({
        status: StatusCodes.BAD_REQUEST,
        message: `Unknown notification job: ${String(event.job)}`,
      });
  }

  logger.info({ job: event.job }, '[EventBridge Notification] Job completed');
};
