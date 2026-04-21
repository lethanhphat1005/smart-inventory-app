import { ChatbotController } from './chatbot.controller.js';
import { ChatbotService } from './chatbot.service.js';
import { redisClient } from '../../config/redis.js';
import { inventoryService } from '../inventories/index.js';
import { transactionService } from '../transactions/index.js';

const chatbotService = new ChatbotService(
  inventoryService,
  transactionService,
  redisClient,
);
const chatbotController = new ChatbotController(chatbotService);

export { chatbotService, chatbotController };
