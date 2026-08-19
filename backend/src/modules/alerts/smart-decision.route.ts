import { Router } from 'express';

import { smartDecisionController } from './alerts.module.js';
import { asyncWrapper } from '../../common/middlewares/async-wrapper.middleware.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../store-member/index.js';

const smartDecisionRouter = Router();

smartDecisionRouter.use(authenticate, requireStoreContext);

smartDecisionRouter.get(
  '/reorder-suggestions',
  asyncWrapper(smartDecisionController.getReorderSuggestions),
);

export { smartDecisionRouter };
