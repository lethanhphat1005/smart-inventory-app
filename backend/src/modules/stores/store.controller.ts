import { StatusCodes } from 'http-status-codes';

import { StoreService } from './store.service.js';
import {
  requireReqStoreContext,
  requireReqUser,
  sendResponse,
} from '../../common/utils/index.js';

import type { StoreResponseDto } from './store.dto.js';
import type { CreateStoreDto, UpdateStoreDto } from './store.dto.js';
import type { ApiResponse } from '../../common/types/index.js';
import type { Request, Response } from 'express';

export class StoreController {
  constructor(private readonly storeService: StoreService) {}

  getStores = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto[]>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;

    const stores = await this.storeService.getStoresByUserId(userId);

    sendResponse.success(res, stores, { status: StatusCodes.OK });
  };

  getStoreById = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;

    const { storeId } = req.params;

    const store = await this.storeService.getStoreById(
      storeId as string,
      userId,
    );

    sendResponse.success(res, store, { status: StatusCodes.OK });
  };

  createStore = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;

    const payload = req.body as CreateStoreDto;

    const createdStore = await this.storeService.createNewStore(
      userId,
      payload,
    );

    sendResponse.success(res, createdStore, { status: StatusCodes.CREATED });
  };

  updateStore = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;
    const storeId = requireReqStoreContext(req).storeId;

    const payload = req.body as UpdateStoreDto;

    const updatedStore = await this.storeService.updateStore(
      storeId as string,
      userId,
      payload,
    );

    sendResponse.success(res, updatedStore, { status: StatusCodes.OK });
  };

  softDeleteStore = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;

    const { storeId } = req.params;

    await this.storeService.softDeleteStore(storeId as string, userId);

    sendResponse.success(res, null, { status: StatusCodes.OK });
  };

  refreshInviteCode = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;
    const storeId = requireReqStoreContext(req).storeId;

    const updatedStore = await this.storeService.refreshInviteCode(
      storeId as string,
      userId,
    );

    sendResponse.success(res, updatedStore, { status: StatusCodes.OK });
  };

  joinStore = async (
    req: Request,
    res: Response<ApiResponse<StoreResponseDto>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;
    const { inviteCode } = req.body; // Lấy từ body do ta dùng POST

    const store = await this.storeService.joinStoreByInviteCode(
      userId,
      inviteCode,
    );

    sendResponse.success(res, store, { status: StatusCodes.OK });
  };

  hardDeleteStore = async (
    req: Request,
    res: Response<ApiResponse<null>>,
  ): Promise<void> => {
    const userId = requireReqUser(req).userId;
    const { storeId } = req.params;
    const { storeName } = req.body as { storeName: string };

    await this.storeService.hardDeleteStore(
      storeId as string,
      userId,
      storeName,
    );

    sendResponse.success(res, null, { status: StatusCodes.OK });
  };
}
