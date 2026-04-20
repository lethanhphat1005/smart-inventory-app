import { Router } from 'express';

import { chatbotRateLimit } from './chatbot-rate-limit.middleware.js';
import { chatbotController } from './chatbot.module.js';
import { asyncWrapper } from '../../common/middlewares/async-wrapper.middleware.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const chatbotRouter = Router();

chatbotRouter.use(authenticate, requireStoreContext);

chatbotRouter.post(
  '/',
  chatbotRateLimit,
  asyncWrapper(chatbotController.processChat),
);
chatbotRouter.post('/confirm', asyncWrapper(chatbotController.confirmAction));

export { chatbotRouter };
