import { SmartDecisionController } from './controllers/smart-decision.controller.js';
import { SmartAlertRepository } from './repositories/smart-alert.repository.js';
import { SmartDecisionRepository } from './repositories/smart-decision.repository.js';
import { SmartAlertService } from './services/smart-alert.service.js';
import { SmartDecisionService } from './services/smart-decision.service.js';
import { prisma } from '../../db/prismaClient.js';
import {
  NotificationRepository,
  NotificationService,
} from '../notification/index.js';

const smartDecisionRepository = new SmartDecisionRepository(prisma);
const smartDecisionService = new SmartDecisionService(smartDecisionRepository);

const smartDecisionController = new SmartDecisionController(
  smartDecisionService,
);

// tạo instance mới tránh circular dependency
const notificationRepository = new NotificationRepository();
const notificationService = new NotificationService(notificationRepository);

const smartAlertRepository = new SmartAlertRepository(prisma);
const smartAlertService = new SmartAlertService(
  notificationService,
  smartAlertRepository,
);

export { smartDecisionService, smartDecisionController, smartAlertService };
