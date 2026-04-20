export type InventoryStatus = 'inStock' | 'lowStock' | 'outOfStock';

export type AdjustmentType = 'set' | 'increase' | 'decrease';

export type Inventory = {
  inventoryId: string;
  quantity: number;
  reorderThreshold: number | null;
  updatedAt: Date;
  productPackageId: string;
};

export type Unit = {
  unitId: string;
  code: string;
  name: string;
};

// NOTE: Cấu trúc Snapshot đại diện cho dữ liệu đã được
// làm phẳng (flatten) từ các bảng liên kết
export type ProductPackageSnapshot = {
  productPackageId: string;
  displayName: string | null;
  importPrice: number | null;
  sellingPrice: number | null;
};

export type ProductSnapshot = {
  productId: string;
  name: string;
  imageUrl: string | null;
  brand: string | null;
  category: {
    categoryId: string;
    name: string;
    description: string | null;
  };
};
