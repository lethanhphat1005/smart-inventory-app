import {
  HISTORY_SUMMARY_THRESHOLD,
  HISTORY_TTL_SECONDS,
} from '../chatbot.constants.js';
import { buildChatHistoryKey } from '../chatbot.mapper.js';

import type { CartSession, ChatHistoryMessage } from '../chatbot.type.js';
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
    newMessages: ChatHistoryMessage[],
  ): Promise<void> {
    let history = await this.getChatHistory(storeId, userId);

    history.push(...newMessages);

    if (history.length > HISTORY_SUMMARY_THRESHOLD) {
      // Giữ lại 4 message cuối, tóm tắt phần còn lại thành 1 system note
      const tail = history.slice(-4);
      const summarized = history
        .slice(0, -4)
        .filter((m) => m.role === 'user' || m.role === 'assistant')
        .map(
          (m) =>
            `[${m.role}]: ${typeof m.content === 'string' ? m.content.slice(0, 80) : ''}`,
        )
        .join('\n');

      history = [
        {
          role: 'system',
          content: `[CONVERSATION SUMMARY — earlier in this session]:\n${summarized}`,
        },
        ...tail,
      ];
    }

    await this.redisClient.set(
      buildChatHistoryKey(storeId, userId),
      JSON.stringify(history),
      'EX',
      HISTORY_TTL_SECONDS,
    );
  }

  async clearChatHistory(storeId: string, userId: string): Promise<void> {
    await this.redisClient.del(buildChatHistoryKey(storeId, userId));
  }

  private buildCartKey(storeId: string, userId: string): string {
    return `chatbot:cart:${storeId}:${userId}`;
  }

  async getCartSession(
    storeId: string,
    userId: string,
  ): Promise<CartSession | null> {
    const data = await this.redisClient.get(this.buildCartKey(storeId, userId));

    return data ? (JSON.parse(data) as CartSession) : null;
  }

  async saveCartSession(
    storeId: string,
    userId: string,
    cart: CartSession,
  ): Promise<void> {
    await this.redisClient.set(
      this.buildCartKey(storeId, userId),
      JSON.stringify(cart),
      'EX',
      3600,
    );
  }

  async clearCartSession(storeId: string, userId: string): Promise<void> {
    await this.redisClient.del(this.buildCartKey(storeId, userId));
  }
}
