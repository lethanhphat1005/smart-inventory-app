import { z } from 'zod';

import type { ProductPackage, Unit } from './product-package.type.js';
import type { listPackageQuerySchema } from './product-package.validator.js';
import type { PaginationResponseDto } from '../../common/types/pagination.type.js';
import type { Category } from '../categories/index.js';
import type { CreateInventoryDto, Inventory } from '../inventories/index.js';
import type { Product } from '../products/index.js';

export type UnitResponseDto = Unit;

export type ProductPackageResponseDto = Omit<
  ProductPackage,
  'activeStatus' | 'createdAt' | 'updatedAt'
>;

export type ProductPackageSimpleResponseDto = Pick<
  ProductPackage,
  'productPackageId' | 'displayName' | 'variant'
>;

export type ProductPackageDetailResponseDto = Omit<
  ProductPackage,
  'unitId' | 'productId' | 'activeStatus' | 'updatedAt'
> & {
  unit: Unit;
  category: Pick<Category, 'categoryId' | 'name'>;
  product: Pick<Product, 'productId' | 'imageUrl'>;
  inventory: Pick<
    Inventory,
    'inventoryId' | 'quantity' | 'reorderThreshold'
  > | null;
};

export type ProductPackageResponseForTransaction = Pick<
  ProductPackage,
  | 'productPackageId'
  | 'displayName'
  | 'variant'
  | 'importPrice'
  | 'sellingPrice'
>;

type CreateProductPackageDto = Pick<ProductPackage, 'unitId'> &
  Partial<Pick<ProductPackage, 'variant' | 'importPrice' | 'sellingPrice'>>;

export type CreateProductPackageInput = CreateProductPackageDto &
  Pick<ProductPackage, 'displayName' | 'productId'>;

export type CreateInventoryInput = Pick<
  CreateInventoryDto,
  'quantity' | 'reorderThreshold'
>;

export type CreateProductPackageAndInventoryDto = {
  package: CreateProductPackageDto;
  inventory: CreateInventoryDto;
};

/* Response của hàm create Package&Inventory để tránh warning DeprecationWarning
Calling client.query() when the client is already executing a query
is deprecated and will be removed in pg@9.0.
Use async/await or an external async flow control mechanism instead. */
export type CreatePackageAndInventoryResponseDto = Omit<
  ProductPackageDetailResponseDto,
  'unit' | 'category' | 'product'
> &
  Pick<ProductPackage, 'productId' | 'unitId'>;

export type UpdateProductPackageInput = Partial<
  Pick<
    ProductPackage,
    'displayName' | 'variant' | 'importPrice' | 'sellingPrice' | 'unitId'
  >
>;

export type UpdateProductPackageDto = Partial<
  Pick<ProductPackage, 'variant' | 'importPrice' | 'sellingPrice' | 'unitId'>
>;

/* Thừa kế type dựa trên schema Zod listPackageQuerySchema
Kết quả:
type PackageQueryDto = {
  page: number;
  limit: number;
  sortBy: 'displayName' | 'createdAt' | 'updatedAt';
  sortOrder: 'asc' | 'desc';
  categoryId?: string;
}; */
export type PackageQueryDto = z.infer<typeof listPackageQuerySchema>;

export type ListProductPackagesResponseDto =
  PaginationResponseDto<ProductPackageDetailResponseDto>;

// data trả về khi query barcode
export type BarcodeCandidateRecord = {
  productName: string;
  brand: string | null;
  productPackage: ProductPackageResponseDto;
};
