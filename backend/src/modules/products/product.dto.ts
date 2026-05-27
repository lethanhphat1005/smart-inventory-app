import { z } from 'zod';

import type { Product } from './product.type.js';
import type { listProductsQuerySchema } from './product.validator.js';
import type { PaginationResponseDto } from '../../common/types/index.js';
import type { Category } from '../categories/index.js';
import type { ProductPackage, Unit } from '../product-packages/index.js';

export type ProductSimpleResponseDto = Omit<
  Product,
  'activeStatus' | 'createdAt' | 'updatedAt'
>;

export type ProductsByCategoryDto = {
  count: number;
  products: Omit<ProductSimpleResponseDto, 'storeId' | 'categoryId'>[];
};

export type ProductResponseDto = Omit<Product, 'categoryId'> & {
  category: Omit<Category, 'description' | 'storeId' | 'isDefault'>;
};

type ProductPackageItemDto = Omit<
  ProductPackage,
  'activeStatus' | 'createdAt' | 'updatedAt' | 'unitId' | 'productId'
> & {
  unit: Omit<Unit, 'code'>;
  inventory: {
    inventoryId: string;
    quantity: number;
    reorderThreshold: number | null;
  } | null;
};

export type DetailProductResponseDto = ProductResponseDto & {
  productPackages: ProductPackageItemDto[];
};

export type CreateProductDto = Pick<Product, 'name' | 'categoryId'> & {
  imageUrl?: string | null;
  brand?: string | null;
};

export type CreateProductData = CreateProductDto & {
  storeId: string;
};

export type UpdateProductDto = Partial<
  Pick<Product, 'brand' | 'imageUrl' | 'name' | 'categoryId'>
>;

export type ListProductsQueryDto = z.infer<typeof listProductsQuerySchema>;

export type ProductListItemDto = ProductResponseDto;

export type ListProductsResponseDto = PaginationResponseDto<ProductListItemDto>;
