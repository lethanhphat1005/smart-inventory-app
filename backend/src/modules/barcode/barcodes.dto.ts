import { z } from 'zod';

import type { BarcodePrefill } from './barcodes.type.js';
import type {
  confirmBarcodeMappingBodySchema,
  scanBarcodeBodySchema,
} from './barcodes.validator.js';
import type {
  BarcodeType,
  PackageBarcodeSource,
} from '../../generated/prisma/client.js';
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
export type ConfirmBarcodeMappingResponseDto = {
  barcode: string;
  type: BarcodeType | null;
  source: PackageBarcodeSource;
  isVerified: boolean;
  productPackage: ProductPackageResponseDto;
};
