import type { InventoryItemData } from './chatbot.type.js';

export type ChatbotRequestDto = {
  message: string;
};

export type ChatbotResponseDto = {
  aiIntent: string;
  botReply: string;
  data?: InventoryItemData | InventoryItemData[] | AuditLogItemData[] | unknown;
};

export type AuditLogItemData = {
  action: string;
  target: string;
  userFullName: string;
  time: string;
};
