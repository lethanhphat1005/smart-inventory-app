import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../common/errors/custom-error.js';
import { sendResponse } from '../../common/utils/api-response.util.js';
import {
  requireReqStoreContext,
  requireReqUser,
} from '../../common/utils/require-req.js';

import type {
  StoreMemberResponseDto,
  StoreMemberUserResponseDto,
  UpdateStoreMemberRoleDto,
} from './store-member.dto.js';
import type { StoreMemberService } from './store-member.service.js';
import type { ApiResponse } from '../../common/types/api-response.type.js';
import type { Request, Response } from 'express';

export class StoreMemberController {
  constructor(private readonly storeMemberService: StoreMemberService) {}

  removeUser = async (
    req: Request,
    res: Response<ApiResponse<StoreMemberResponseDto>>,
  ): Promise<void> => {
    const user = requireReqUser(req);
    // Lấy ID của người đang thao tác
    const storeContext = requireReqStoreContext(req);
    // Có chứa storeId và role ('owner', 'manager', 'staff')
    const targetUserId = req.params.userId as string;

    if (!targetUserId) {
      throw new CustomError({
        message: 'Target User ID is required',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    const removedMember = await this.storeMemberService.removeUserFromStore(
      user.userId,
      storeContext.role,
      targetUserId,
      storeContext.storeId,
    );

    sendResponse.success(res, removedMember, { status: StatusCodes.OK });
  };

  updateRole = async (
    req: Request,
    res: Response<ApiResponse<StoreMemberResponseDto>>,
  ): Promise<void> => {
    const storeContext = requireReqStoreContext(req);
    const targetUserId = req.params.userId as string;
    const { role: newRole } = req.body as UpdateStoreMemberRoleDto;

    const updatedMember = await this.storeMemberService.updateMemberRole(
      storeContext.role,
      targetUserId,
      storeContext.storeId,
      newRole,
    );

    sendResponse.success(res, updatedMember, { status: StatusCodes.OK });
  };

  getStoreMembers = async (
    req: Request,
    res: Response<ApiResponse<StoreMemberUserResponseDto[]>>,
  ): Promise<void> => {
    // Lấy store context để đảm bảo user có quyền truy cập store này
    const storeContext = requireReqStoreContext(req);

    const members = await this.storeMemberService.getMembersByStoreId(
      storeContext.storeId,
    );

    sendResponse.success(res, members, { status: StatusCodes.OK });
  };
}
