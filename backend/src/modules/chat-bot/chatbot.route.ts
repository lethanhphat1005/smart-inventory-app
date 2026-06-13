import { Router } from 'express';

import {
  chatbotBurstLimit,
  chatbotRateLimit,
} from './chatbot-rate-limit.middleware.js';
import { chatbotController, chatController } from './chatbot.module.js';
import {
  chatPayloadBodySchema,
  confirmActionBodySchema,
} from './chatbot.validator.js';
import { asyncWrapper } from '../../common/middlewares/async-wrapper.middleware.js';
import { validator } from '../../common/middlewares/validate.middleware.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../store-member/index.js';

const chatRouter = Router();

chatRouter.use(authenticate, requireStoreContext);

chatRouter.post(
  '/',
  chatbotBurstLimit,
  chatbotRateLimit,
  validator(chatPayloadBodySchema, 'body'),
  asyncWrapper(chatController.processChat),
);
chatRouter.post(
  '/confirm',
  validator(confirmActionBodySchema, 'body'),
  asyncWrapper(chatController.confirmAction),
);
chatRouter.delete('/history', asyncWrapper(chatbotController.clearHistory));

export { chatRouter, chatRouter as chatbotRouter };
