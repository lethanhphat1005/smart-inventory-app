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
): ChatHistoryMessage[] => {
  // Lấy thời gian thực tại múi giờ Việt Nam
  const currentDate = new Date().toLocaleString('vi-VN', {
    timeZone: 'Asia/Ho_Chi_Minh',
    dateStyle: 'full',
    timeStyle: 'medium',
  });

  return [
    {
      role: 'system',
      content:
        getCoordinatorPrompt(storeId, userId) +
        `\n\n[SYSTEM TIME CONTEXT]: Thời gian hiện tại của hệ thống là ${currentDate}. BẠN PHẢI dùng mốc thời gian này để tính toán ngày tháng chính xác khi người dùng dùng các từ chỉ thời gian tương đối (hôm qua, hôm nay, tuần trước, tháng này...).`,
    },
    ...previousHistory,
    { role: 'user', content: userMessage },
  ];
};

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

export const buildUserDraftRefKey = (storeId: string, userId: string): string =>
  `${CHAT_DRAFT_KEY_PREFIX}ref:${storeId}:${userId}`;
