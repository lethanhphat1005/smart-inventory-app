import type { InventoryItemData } from './chatbot.type.js';
import type { ReorderSuggestionItemDto } from '../alerts/index.js';

export type ChatbotRequestDto = {
  message: string;
  locale?: string;
};

export type ChatbotResponseDto = {
  aiIntent: string;
  botReply: string;
  data?:
    | InventoryItemData
    | InventoryItemData[]
    | AuditLogItemData[]
    | SmartSuggestionData
    | unknown;
};

export type AuditLogItemData = {
  action: string;
  target: string;
  userFullName: string;
  time: string;
};

export type SmartSuggestionData = {
  type: 'general_restock' | 'cross_sell';
  suggestions?: ReorderSuggestionItemDto[];
  crossSellItems?: { productName: string; frequency: number }[];
  targetProduct?: string;
};
