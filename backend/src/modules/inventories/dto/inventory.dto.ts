import type {
  ListPaginationQueryDto,
  PaginationResponseDto,
} from '../../../common/types/index.js';
import type {
  AdjustmentType,
  Inventory,
  InventoryStatus,
  ProductPackageSnapshot,
  ProductSnapshot,
  Unit,
} from '../inventory.type.js';

export type InventoryResponseDto = Inventory;

export type InventoryListItemDto = Omit<Inventory, 'productPackageId'> & {
  inventoryStatus: InventoryStatus;
  productPackage: ProductPackageSnapshot & {
    unit: Unit;
    product: ProductSnapshot;
  };
};

export type InventoryDetailResponseDto = InventoryListItemDto;

export type InventorySortBy =
  | 'updatedAt'
  | 'quantity'
  | 'reorderThreshold';

export type ListInventoriesQueryDto =
  ListPaginationQueryDto<InventorySortBy> & {
    keyword?: string;
    categoryId?: string;
    inventoryStatus?: InventoryStatus;
  };

export type ListInventoriesResponseDto =
  PaginationResponseDto<InventoryListItemDto>;

export type LowStockInventoriesResponseDto =
  PaginationResponseDto<InventoryListItemDto>;

export type UpdateInventoryDto = Partial<Pick<Inventory, 'reorderThreshold'>>;

export type InventoryAdjustmentItemDto = {
  productPackageId: string;
  type: AdjustmentType;
  quantity: number;
  reason?: string | null;
  note?: string | null;
};

export type BatchInventoryAdjustmentDto = {
  items: InventoryAdjustmentItemDto[];
};

export type InventoryAdjustmentResponseDto = {
  productPackageId: string;
  previousQuantity: number;
  currentQuantity: number;
  changedQuantity: number;
  adjustmentType: AdjustmentType;
  reason: string | null;
  note: string | null;
  updatedAt: Date;
};

export type CreateInventoryDto = {
  productPackageId: string;
  quantity: number;
  reorderThreshold?: number | null;
};

export type AdjustInventoryForTransactionDto = Pick<
  Inventory,
  'inventoryId' | 'productPackageId' | 'quantity'
> & {
  transactionQuantity: number;
  unitPrice: number;
  transactionId: string;
};

export type InventoryForTransactionData = Pick<
  Inventory,
  'productPackageId' | 'quantity'
> & {
  transactionId: string;
  unitPrice: number;
};
