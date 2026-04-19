import { StatusCodes } from 'http-status-codes';

import { BarcodesService } from './services/barcodes.service.js';
import {
  requireReqStoreContext,
  sendResponse,
} from '../../common/utils/index.js';

import type {
  ConfirmBarcodeMappingRequestDto,
  ConfirmBarcodeMappingResponseDto,
  ScanBarcodeRequestDto,
  ScanBarcodeResponseDto,
} from './barcodes.dto.js';
import type { ScanBarcodeServiceResult } from './barcodes.type.js';
import type { ApiResponse } from '../../common/types/index.js';
import type { Request, Response } from 'express';

export class BarcodesController {
  constructor(private readonly barcodesService: BarcodesService) {}

  // chuyển data shape từ hàm service, chủ yếu là chuyển
  // ScanBarcodeServiceResult.candidates: BarcodeCandidatePackage[]
  //   -> ScanBarcodeResponseDto.candidates: ProductPackageResponseDto[]
  private mapScanResultToResponseDto(
    result: ScanBarcodeServiceResult,
  ): ScanBarcodeResponseDto {
    if (result.resolutionType === 'exact_match') {
      return {
        resolutionType: 'exact_match',
        productPackage: result.productPackage,
      };
    }

    if (result.resolutionType === 'candidate_match') {
      const prefill = result.prefill;

      return {
        resolutionType: 'candidate_match',
        candidates: result.candidates.map((candidate) => {
          return candidate.productPackage;
        }),
        ...(prefill !== undefined && {
          prefill,
        }),
      };
    }

    const prefill = result.prefill;

    return {
      resolutionType: 'not_found',
      ...(prefill !== undefined && {
        prefill,
      }),
    };
  }

  scanBarcode = async (
    req: Request,
    res: Response<ApiResponse<ScanBarcodeResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const requestData = req.body as ScanBarcodeRequestDto;

    const scanResult = await this.barcodesService.scanBarcode({
      storeId,
      barcode: requestData.barcode,
      ...(requestData.type !== undefined && {
        type: requestData.type,
      }),
    });

    sendResponse.success(res, this.mapScanResultToResponseDto(scanResult), {
      status: StatusCodes.OK,
    });
  };

  confirmBarcodeMapping = async (
    req: Request,
    res: Response<ApiResponse<ConfirmBarcodeMappingResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const requestData = req.body as ConfirmBarcodeMappingRequestDto;

    const barcodeMapping = await this.barcodesService.confirmBarcodeMapping({
      storeId,
      barcode: requestData.barcode,
      productPackageId: requestData.productPackageId,
      ...(requestData.type !== undefined && {
        type: requestData.type,
      }),
    });

    sendResponse.success(res, barcodeMapping, {
      status: StatusCodes.CREATED,
    });
  };
}
