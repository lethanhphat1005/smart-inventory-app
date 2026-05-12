// chatbot.module.ts
import { ChatbotController } from './chatbot.controller.js';
import { OpenAIProvider } from './llm/openai.provider.js';
import { ChatMemoryService } from './services/chat-memory.service.js';
import { ChatbotService } from './services/chatbot.service.js';
import { redisClient } from '../../db/redis.js';
import { auditLogService } from '../audit-log/audit-log.module.js';
import { inventoryService } from '../inventories/index.js';
import { transactionService } from '../transactions/index.js';

const chatMemoryService = new ChatMemoryService(redisClient);
const llmProvider = new OpenAIProvider();

// 2. Đảm bảo tham số thứ 6 truyền vào là instance đã được import ở trên
const chatService = new ChatbotService(
  inventoryService,
  transactionService,
  redisClient,
  chatMemoryService,
  llmProvider,
  auditLogService, // Bây giờ biến này đã có giá trị thay vì undefined
);

const chatController = new ChatbotController(chatService);

export {
  chatService,
  chatController,
  chatService as chatbotService,
  chatController as chatbotController,
};
