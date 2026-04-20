import { StatusCodes } from 'http-status-codes';

import {
  requireReqStoreContext,
  requireReqUser,
  sendResponse,
} from '../../../common/utils/index.js';
import { ProductPackageService } from '../services/product-package.service.js';

import type { ApiResponse } from '../../../common/types/index.js';
import type {
  CreateProductPackageAndInventoryDto,
  ListProductPackagesResponseDto,
  PackageQueryDto,
  ProductPackageDetailResponseDto,
  ProductPackageResponseDto,
  UpdateProductPackageDto,
  CreatePackageAndInventoryResponseDto,
} from '../product-package.dto.js';
import type { Request, Response } from 'express';

export class ProductPackageController {
  constructor(private readonly productPackageService: ProductPackageService) {}

  getProductPackagesByStore = async (
    req: Request,
    res: Response<ApiResponse<ListProductPackagesResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;

    const productPackages =
      await this.productPackageService.getProductPackagesByStore(
        storeId,
        res.locals.validatedQuery as unknown as PackageQueryDto,
      );

    sendResponse.success(res, productPackages, {
      status: StatusCodes.OK,
    });
  };

  getProductPackagesByProductId = async (
    req: Request,
    res: Response<ApiResponse<ProductPackageDetailResponseDto[]>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { productId } = req.params;

    const productPackages =
      await this.productPackageService.getProductPackagesByProductId(
        storeId,
        productId as string,
      );

    sendResponse.success(res, productPackages, {
      status: StatusCodes.OK,
    });
  };

  getProductPackageById = async (
    req: Request,
    res: Response<ApiResponse<ProductPackageDetailResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { productPackageId } = req.params;

    const productPackage =
      await this.productPackageService.getProductPackageById(
        storeId,
        productPackageId as string,
      );

    sendResponse.success(res, productPackage, {
      status: StatusCodes.OK,
    });
  };

  createProductPackage = async (
    req: Request,
    res: Response<ApiResponse<CreatePackageAndInventoryResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const { productId } = req.params;

    const productPackage =
      await this.productPackageService.createProductPackageAndInventory(
        storeId,
        userId,
        productId as string,
        req.body as CreateProductPackageAndInventoryDto,
      );

    sendResponse.success(res, productPackage, {
      status: StatusCodes.CREATED,
    });
  };

  updateProductPackage = async (
    req: Request,
    res: Response<ApiResponse<ProductPackageResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const { productPackageId } = req.params;

    const productPackage =
      await this.productPackageService.updateProductPackage(
        storeId,
        userId,
        productPackageId as string,
        req.body as UpdateProductPackageDto,
      );

    sendResponse.success(res, productPackage, {
      status: StatusCodes.OK,
    });
  };

  softDeleteProductPackage = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const { productPackageId } = req.params;

    await this.productPackageService.softDeleteProductPackage(
      storeId,
      userId,
      productPackageId as string,
    );

    sendResponse.success(res, null, {
      status: StatusCodes.OK,
    });
  };
}
