import { Router } from 'express';

import { notificationController } from './notification.module.js';
import {
  registerTokenBodySchema,
  removeTokenBodySchema,
} from './validators/notification.validator.js';
import { asyncWrapper, validator } from '../../common/middlewares/index.js';
import { authenticate } from '../auth/index.js';

const notificationRouter = Router();

notificationRouter.post(
  '/register-token',
  authenticate,
  validator(registerTokenBodySchema, 'body'),
  asyncWrapper(notificationController.registerToken),
);

notificationRouter.post(
  '/remove-token',
  authenticate,
  validator(removeTokenBodySchema, 'body'),
  asyncWrapper(notificationController.removeToken),
);

notificationRouter.post(
  '/test-send',
  authenticate,
  asyncWrapper(notificationController.testSend),
);

// Các route cho App
notificationRouter.get(
  '/',
  authenticate,
  asyncWrapper(notificationController.getNotifications),
);

notificationRouter.patch(
  '/:notificationId/read',
  authenticate,
  asyncWrapper(notificationController.markAsRead),
);

notificationRouter.delete(
  '/:notificationId',
  authenticate,
  asyncWrapper(notificationController.deleteNotification),
);

notificationRouter.patch(
  '/read-all',
  authenticate,
  asyncWrapper(notificationController.markAllAsRead),
);

export default notificationRouter;
