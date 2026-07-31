import type {
  RawStoreMemberDto,
  StoreMemberResponseDto,
  CreateStoreMembershipDto,
  RbacStoreMembershipResponseDto,
} from './store-member.dto.js';
import type { DbClient } from '../../common/types/index.js';
import type { StoreRole } from '../../generated/prisma/enums.js';

export class StoreMemberRepository {
  /* tạo constructor cho các repository có dùng cơ chế $transaction,
  truyền prisma global (prismaClient.ts) lúc bình thường
  và truyền `tx` cho các hàm transaction */
  constructor(private readonly db: DbClient) {}

  async findOne(
    userId: string,
    storeId: string,
  ): Promise<StoreMemberResponseDto | null> {
    return await this.db.storeMember.findFirst({
      where: { userId, storeId, activeStatus: 'active' },
      select: {
        userId: true,
        storeId: true,
        role: true,
        joinedAt: true,
        activeStatus: true,
      },
    });
  }

  async findByIdsWithStore(
    userId: string,
    storeId: string,
  ): Promise<(StoreMemberResponseDto & { store: { userId: string } }) | null> {
    return await this.db.storeMember.findUnique({
      where: {
        userId_storeId: { userId, storeId },
      },
      include: {
        store: {
          select: { userId: true }, // Lấy ID của chủ cửa hàng (Owner)
        },
      },
    });
  }

  async findManyByStoreId(storeId: string): Promise<RawStoreMemberDto[]> {
    return (await this.db.storeMember.findMany({
      where: {
        storeId,
        activeStatus: 'active',
        user: {
          activeStatus: 'active',
        },
      },
      select: {
        role: true,
        joinedAt: true,
        user: {
          select: {
            userId: true,
            email: true,
            fullName: true,
            phone: true,
            address: true,
            activeStatus: true,
            createdAt: true,
            updatedAt: true,
            authUserId: true,
          },
        },
      },
    })) as unknown as RawStoreMemberDto[];
  }

  async softDeleteMember(
    userId: string,
    storeId: string,
  ): Promise<StoreMemberResponseDto> {
    return await this.db.storeMember.update({
      where: {
        userId_storeId: {
          userId,
          storeId,
        },
      },
      data: {
        activeStatus: 'inactive', // Soft delete theo business rule của SIS
      },
    });
  }

  async updateRole(
    userId: string,
    storeId: string,
    newRole: StoreRole,
  ): Promise<StoreMemberResponseDto> {
    return await this.db.storeMember.update({
      where: {
        userId_storeId: {
          userId,
          storeId,
        },
      },
      data: {
        role: newRole,
      },
    });
  }

  async createOne(
    data: CreateStoreMembershipDto,
  ): Promise<StoreMemberResponseDto> {
    return await this.db.storeMember.create({
      data,
      select: {
        userId: true,
        storeId: true,
        role: true,
        activeStatus: true,
        joinedAt: true,
      },
    });
  }

  async findOneByUserIdAndStoreId(
    userId: string,
    storeId: string,
  ): Promise<RbacStoreMembershipResponseDto | null> {
    return await this.db.storeMember.findFirst({
      where: {
        userId,
        storeId,
        activeStatus: 'active',
        store: {
          activeStatus: 'active',
        },
      },
      select: {
        userId: true,
        storeId: true,
        role: true,
      },
    });
  }

  // NOTE: 2 function để disable membership trong store khi store bị xóa
  // async findAllByStoreId(storeId: string): Promise<StoreMembershipList[]> {
  //   return this.db.storeMember.findMany({
  //     where: {
  //       storeId,
  //       activeStatus: 'active',
  //     },
  //     select: {
  //       userId: true,
  //       storeId: true,
  //     },
  //   });
  // }

  // async disableAllStoreMembership(
  //   membershipList: StoreMembershipList[],
  // ): Promise<void> {
  //   await this.db.storeMember.updateMany({
  //     where: {
  //       OR: membershipList.map((membership) => ({
  //         userId: membership.userId,
  //         storeId: membership.storeId,
  //         activeStatus: 'active'
  //       })),
  //     },
  //     data: {
  //       activeStatus: 'inactive',
  //     },
  //   });
  // }

  // Nếu user đã từng tham gia nhưng bị kích (inactive),
  // có thể sẽ cần hàm update để khôi phục
  async reactivateMembership(userId: string, storeId: string, role: StoreRole) {
    return await this.db.storeMember.update({
      where: { userId_storeId: { userId, storeId } },
      data: { activeStatus: 'active', role },
    });
  }
}
