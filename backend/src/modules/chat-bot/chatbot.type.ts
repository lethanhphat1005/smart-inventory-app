import type { OpenAI } from 'openai';

export type DraftActionType = 'create_import' | 'create_export';

export type ChatHistoryMessage = OpenAI.Chat.ChatCompletionMessageParam;

export interface LLMProductItem {
  product_name: string;
  quantity: number;
}

export interface LLMToolParams {
  product_name?: string;
  quantity?: number;
  products?: LLMProductItem[];
}

export interface TransactionItemPayload {
  productPackageId: string;
  quantity: number;
  unitPrice: number;
}

export interface TransactionPayload {
  note: string;
  items: TransactionItemPayload[];
}

export interface DraftAction {
  id: string;
  type: DraftActionType;
  storeId: string;
  userId: string;
  payload: TransactionPayload;
  createdAt: number;
}

export interface InventoryPackageData {
  productPackageId: string;
  displayName: string;
  sellingPrice: number | string;
  importPrice: number | string;
  unit: { name: string };
}

export interface InventoryItemData {
  quantity: number;
  reorder_threshold?: number;
  reorderThreshold?: number;
  productPackage: InventoryPackageData;
}

export interface CartItem {
  productPackageId: string;
  displayName: string;
  quantity: number;
  unitPrice: number;
}

export interface CartSession {
  type: DraftActionType;
  items: CartItem[];
}
