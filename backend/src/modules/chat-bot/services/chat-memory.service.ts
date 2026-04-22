import {
  HISTORY_TTL_SECONDS,
  MAX_HISTORY_LENGTH,
} from '../chatbot.constants.js';
import { buildChatHistoryKey } from '../chatbot.mapper.js';

import type { ChatHistoryMessage } from '../chatbot.type.js';
import type { Redis } from 'ioredis';

export class ChatMemoryService {
  constructor(private readonly redisClient: Redis) {}

  async getChatHistory(
    storeId: string,
    userId: string,
  ): Promise<ChatHistoryMessage[]> {
    const data = await this.redisClient.get(
      buildChatHistoryKey(storeId, userId),
    );

    return data ? (JSON.parse(data) as ChatHistoryMessage[]) : [];
  }

  async saveChatHistory(
    storeId: string,
    userId: string,
    userMsg: string,
    assistantMsg: string,
  ): Promise<void> {
    let history = await this.getChatHistory(storeId, userId);

    history.push({ role: 'user', content: userMsg });
    history.push({ role: 'assistant', content: assistantMsg });

    if (history.length > MAX_HISTORY_LENGTH) {
      history = history.slice(history.length - MAX_HISTORY_LENGTH);
    }

    await this.redisClient.set(
      buildChatHistoryKey(storeId, userId),
      JSON.stringify(history),
      'EX',
      HISTORY_TTL_SECONDS,
    );
  }
}
