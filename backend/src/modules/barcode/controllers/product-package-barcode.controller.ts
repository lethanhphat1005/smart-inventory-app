import { StatusCodes } from 'http-status-codes';

import {
  requireReqStoreContext,
  sendResponse,
} from '../../../common/utils/index.js';
import { ProductPackageBarcodeService } from '../services/product-package-barcode.service.js';

import type { ApiResponse } from '../../../common/types/index.js';
import type {
  CreatePackageBarcodeMappingRequestDto,
  CreatePackageBarcodeMappingResponseDto,
  RemovePackageBarcodeMappingParamsDto,
  CreatePackageBarcodeMappingParamsDto,
} from '../barcodes.dto.js';
import type { Request, Response } from 'express';

export class ProductPackageBarcodeController {
  constructor(
    private readonly packageBarcodeService: ProductPackageBarcodeService,
  ) {}

  createPackageBarcode = async (
    req: Request,
    res: Response<ApiResponse<CreatePackageBarcodeMappingResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { productPackageId } =
      req.params as CreatePackageBarcodeMappingParamsDto;
    const requestData = req.body as CreatePackageBarcodeMappingRequestDto;

    const barcodeMapping =
      await this.packageBarcodeService.createPackageBarcodeMapping({
        storeId,
        productPackageId,
        barcode: requestData.barcode,
        ...(requestData.type !== undefined && {
          type: requestData.type,
        }),
      });

    sendResponse.success(res, barcodeMapping, {
      status: StatusCodes.CREATED,
    });
  };

  deletePackageBarcode = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { productPackageId, barcode } =
      req.params as RemovePackageBarcodeMappingParamsDto;

    await this.packageBarcodeService.removePackageBarcodeMapping({
      storeId,
      productPackageId,
      barcode,
    });

    sendResponse.success(res, null, {
      status: StatusCodes.OK,
    });
  };
}
