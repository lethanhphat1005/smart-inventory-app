import type {
  StoreResponseDto,
  CreateStoreDto,
  UpdateStoreDto,
  ListRawStoreDto,
} from './store.dto.js';
import type { DbClient } from '../../common/types/index.js';

export class StoreRepository {
  /* tạo constructor cho các repository có dùng cơ chế $transaction,
  truyền prisma global (prismaClient.ts) lúc bình thường
  và truyền `tx` cho các hàm transaction */
  constructor(private readonly db: DbClient) {}

  async findManybyUserId(userId: string): Promise<ListRawStoreDto[]> {
    return await this.db.store.findMany({
      where: {
        activeStatus: 'active',
        storeMembers: {
          some: {
            userId,
            activeStatus: 'active',
          },
        },
      },
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        inviteCode: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
        currencyCode: true,
        storeMembers: {
          where: {
            userId,
            activeStatus: 'active',
          },
          select: {
            role: true,
          },
        },
      },
    });
  }

  async findById(storeId: string): Promise<StoreResponseDto | null> {
    return await this.db.store.findFirst({
      where: {
        storeId,
        activeStatus: 'active',
      },
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        inviteCode: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
        currencyCode: true,
      },
    });
  }

  async findByIdAndUserId(
    storeId: string,
    userId: string,
  ): Promise<StoreResponseDto | null> {
    return await this.db.store.findFirst({
      where: {
        storeId,
        activeStatus: 'active',
        storeMembers: {
          some: {
            userId,
            activeStatus: 'active',
          },
        },
      },
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        inviteCode: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
        currencyCode: true,
      },
    });
  }

  async createOne(
    data: CreateStoreDto & { inviteCode: string },
  ): Promise<StoreResponseDto> {
    return await this.db.store.create({
      data,
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        inviteCode: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
        currencyCode: true,
      },
    });
  }

  async updateOne(
    storeId: string,
    data: UpdateStoreDto,
  ): Promise<StoreResponseDto | null> {
    return await this.db.store.update({
      where: { storeId },
      data,
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        inviteCode: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
        currencyCode: true,
      },
    });
  }

  async disableOne(storeId: string): Promise<void> {
    await this.db.store.update({
      where: { storeId: storeId },
      data: {
        activeStatus: 'inactive',
      },
    });
  }

  async updateInviteCode(
    storeId: string,
    inviteCode: string,
  ): Promise<StoreResponseDto> {
    return await this.db.store.update({
      where: { storeId },
      data: { inviteCode },
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        inviteCode: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
        currencyCode: true,
      },
    });
  }

  async findByInviteCode(inviteCode: string): Promise<StoreResponseDto | null> {
    return await this.db.store.findFirst({
      where: {
        inviteCode,
        activeStatus: 'active',
      },
      select: {
        storeId: true,
        address: true,
        timezone: true,
        name: true,
        inviteCode: true,
        createdAt: true,
        updatedAt: true,
        userId: true,
        activeStatus: true,
        currencyCode: true,
      },
    });
  }

  async deleteOne(storeId: string): Promise<void> {
    await this.db.store.delete({
      where: { storeId },
    });
  }
}
