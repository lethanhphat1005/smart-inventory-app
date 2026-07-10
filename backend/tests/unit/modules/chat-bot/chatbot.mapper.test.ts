import { describe, expect, it } from 'vitest';

import {
  buildChatDraftKey,
  buildChatHistoryKey,
  buildChatLockKey,
  buildCoordinatorMessages,
  buildUserDraftRefKey,
  findExactInventoryMatch,
  normalizeInventoryName,
} from '../../../../src/modules/chat-bot/chatbot.mapper.js';

import type { InventoryItemData } from '../../../../src/modules/chat-bot/chatbot.type.js';

describe('chatbot mapper utilities', () => {
  it('builds Redis keys with store, user, and draft identifiers', () => {
    expect(buildChatHistoryKey('store-1', 'user-1')).toBe(
      'chatbot:history:store-1:user-1',
    );
    expect(buildChatLockKey('store-1', 'user-1')).toBe(
      'chatbot:lock:store-1:user-1',
    );
    expect(buildChatDraftKey('draft-1')).toBe('chatbot:draft:draft-1');
    expect(buildUserDraftRefKey('store-1', 'user-1')).toBe(
      'chatbot:draft:ref:store-1:user-1',
    );
  });

  it('normalizes inventory names for exact matching', () => {
    expect(normalizeInventoryName('Red Bull (Can)')).toBe('redbullcan');
  });

  it('finds exact inventory matches after normalization', () => {
    const items = [
      {
        quantity: 10,
        productPackage: {
          productPackageId: 'pkg-1',
          displayName: 'Red Bull (Can)',
          sellingPrice: 15000,
          importPrice: 10000,
          unit: { name: 'can' },
        },
      },
    ] satisfies InventoryItemData[];

    expect(findExactInventoryMatch(items, 'red bull can')).toBe(items[0]);
    expect(findExactInventoryMatch(items, 'sting')).toBeUndefined();
  });

  it('builds coordinator messages with system, prior history, and new user message', () => {
    const messages = buildCoordinatorMessages(
      'store-1',
      'user-1',
      [{ role: 'assistant', content: 'previous reply' }],
      'new request',
    );

    expect(messages[0]?.role).toBe('system');
    expect(messages[0]?.content).toContain('store-1');
    expect(messages[1]).toEqual({
      role: 'assistant',
      content: 'previous reply',
    });
    expect(messages[2]).toEqual({ role: 'user', content: 'new request' });
  });
});
