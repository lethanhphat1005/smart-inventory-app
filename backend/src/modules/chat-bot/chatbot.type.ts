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
  action_type?: string;
  keyword?: string;
  time_period?: string;
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

export interface AuditLogItemData {
  action: string;
  target: string;
  userFullName: string;
  time: string;
}

export interface AuditLogDetails {
  displayName?: string;
  productName?: string;
  name?: string;
}

export interface AuditLogRecord {
  actionType: string;
  entityType: string;
  note: string | null | undefined;
  newValue: string | Record<string, unknown> | null | undefined;
  performedAt: string | number | Date;
  user?: {
    fullName?: string | null;
  } | null;
}

export interface CrossSellItem {
  productName?: string | null;
  associatedPackageId: string;
  frequency: number;
}
