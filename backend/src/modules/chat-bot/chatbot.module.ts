import { ChatbotController } from './chatbot.controller.js';
import { OpenAIProvider } from './llm/openai.provider.js';
import { ChatMemoryService } from './services/chat-memory.service.js';
import { ChatbotService } from './services/chatbot.service.js';
import { redisClient } from '../../db/redis.js';
import { smartDecisionService } from '../alerts/smart-decision.module.js';
import { auditLogService } from '../audit-log/audit-log.module.js';
import { inventoryService } from '../inventories/index.js';
import { storeMemberRepository } from '../store-member/store-member.module.js';
import { transactionService } from '../transactions/index.js';

const chatMemoryService = new ChatMemoryService(redisClient);
const llmProvider = new OpenAIProvider();

const chatService = new ChatbotService(
  inventoryService,
  transactionService,
  redisClient,
  chatMemoryService,
  llmProvider,
  auditLogService,
  storeMemberRepository,
  smartDecisionService,
);

const chatController = new ChatbotController(chatService);

export {
  chatService,
  chatController,
  chatService as chatbotService,
  chatController as chatbotController,
};
