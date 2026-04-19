type ActiveStatus = 'active' | 'inactive';

export type ProductPackage = {
  productPackageId: string;
  displayName: string | null;
  importPrice: number | null;
  sellingPrice: number | null;
  variant: string | null;
  activeStatus: ActiveStatus;
  createdAt: Date;
  updatedAt: Date;
  unitId: string;
  productId: string;
};

export type Unit = {
  unitId: string;
  code: string;
  name: string;
};
