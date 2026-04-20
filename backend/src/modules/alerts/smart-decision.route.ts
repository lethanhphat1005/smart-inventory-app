import { Router } from 'express';

import { smartDecisionController } from './smart-decision.module.js';
import { asyncWrapper } from '../../common/middlewares/async-wrapper.middleware.js';
import { authenticate } from '../auth/index.js';
import { requireStoreContext } from '../stores/index.js';

const smartDecisionRouter = Router();

smartDecisionRouter.use(authenticate);
smartDecisionRouter.use(requireStoreContext);

smartDecisionRouter.get(
  '/reorder-suggestions',
  asyncWrapper(smartDecisionController.getReorderSuggestions),
);

export { smartDecisionRouter };
