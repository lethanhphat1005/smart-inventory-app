import { Router } from 'express';

import { healthCheckController } from './health-check.module.js';

export const healthRouter = Router();

healthRouter.get('/', healthCheckController.getLiveness);
healthRouter.get('/ready', healthCheckController.getReadiness);
