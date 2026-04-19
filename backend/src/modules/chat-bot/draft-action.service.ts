export interface TransactionItemPayload {
  productPackageId: string;
  quantity: number;
  unitPrice: number;
}

export interface TransactionPayload {
  note: string;
  items: TransactionItemPayload[];
}

export type DraftAction = {
  id: string;
  type: 'create_import' | 'create_export';
  storeId: string;
  userId: string;
  // Thay thế any bằng TransactionPayload
  payload: TransactionPayload;
  createdAt: number;
};
