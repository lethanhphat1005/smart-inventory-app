import { beforeEach, describe, expect, it, vi } from 'vitest';

import { ChatMemoryService } from '../../../../src/modules/chat-bot/services/chat-memory.service.js';

type MockRedis = {
  get: ReturnType<typeof vi.fn>;
  set: ReturnType<typeof vi.fn>;
  del: ReturnType<typeof vi.fn>;
};

const createRedis = (): MockRedis => ({
  get: vi.fn(),
  set: vi.fn(),
  del: vi.fn(),
});

describe('ChatMemoryService', () => {
  let redis: MockRedis;
  let service: ChatMemoryService;

  beforeEach(() => {
    redis = createRedis();
    service = new ChatMemoryService(redis as never);
  });

  it('returns an empty history when Redis has no chat data', async () => {
    redis.get.mockResolvedValue(null);

    await expect(service.getChatHistory('store-1', 'user-1')).resolves.toEqual(
      [],
    );
  });

  it('saves only the newest twelve messages and removes leading tool messages', async () => {
    const previous = Array.from({ length: 11 }, (_, index) => ({
      role: index === 0 ? 'tool' : 'assistant',
      content: `old-${index}`,
      tool_call_id: index === 0 ? 'tool-1' : undefined,
    }));

    redis.get.mockResolvedValue(JSON.stringify(previous));

    await service.saveChatHistory('store-1', 'user-1', [
      { role: 'user', content: 'new-1' },
      { role: 'assistant', content: 'new-2' },
    ]);

    const savedPayload = JSON.parse(redis.set.mock.calls[0]?.[1] as string);

    expect(savedPayload).toHaveLength(12);
    expect(savedPayload[0].role).not.toBe('tool');
    expect(savedPayload.at(-1)).toEqual({
      role: 'assistant',
      content: 'new-2',
    });
    expect(redis.set).toHaveBeenCalledWith(
      'chatbot:history:store-1:user-1',
      expect.any(String),
      'EX',
      expect.any(Number),
    );
  });

  it('reads, saves, and clears cart sessions by store and user', async () => {
    const cart = {
      type: 'create_import',
      items: [
        {
          productPackageId: 'pkg-1',
          displayName: 'Milk',
          quantity: 2,
          unitPrice: 10000,
        },
      ],
    };

    redis.get.mockResolvedValue(JSON.stringify(cart));

    await expect(service.getCartSession('store-1', 'user-1')).resolves.toEqual(
      cart,
    );

    await service.saveCartSession('store-1', 'user-1', cart as never);
    await service.clearCartSession('store-1', 'user-1');

    expect(redis.set).toHaveBeenCalledWith(
      'chatbot:cart:store-1:user-1',
      JSON.stringify(cart),
      'EX',
      expect.any(Number),
    );
    expect(redis.del).toHaveBeenCalledWith('chatbot:cart:store-1:user-1');
  });
});
