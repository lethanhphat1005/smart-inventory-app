import { SmartDecisionController } from './controllers/smart-decision.controller.js';
import { SmartDecisionService } from './services/smart-decision.service.js';

const smartDecisionService = new SmartDecisionService();

const smartDecisionController = new SmartDecisionController(
  smartDecisionService,
);

export { smartDecisionService, smartDecisionController };
