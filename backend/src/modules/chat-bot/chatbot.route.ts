import { Router } from 'express';

import { chatbotRateLimit } from './chatbot-rate-limit.middleware.js';
import { chatbotController } from './chatbot.module.js';
import { chatPayloadSchema, confirmActionSchema } from './chatbot.validator.js';
import { asyncWrapper } from '../../common/middlewares/async-wrapper.middleware.js';
import { validator } from '../../common/middlewares/validate.middleware.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const chatbotRouter = Router();

chatbotRouter.use(authenticate, requireStoreContext);

chatbotRouter.post(
  '/',
  chatbotRateLimit,
  validator(chatPayloadSchema),
  asyncWrapper(chatbotController.processChat),
);
chatbotRouter.post(
  '/confirm',
  validator(confirmActionSchema),
  asyncWrapper(chatbotController.confirmAction),
);

export { chatbotRouter };
