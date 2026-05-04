import { Router } from 'express';

import {
  chatbotBurstLimit,
  chatbotRateLimit,
} from './chatbot-rate-limit.middleware.js';
import { chatController } from './chatbot.module.js';
import { chatPayloadSchema, confirmActionSchema } from './chatbot.validator.js';
import { asyncWrapper } from '../../common/middlewares/async-wrapper.middleware.js';
import { validator } from '../../common/middlewares/validate.middleware.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const chatRouter = Router();

chatRouter.use(authenticate, requireStoreContext);

chatRouter.post(
  '/',
  chatbotBurstLimit,
  chatbotRateLimit,
  validator(chatPayloadSchema),
  asyncWrapper(chatController.processChat),
);
chatRouter.post(
  '/confirm',
  validator(confirmActionSchema),
  asyncWrapper(chatController.confirmAction),
);

export { chatRouter, chatRouter as chatbotRouter };
