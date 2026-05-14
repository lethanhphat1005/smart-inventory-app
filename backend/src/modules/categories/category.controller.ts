import { StatusCodes } from 'http-status-codes';

import { CategoriesService } from './category.service.js';
import {
  sendResponse,
  requireReqStoreContext,
  requireReqUser,
} from '../../common/utils/index.js';

import type {
  CategoryResponseDto,
  CreateCategoryDto,
  UpdateCategoryDto,
} from './category.dto.js';
import type { ApiResponse } from '../../common/types/index.js';
import type { Request, Response } from 'express';

export class CategoryController {
  constructor(private readonly categoryService: CategoriesService) {}

  findAll = async (
    req: Request,
    res: Response<ApiResponse<CategoryResponseDto[]>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const categories = await this.categoryService.findAll(storeId);

    sendResponse.success(res, categories, {
      status: StatusCodes.OK,
    });
  };

  findAllHidden = async (
    req: Request,
    res: Response<ApiResponse<CategoryResponseDto[]>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const hiddenCategories = await this.categoryService.findAllHiddenInStore(storeId);

    sendResponse.success(res, hiddenCategories, {
      status: StatusCodes.OK,
    });
  };

  createOne = async (
    req: Request,
    res: Response<ApiResponse<CategoryResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const payload = req.body as CreateCategoryDto;

    const createdCategory = await this.categoryService.createOne(
      storeId,
      userId,
      payload,
    );

    sendResponse.success(res, createdCategory, {
      status: StatusCodes.CREATED,
    });
  };

  updateOne = async (
    req: Request,
    res: Response<ApiResponse<CategoryResponseDto>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const { categoryId } = req.params;
    const payload = req.body as UpdateCategoryDto;

    const updatedCategory = await this.categoryService.updateOne(
      storeId,
      userId,
      categoryId as string,
      payload,
    );

    sendResponse.success(res, updatedCategory, {
      status: StatusCodes.OK,
    });
  };

  softDeleteDefaultOne = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { categoryId } = req.params;

    await this.categoryService.softDeleteDefault(storeId, categoryId as string);

    sendResponse.success(res, null, {
      status: StatusCodes.OK,
    });
  };

  restoreDefaultOne = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const { categoryId } = req.params;

    await this.categoryService.restoreDefault(storeId, categoryId as string);

    sendResponse.success(res, null, {
      status: StatusCodes.OK,
    });
  };

  /*
    FE gọi xóa với canReassignToUncategorized = false
    Nếu category rỗng, backend xóa luôn
    Nếu category đang được dùng, backend trả 409 CATEGORY_IN_USE
    FE hiện popup xác nhận
    User đồng ý
    FE gọi lại cùng endpoint với canReassignToUncategorized = true
    Backend chuyển product sang Uncategorized rồi xóa category trong transaction
  */
  deleteCustomCategory = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    const storeId = requireReqStoreContext(req).storeId;
    const userId = requireReqUser(req).userId;
    const { categoryId } = req.params;

    // FE gửi cờ canReassignToUncategorized để thể hiện người dùng
    // đã xác nhận chuyển toàn bộ product sang Uncategorized trước khi xóa.
    const { canReassignToUncategorized } = req.body as {
      canReassignToUncategorized?: boolean;
    };

    await this.categoryService.deleteCustomCategory(
      storeId,
      userId,
      categoryId as string,
      canReassignToUncategorized ?? false,
    );

    sendResponse.success(res, null, {
      status: StatusCodes.OK,
    });
  };
}
