import type {
  BarcodeType,
  BarcodeStatus,
  Prisma,
  PackageBarcodeSource,
  ProductPackage,
} from '../../generated/prisma/client.js';
import type { ProductPackageResponseDto } from '../product-packages/index.js';

export type ProductPackageInput = Omit<
  ProductPackage,
  'activeStatus' | 'createdAt' | 'updatedAt'
>;

export type ScanBarcodeResolutionType =
  | 'exact_match'
  | 'candidate_match'
  | 'not_found';

export type BarcodePrefill = {
  name?: string;
  brand?: string;
  packageText?: string;
};

// kết quả được chuẩn hóa từ API barcode
export type NormalizedBarcodeData = {
  normalizedName?: string;
  normalizedBrand?: string;
  normalizedPackageText?: string;
};

// lớp abstraction query từ API barcode
export type BarcodeLookupProviderResult = {
  rawPayload: unknown;
  status: BarcodeStatus;
  provider?: string;
  type?: BarcodeType;
  normalizedName?: string;
  normalizedBrand?: string;
  normalizedPackageText?: string;
};

export type BarcodeApiCacheUpsertInput = {
  barcode: string;
  payload: Prisma.InputJsonObject;
  status: BarcodeStatus;
  provider?: string;
  type?: BarcodeType;
  normalizedName?: string;
  normalizedBrand?: string;
  normalizedPackageText?: string;
};

// chấm điểm candidate matching
export type BarcodeCandidateScoreDetail = {
  isBrandMatch: boolean;
  isNameMatch: boolean;
  isPackageTextMatch: boolean;
  brandScore: number;
  nameScore: number;
  packageTextScore: number;
  finalScore: number;
  threshold: number;
  availableSignalCount: number;
};

// data package mà service trả về
export type BarcodeCandidatePackage = {
  productPackageId: string;
  score: number;
  scoreDetail: BarcodeCandidateScoreDetail;
  productPackage: ProductPackageResponseDto;
};

/* output của service trả về cho package(s) match
- nếu match 100% -> trả về data package đó
- nếu match tương đối -> trả về các package gần match
- nếu không match package nào -> trả về data (đã chuẩn hoá) từ API barcode */
export type ScanBarcodeServiceResult =
  | {
      resolutionType: 'exact_match';
      productPackage: ProductPackageResponseDto;
    }
  | {
      resolutionType: 'candidate_match';
      candidates: BarcodeCandidatePackage[];
      prefill?: BarcodePrefill;
    }
  | {
      resolutionType: 'not_found';
      prefill?: BarcodePrefill;
    };

// các input của service
export type ScanBarcodeInput = {
  storeId: string;
  barcode: string;
  type?: BarcodeType;
};

export type CreateBarcodeMappingInput = {
  barcode: string;
  productPackageId: string;
  source: PackageBarcodeSource;
  isVerified: boolean;
  confidence?: Prisma.Decimal | number;
  type?: BarcodeType;
};

export type ConfirmBarcodeMappingInput = ScanBarcodeInput & {
  productPackageId: string;
};

export type CreateBarcodeMappingForNewPackageInput = ConfirmBarcodeMappingInput;

export type RemoveProductPackageBarcodeMappingInput = {
  storeId: string;
  productPackageId: string;
  barcode: string;
};

export type TokenMatchResult = {
  matchedTokenCount: number;
  expectedTokenCount: number;
  actualTokenCount: number;
  overlapRatio: number;
  isMatch: boolean;
};
