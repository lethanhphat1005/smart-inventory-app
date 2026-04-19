export interface BatchInventoryPayload {
  storeId: string;
  items: Array<{
    inventoryId: string;
    oldQuantity: number;
    newQuantity: number;
  }>;
}

export interface SingleInventoryPayload {
  inventoryId: string;
  storeId: string;
  oldQuantity: number;
  newQuantity: number;
}

export interface DiscrepancyPayload {
  storeId: string;
  adjustmentId: string; // Đây chính là transactionId của phiếu kiểm kê
  items: DiscrepancyItem[];
}

export interface DiscrepancyItem {
  productName: string;
  systemQuantity: number;
  actualQuantity: number;
}

export interface LowStockInventoryItem {
  inventoryId: string;
  quantity: number;
  productPackage?: {
    displayName: string | null;
    product?: {
      storeId: string | null;
      productId: string;
    } | null;
  } | null;
}

export interface ReorderSuggestionItem {
  productId: string;
  productName: string;
  currentStock: number;
  suggestedQuantity: number;
  suggestedThreshold: number;
  reason: string;
}

export interface BatchReorderSuggestionPayload {
  storeId: string;
  suggestions: ReorderSuggestionItem[];
}
