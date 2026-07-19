import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../common/errors/custom-error.js';
import { logger } from '../common/utils/logger.util.js';
import { initFirebaseAdmin } from '../config/firebase.config.js';
import { smartAlertService } from '../modules/alerts/services/smart-alert.service.js';
import { smartDecisionService } from '../modules/alerts/smart-decision.module.js';

// Khởi tạo firebase khi khởi động server
await initFirebaseAdmin();

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
