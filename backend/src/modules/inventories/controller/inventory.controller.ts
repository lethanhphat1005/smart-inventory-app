import { StatusCodes } from 'http-status-codes';

import {
  requireReqStoreContext,
  requireReqUser,
  sendResponse,
} from '../../../common/utils/index.js';
import { InventoryService } from '../service/inventory.service.js';

import type { ApiResponse } from '../../../common/types/index.js';
import type {
  BatchInventoryAdjustmentDto,
  CreateInventoryDto,
  InventoryAdjustmentResponseDto,
  InventoryDetailResponseDto,
  ListInventoriesQueryDto,
  ListInventoriesResponseDto,
  LowStockInventoriesResponseDto,
  UpdateInventoryDto,
} from '../dto/inventory.dto.js';
import type { Request, Response } from 'express';

/* Controller xử lý các luồng request liên quan đến quản lý kho (Inventory),
bao gồm tra cứu, thiết lập cấu hình và
điều chỉnh số lượng tồn kho thực tế của cửa hàng. */
export class InventoryController {
  constructor(private readonly inventoryService: InventoryService) {}

  getInventories = async (
    req: Request,
    res: Response<ApiResponse<ListInventoriesResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;

    const inventories = await this.inventoryService.getInventoriesByStoreId(
      storeId,
      res.locals.validatedQuery as unknown as ListInventoriesQueryDto,
    );

    sendResponse.success(res, inventories, { status: StatusCodes.OK });
  };

  getLowStockInventories = async (
    req: Request,
    res: Response<ApiResponse<LowStockInventoriesResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;

    // Truy vấn danh sách các mặt hàng có số lượng chạm
    // hoặc dưới mức cảnh báo (reorderThreshold)
    const inventories =
      await this.inventoryService.getLowStockInventoriesByStoreId(
        storeId,
        res.locals.validatedQuery as unknown as ListInventoriesQueryDto,
      );

    sendResponse.success(res, inventories, { status: StatusCodes.OK });
  };

  getInventoryByProductPackageId = async (
    req: Request,
    res: Response<ApiResponse<InventoryDetailResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { productPackageId } = req.params;

    const inventory =
      await this.inventoryService.getInventoryByProductPackageId(
        storeId,
        productPackageId as string,
      );

    sendResponse.success(res, inventory, { status: StatusCodes.OK });
  };

  updateInventory = async (
    req: Request,
    res: Response<ApiResponse<InventoryDetailResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const { productPackageId } = req.params;

    // Chỉ cập nhật reorderThreshold
    const inventory = await this.inventoryService.updateInventory(
      storeId,
      productPackageId as string,
      req.body as UpdateInventoryDto,
      userId,
    );

    sendResponse.success(res, inventory, { status: StatusCodes.OK });
  };

  adjustInventories = async (
    req: Request,
    res: Response<ApiResponse<InventoryAdjustmentResponseDto[]>>, // Trả về mảng
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;

    const adjustedInventories = await this.inventoryService.adjustInventories(
      storeId,
      userId,
      req.body as BatchInventoryAdjustmentDto,
    );

    sendResponse.success(res, adjustedInventories, {
      status: StatusCodes.OK,
    });
  };

  createInventory = async (
    req: Request,
    res: Response<ApiResponse<InventoryDetailResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;

    const inventory = await this.inventoryService.createInventory(
      storeId,
      req.body as CreateInventoryDto,
      userId,
    );

    sendResponse.success(res, inventory, { status: StatusCodes.CREATED });
  };

  deleteInventory = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const { productPackageId } = req.params;

    // NOTE: Theo quy định hệ thống, đây là thao tác xóa mềm
    // (soft-delete) để bảo toàn dữ liệu lịch sử
    await this.inventoryService.deleteInventory(
      storeId,
      productPackageId as string,
      userId,
    );

    sendResponse.success(res, null, {
      status: StatusCodes.OK,
      message: 'Inventory deleted successfully',
    });
  };
}
