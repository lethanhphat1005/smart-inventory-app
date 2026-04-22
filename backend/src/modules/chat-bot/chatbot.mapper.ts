import {
  CHAT_DRAFT_KEY_PREFIX,
  CHAT_HISTORY_KEY_PREFIX,
  CHAT_LOCK_KEY_PREFIX,
} from './chatbot.constants.js';
import { getCoordinatorPrompt } from './chatbot.prompt.js';

import type { ChatHistoryMessage, InventoryItemData } from './chatbot.type.js';

export const buildChatHistoryKey = (storeId: string, userId: string): string =>
  `${CHAT_HISTORY_KEY_PREFIX}${storeId}:${userId}`;

export const buildChatLockKey = (storeId: string, userId: string): string =>
  `${CHAT_LOCK_KEY_PREFIX}${storeId}:${userId}`;

export const buildChatDraftKey = (draftId: string): string =>
  `${CHAT_DRAFT_KEY_PREFIX}${draftId}`;

export const buildCoordinatorMessages = (
  storeId: string,
  userId: string,
  previousHistory: ChatHistoryMessage[],
  userMessage: string,
): ChatHistoryMessage[] => [
  { role: 'system', content: getCoordinatorPrompt(storeId, userId) },
  ...previousHistory,
  { role: 'user', content: userMessage },
];

export const normalizeInventoryName = (str?: string | null): string =>
  (str || '').toLowerCase().replace(/[\s()-]/g, '');

export const findExactInventoryMatch = (
  items: InventoryItemData[],
  keyword: string,
): InventoryItemData | undefined =>
  items.find(
    (item) =>
      normalizeInventoryName(item.productPackage.displayName) ===
      normalizeInventoryName(keyword),
  );
