import { z } from 'zod';

import type { searchByKeywordQuerySchema } from './search.validator.js';
import type { PaginationResponseDto } from '../../common/types/index.js';
import type { Prisma } from '../../generated/prisma/client.js';
import type { Product } from '../products/index.js';

export type SearchByKeywordQueryDto = z.infer<
  typeof searchByKeywordQuerySchema
>;

export type SearchByBarcodeQueryDto = {
  barcode: string;
};

export type SearchByPrefixQueryDto = {
  prefix: string;
  limit?: number;
};

export type SearchProductPackageItemDto = {
  productId: string;
  productName: string;
  imageUrl: string | null;
  brand: string | null;

  categoryId: string;
  categoryName: string;

  productPackageId: string;
  displayName: string | null;
  importPrice: number | null;
  sellingPrice: number | null;

  quantity: number | null;
  reorderThreshold: number | null;

  unitId: string;
  unitCode: string;
  unitName: string;
};

// đại diện cho kết quả trả về từ Prisma
// nên importPrice, sellingPrice cần để Prisma.Decimal
// vì $queryRaw trả về raw result, không tự map kiểu như findMany(),...
export type SearchProductPackageRow = Omit<
  SearchProductPackageItemDto,
  'importPrice' | 'sellingPrice'
> & {
  importPrice: Prisma.Decimal | null;
  sellingPrice: Prisma.Decimal | null;
  rank?: number;
};

export type SearchCountRow = {
  total: bigint;
};

export type SearchProductItemDto = {
  productId: string;
  productName: string;
  imageUrl: string | null;
  brand: string | null;
  categoryId: string;
  categoryName: string;
};

export type SearchProductRow = SearchProductItemDto & {
  rank?: number;
};

export type ListProductPackageByKeywordResponseDto =
  PaginationResponseDto<SearchProductPackageItemDto>;

export type ListProductByKeywordResponseDto =
  PaginationResponseDto<SearchProductItemDto>;

export type SearchProductPrefixResponseDto = Pick<
  Product,
  'productId' | 'name' | 'brand' | 'imageUrl'
>;
