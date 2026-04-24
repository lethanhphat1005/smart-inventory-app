import type { InventoryItemData } from './chatbot.type.js';

export type ChatbotRequestDto = {
  message: string;
};

export type ChatbotResponseDto = {
  aiIntent: string;
  botReply: string;
  data?: InventoryItemData | unknown;
};
