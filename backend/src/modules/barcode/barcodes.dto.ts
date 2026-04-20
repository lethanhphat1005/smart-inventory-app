import { z } from 'zod';

import type { BarcodePrefill } from './barcodes.type.js';
import type {
  confirmBarcodeMappingBodySchema,
  scanBarcodeBodySchema,
  createProductPackageBarcodeMappingBodySchema,
  createProductPackageBarcodeMappingParamsSchema,
  removeProductPackageBarcodeMappingParamsSchema,
} from './barcodes.validator.js';
import type { ProductPackageBarcode } from '../../generated/prisma/client.js';
import type { ProductPackageResponseDto } from '../product-packages/index.js';

export type ScanBarcodeRequestDto = z.infer<typeof scanBarcodeBodySchema>;

export type ConfirmBarcodeMappingRequestDto = z.infer<
  typeof confirmBarcodeMappingBodySchema
>;

// output của controller trả về cho package(s) match
export type ScanBarcodeResponseDto =
  | {
      resolutionType: 'exact_match';
      productPackage: ProductPackageResponseDto;
    }
  | {
      resolutionType: 'candidate_match';
      candidates: ProductPackageResponseDto[];
      prefill?: BarcodePrefill;
    }
  | {
      resolutionType: 'not_found';
      prefill?: BarcodePrefill;
    };

// output service trả về cho confirm mapping
export type ConfirmBarcodeMappingResponseDto = Pick<
  ProductPackageBarcode,
  'barcode' | 'type' | 'source' | 'isVerified'
> & {
  confidence: number | null;
  productPackage: ProductPackageResponseDto;
};

export type CreatePackageBarcodeMappingRequestDto = z.infer<
  typeof createProductPackageBarcodeMappingBodySchema
>;

export type CreatePackageBarcodeMappingParamsDto = z.infer<
  typeof createProductPackageBarcodeMappingParamsSchema
>;

export type RemovePackageBarcodeMappingParamsDto = z.infer<
  typeof removeProductPackageBarcodeMappingParamsSchema
>;

export type CreatePackageBarcodeMappingResponseDto =
  ConfirmBarcodeMappingResponseDto;
