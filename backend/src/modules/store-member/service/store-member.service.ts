import { StatusCodes } from 'http-status-codes';

import { CustomError } from '../../../common/errors/custom-error.js';
import { appEvents, eventBus } from '../../../common/events/event-bus.js';
import { ROLE } from '../../access-control/role-permission.constant.js'; // IMPORT CONSTANT MỚI Ở ĐÂY

import type { StoreRole } from '../../../generated/prisma/enums.js';
import type {
  StoreMemberResponseDto,
  StoreMemberUserResponseDto,
} from '../dto/store-member.dto.js';
import type { StoreMemberRepository } from '../repository/store-member.repository.js';

export class StoreMemberService {
  constructor(private readonly storeMemberRepository: StoreMemberRepository) {}

  public async removeUserFromStore(
    requesterUserId: string,
    requesterRole: string,
    targetUserId: string,
    storeId: string,
  ): Promise<StoreMemberResponseDto> {
    const targetMember = await this.storeMemberRepository.findByIdsWithStore(
      targetUserId,
      storeId,
    );

    if (!targetMember) {
      throw new CustomError({
        message: 'User is not a member of this store',
        status: StatusCodes.NOT_FOUND,
      });
    }

    if (targetMember.activeStatus === 'inactive') {
      throw new CustomError({
        message: 'This user has already been removed from the store',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    if (requesterUserId === targetUserId) {
      throw new CustomError({
        message: 'You cannot remove yourself using this feature',
        status: StatusCodes.BAD_REQUEST,
      });
    }

    if (targetMember.store.userId === targetUserId) {
      throw new CustomError({
        message: 'Cannot remove the store owner',
        status: StatusCodes.FORBIDDEN,
      });
    }

    // ĐỒNG BỘ CHỮ HOA ĐỂ TRÁNH LỖI CASE-SENSITIVE
    const reqRoleStandardized = requesterRole.toUpperCase();
    const targetRoleStandardized = targetMember.role.toUpperCase();

    // Dùng hằng số ROLE để kiểm tra thay vì hardcode string
    if (
      reqRoleStandardized === ROLE.MANAGER &&
      targetRoleStandardized === ROLE.MANAGER
    ) {
      throw new CustomError({
        message: 'Managers can only remove staff members, not other managers',
        status: StatusCodes.FORBIDDEN,
      });
    }

    return await this.storeMemberRepository.softDeleteMember(
      targetUserId,
      storeId,
    );
  }

  public async updateMemberRole(
    requesterRole: string,
    targetUserId: string,
    storeId: string,
    newRole: StoreRole,
  ): Promise<StoreMemberResponseDto> {
    // 1. CHỈ OWNER MỚI CÓ QUYỀN ĐỔI ROLE
    if (requesterRole.toUpperCase() !== ROLE.OWNER) {
      throw new CustomError({
        message: 'Only the store owner can change member roles',
        status: StatusCodes.FORBIDDEN,
      });
    }

    // 2. Lấy thông tin user cần đổi
    const targetMember = await this.storeMemberRepository.findByIdsWithStore(
      targetUserId,
      storeId,
    );

    if (!targetMember || targetMember.activeStatus === 'inactive') {
      throw new CustomError({
        message: 'User is not an active member of this store',
        status: StatusCodes.NOT_FOUND,
      });
    }

    // 3. Không được phép đổi quyền của Chủ cửa hàng (Owner)
    if (targetMember.store.userId === targetUserId) {
      throw new CustomError({
        message: 'Cannot change the role of the store owner',
        status: StatusCodes.FORBIDDEN,
      });
    }

    // 4. Nếu role truyền lên giống y hệt role
    // hiện tại thì báo lỗi luôn để tránh update thừa
    if (targetMember.role === newRole) {
      throw new CustomError({
        message: `User is already a ${newRole}`,
        status: StatusCodes.BAD_REQUEST,
      });
    }

    eventBus.emit(appEvents.ROLE_UPDATED, {
      targetUserId,
      storeId,
      oldRole: targetMember.role,
      newRole: newRole,
    });

    // 5. Cập nhật role
    return await this.storeMemberRepository.updateRole(
      targetUserId,
      storeId,
      newRole,
    );
  }

  public async getMembersByStoreId(
    storeId: string,
  ): Promise<StoreMemberUserResponseDto[]> {
    const members = await this.storeMemberRepository.findManyByStoreId(storeId);

    return members.map((item) => ({
      userId: item.user.userId,
      email: item.user.email,
      fullName: item.user.fullName,
      phone: item.user.phone,
      address: item.user.address,
      activeStatus: item.user.activeStatus,
      role: item.role,
      joinedAt: item.joinedAt,
    }));
  }
}
