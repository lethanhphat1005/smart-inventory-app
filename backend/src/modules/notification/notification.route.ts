import { Router } from 'express';

import { NotificationController } from './controllers/notification.controller.js';
import { NotificationRepository } from './repositories/notification.repository.js';
import { NotificationService } from './services/notification.service.js';
import { authenticate } from '../auth/index.js';
import {
  registerTokenBodySchema,
  removeTokenBodySchema,
} from './validators/notification.validator.js';
import { asyncWrapper, validator } from '../../common/middlewares/index.js';

const notificationRouter = Router();
const repository = new NotificationRepository();

const service = new NotificationService(repository);
const controller = new NotificationController(service);

notificationRouter.post(
  '/register-token',
  authenticate,
  validator(registerTokenBodySchema, 'body'),
  asyncWrapper(controller.registerToken),
);

notificationRouter.post(
  '/remove-token',
  authenticate,
  validator(removeTokenBodySchema, 'body'),
  asyncWrapper(controller.removeToken),
);

notificationRouter.post(
  '/test-send',
  authenticate,
  asyncWrapper(controller.testSend),
);

// Các route cho App
notificationRouter.get(
  '/',
  authenticate,
  asyncWrapper(controller.getNotifications),
);

notificationRouter.patch(
  '/:notificationId/read',
  authenticate,
  asyncWrapper(controller.markAsRead),
);

notificationRouter.delete(
  '/:notificationId',
  authenticate,
  asyncWrapper(controller.deleteNotification),
);

notificationRouter.patch(
  '/read-all',
  authenticate,
  asyncWrapper(controller.markAllAsRead),
);

export default notificationRouter;
