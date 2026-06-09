import { StatusCodes } from 'http-status-codes';

import { StoreRepository } from './store.repository.js';
import { generateFormattedInviteCode } from './store.util.js';
import { CustomError } from '../../common/errors/index.js';
import { prisma } from '../../db/prismaClient.js'; // gọi prisma để dùng cơ chế $transaction
import { StoreMemberRepository } from '../store-member/index.js';

import type {
  StoreResponseDto,
  ListStoreResponseDto,
  CreateStoreDto,
  UpdateStoreDto,
} from './store.dto.js';

export class StoreService {
  constructor(private readonly storeRepository: StoreRepository) {}

  async getStoresByUserId(userId: string): Promise<ListStoreResponseDto[]> {
    const rawStores = await this.storeRepository.findManybyUserId(userId);

    /*
    Xử lý trả về thêm role của user từ StoreMember clean:
    [
      {
        storeId: '...',
        name: 'Store A',
        role: 'manager'
      }
    ]
    Vì nếu giữ raw query sẽ trả về dạng sau:
    [
      {
        storeId: '...',
        name: 'Store A',
        storeMembers: [
          { role: 'manager' }
        ]
      }
    ]
    */
    return rawStores.map(({ storeMembers, ...store }) => {
      const membership = storeMembers[0];

      if (!membership) {
        throw new CustomError({
          message: 'Store membership not found',
          status: StatusCodes.INTERNAL_SERVER_ERROR,
        });
      }

      return {
        ...store,
        role: membership.role,
      };
    });
  }

  public async getStoreById(
    storeId: string,
    userId: string,
  ): Promise<StoreResponseDto> {
    const store = await this.storeRepository.findByIdAndUserId(storeId, userId);

    if (!store) {
      throw new CustomError({
        message: 'Store not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    return store;
  }

  public async createNewStore(
    userId: string,
    data: CreateStoreDto,
  ): Promise<StoreResponseDto> {
    const newInviteCode = generateFormattedInviteCode();

    /* dùng hàm $transaction để chạy nhiều query trong một lệnh,
    $transaction hỗ trợ cơ chế Either ALL succeed hoặc ALL rollback */
    return await prisma.$transaction(async (tx) => {
      const storeRepositoryTx = new StoreRepository(tx);
      const storeMemberRepositoryTx = new StoreMemberRepository(tx);

      const createdStore = await storeRepositoryTx.createOne({
        ...data,
        userId,
        inviteCode: newInviteCode,
      });

      // gán role manager cho user khi tạo store thành công
      await storeMemberRepositoryTx.createOne({
        userId,
        storeId: createdStore.storeId,
        role: 'owner',
      });

      return createdStore;
    });
  }

  public async updateStore(
    storeId: string,
    userId: string,
    data: UpdateStoreDto,
  ): Promise<StoreResponseDto> {
    const existingStore = await this.storeRepository.findByIdAndUserId(
      storeId,
      userId,
    );

    if (!existingStore) {
      throw new CustomError({
        message: 'Store not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    const updatedStore = await this.storeRepository.updateOne(storeId, data);

    if (!updatedStore) {
      throw new CustomError({
        message: 'Store update failed',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    }

    return updatedStore;
  }

  public async softDeleteStore(storeId: string, userId: string): Promise<void> {
    const existingStore = await this.storeRepository.findByIdAndUserId(
      storeId,
      userId,
    );

    if (!existingStore) {
      throw new CustomError({
        message: 'Store not found',
        status: StatusCodes.NOT_FOUND,
      });
    }

    await this.storeRepository.disableOne(storeId);

    /*
      NOTE: disable luôn các membership có trong store
      NOTE: tuy nhiên có thể dẫn tới lẫn logic khi có function restore store:
        - membership inactive vì user bị remove?
        - hay vì store bị disable?
    */
    // await prisma.$transaction(async (tx) => {
    //   const storeRepositoryTx = new StoreRepository(tx);
    //   const storeMemberRepositoryTx = new StoreMemberRepository(tx);

    //   await storeRepositoryTx.disableOne(storeId);

    //   const storeMemberships =
    //     await storeMemberRepositoryTx.findAllByStoreId(storeId);

    //   await storeMemberRepositoryTx
    //          .disableAllStoreMembership(storeMemberships);
    // });
  }

  public async refreshInviteCode(
    storeId: string,
    userId: string,
  ): Promise<StoreResponseDto> {
    const store = await this.storeRepository.findByIdAndUserId(storeId, userId);

    if (!store) {
      throw new CustomError({
        message: 'Store not found or you do not have permission',
        status: StatusCodes.NOT_FOUND,
      });
    }

    // Sinh mã mới bằng util đã tách ở bước trước
    const newInviteCode = generateFormattedInviteCode();

    return await this.storeRepository.updateInviteCode(storeId, newInviteCode);
  }

  public async joinStoreByInviteCode(
    userId: string,
    inviteCode: string,
  ): Promise<StoreResponseDto> {
    return await prisma.$transaction(async (tx) => {
      const storeRepositoryTx = new StoreRepository(tx);
      const storeMemberRepositoryTx = new StoreMemberRepository(tx);

      // 1. Tìm cửa hàng bằng mã mời
      const store = await storeRepositoryTx.findByInviteCode(inviteCode);

      if (!store) {
        throw new CustomError({
          message: 'Invalid invite code or store not found',
          status: StatusCodes.NOT_FOUND,
        });
      }

      // 2. Kiểm tra xem user đã là thành viên chưa
      const existingMembership = await storeMemberRepositoryTx.findOne(
        userId,
        store.storeId,
      );

      if (existingMembership) {
        // Nếu đang active thì báo lỗi (không cho join lại)
        if (existingMembership.activeStatus === 'active') {
          throw new CustomError({
            message: 'You are already a member of this store',
            status: StatusCodes.CONFLICT, // 409 Conflict
          });
        } else {
          // Nếu đã từng tham gia nhưng bị xoá/rời đi (inactive),
          // thì khôi phục lại với role staff
          await storeMemberRepositoryTx.reactivateMembership(
            userId,
            store.storeId,
            'staff',
          );

          return store;
        }
      }

      // 3. Nếu chưa từng tham gia, tạo mới StoreMember với role là staff
      await storeMemberRepositoryTx.createOne({
        userId,
        storeId: store.storeId,
        role: 'staff',
      });

      return store;
    });
  }
}
