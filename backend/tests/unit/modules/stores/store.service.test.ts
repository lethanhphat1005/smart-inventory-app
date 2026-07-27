import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { CustomError } from '../../../../src/common/errors/index.js';
import { StoreService } from '../../../../src/modules/stores/store.service.js';

import type {
  CreateStoreDto,
  StoreResponseDto,
  UpdateStoreDto,
} from '../../../../src/modules/stores/store.dto.js';

const prismaMocks = vi.hoisted(() => {
  const transactionClient = {
    store: {
      create: vi.fn(),
      findFirst: vi.fn(),
      update: vi.fn(),
    },
    storeMember: {
      create: vi.fn(),
      findFirst: vi.fn(),
      update: vi.fn(),
    },
  };

  const transactionMock = vi.fn(
    async <T>(callback: (tx: typeof transactionClient) => Promise<T>) => {
      return await callback(transactionClient);
    },
  );

  return {
    transactionClient,
    transactionMock,
  };
});

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: {
    $transaction: prismaMocks.transactionMock,
  },
}));

vi.mock('../../../../src/modules/stores/store.util.js', () => ({
  generateFormattedInviteCode: vi.fn(() => 'aaaa-bbbb-cccc-dddd'),
}));

// NOTE: tạm thời bypass failure test case khi import productRepository
vi.mock('../../../../src/modules/products/index.js', () => ({
  ProductRepository: class {
    findAllImagePathsByStoreId = vi.fn();
  },

  productRepository: {},
  productService: {},
  productRouter: {},
}));

type MockProductRepository = {
  findAllImagePathsByStoreId: ReturnType<typeof vi.fn>;
};

const createMockProductRepository = (): MockProductRepository => ({
  findAllImagePathsByStoreId: vi.fn(),
});

type MockStoreRepository = {
  findManybyUserId: ReturnType<typeof vi.fn>;
  findByIdAndUserId: ReturnType<typeof vi.fn>;
  updateOne: ReturnType<typeof vi.fn>;
  disableOne: ReturnType<typeof vi.fn>;
  updateInviteCode: ReturnType<typeof vi.fn>;
};

const storeFixture = (
  overrides: Partial<StoreResponseDto> = {},
): StoreResponseDto => ({
  storeId: 'store-1',
  name: 'Main Store',
  address: '123 Market Street',
  timezone: 'Asia/Ho_Chi_Minh',
  inviteCode: 'aaaa-bbbb-cccc-dddd',
  createdAt: new Date('2026-01-01T00:00:00.000Z'),
  updatedAt: new Date('2026-01-01T00:00:00.000Z'),
  userId: 'user-1',
  activeStatus: 'active',
  currencyCode: 'VND',
  ...overrides,
});

const createMockRepository = (): MockStoreRepository => ({
  findManybyUserId: vi.fn(),
  findByIdAndUserId: vi.fn(),
  updateOne: vi.fn(),
  disableOne: vi.fn(),
  updateInviteCode: vi.fn(),
});

describe('StoreService', () => {
  let storeRepository: MockStoreRepository;
  let storeService: StoreService;
  let productRepository: MockProductRepository;

  beforeEach(() => {
    vi.clearAllMocks();

    storeRepository = createMockRepository();
    productRepository = createMockProductRepository();
    storeService = new StoreService(
      storeRepository as never,
      productRepository as never,
    );
  });

  describe('getStoresByUserId', () => {
    it('returns active stores with the current membership role', async () => {
      const store = storeFixture();

      storeRepository.findManybyUserId.mockResolvedValue([
        {
          ...store,
          storeMembers: [{ role: 'manager' }],
        },
      ]);

      const result = await storeService.getStoresByUserId('user-1');

      expect(storeRepository.findManybyUserId).toHaveBeenCalledWith('user-1');
      expect(result).toEqual([
        {
          ...store,
          role: 'manager',
        },
      ]);
    });

    it('throws when repository data has no matching membership', async () => {
      storeRepository.findManybyUserId.mockResolvedValue([
        {
          ...storeFixture(),
          storeMembers: [],
        },
      ]);

      await expect(
        storeService.getStoresByUserId('user-1'),
      ).rejects.toMatchObject({
        message: 'Store membership not found',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    });
  });

  describe('getStoreById', () => {
    it('returns a store when the user is an active member', async () => {
      const store = storeFixture();

      storeRepository.findByIdAndUserId.mockResolvedValue(store);

      const result = await storeService.getStoreById('store-1', 'user-1');

      expect(storeRepository.findByIdAndUserId).toHaveBeenCalledWith(
        'store-1',
        'user-1',
      );
      expect(result.storeId).toBe('store-1');
    });

    it('throws not found when the user has no store access', async () => {
      storeRepository.findByIdAndUserId.mockResolvedValue(null);

      await expect(
        storeService.getStoreById('store-1', 'user-1'),
      ).rejects.toMatchObject({
        message: 'Store not found',
        status: StatusCodes.NOT_FOUND,
      });
    });
  });

  describe('createNewStore', () => {
    it('creates a store and owner membership in one transaction', async () => {
      const store = storeFixture();
      const payload: CreateStoreDto = {
        name: 'Main Store',
        address: '123 Market Street',
        timezone: 'Asia/Ho_Chi_Minh',
        currencyCode: 'VND',
        userId: 'payload-user',
      };

      prismaMocks.transactionClient.store.create.mockResolvedValue(store);
      prismaMocks.transactionClient.storeMember.create.mockResolvedValue({
        userId: 'user-1',
        storeId: 'store-1',
        role: 'owner',
        activeStatus: 'active',
        joinedAt: new Date('2026-01-01T00:00:00.000Z'),
      });

      const result = await storeService.createNewStore('user-1', payload);

      expect(prismaMocks.transactionMock).toHaveBeenCalledTimes(1);
      expect(prismaMocks.transactionClient.store.create).toHaveBeenCalledWith({
        data: {
          ...payload,
          userId: 'user-1',
          inviteCode: 'aaaa-bbbb-cccc-dddd',
        },
        select: expect.objectContaining({
          storeId: true,
          inviteCode: true,
        }),
      });
      expect(
        prismaMocks.transactionClient.storeMember.create,
      ).toHaveBeenCalledWith({
        data: {
          userId: 'user-1',
          storeId: 'store-1',
          role: 'owner',
        },
        select: expect.objectContaining({
          userId: true,
          storeId: true,
          role: true,
        }),
      });
      expect(result).toBe(store);
    });

    it('propagates database errors from the transaction', async () => {
      prismaMocks.transactionClient.store.create.mockRejectedValue(
        new Error('unique invite code collision'),
      );

      await expect(
        storeService.createNewStore('user-1', {
          name: 'Main Store',
          address: null,
          timezone: null,
          currencyCode: 'VND',
          userId: 'payload-user',
        }),
      ).rejects.toThrow('unique invite code collision');
    });
  });

  describe('updateStore', () => {
    it('updates store data after membership access is verified', async () => {
      const updatePayload: UpdateStoreDto = { name: 'Updated Store' };
      const updatedStore = storeFixture({ name: 'Updated Store' });

      storeRepository.findByIdAndUserId.mockResolvedValue(storeFixture());
      storeRepository.updateOne.mockResolvedValue(updatedStore);

      const result = await storeService.updateStore(
        'store-1',
        'user-1',
        updatePayload,
      );

      expect(storeRepository.updateOne).toHaveBeenCalledWith(
        'store-1',
        updatePayload,
      );
      expect(result.name).toBe('Updated Store');
    });

    it('throws not found when the user cannot access the store', async () => {
      storeRepository.findByIdAndUserId.mockResolvedValue(null);

      await expect(
        storeService.updateStore('store-1', 'user-1', { name: 'Updated' }),
      ).rejects.toMatchObject({
        message: 'Store not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(storeRepository.updateOne).not.toHaveBeenCalled();
    });

    it('throws internal server error when update returns no store', async () => {
      storeRepository.findByIdAndUserId.mockResolvedValue(storeFixture());
      storeRepository.updateOne.mockResolvedValue(null);

      await expect(
        storeService.updateStore('store-1', 'user-1', { name: 'Updated' }),
      ).rejects.toMatchObject({
        message: 'Store update failed',
        status: StatusCodes.INTERNAL_SERVER_ERROR,
      });
    });
  });

  describe('softDeleteStore', () => {
    it('disables an accessible active store', async () => {
      storeRepository.findByIdAndUserId.mockResolvedValue(storeFixture());
      storeRepository.disableOne.mockResolvedValue(undefined);

      await storeService.softDeleteStore('store-1', 'user-1');

      expect(storeRepository.disableOne).toHaveBeenCalledWith('store-1');
    });

    it('throws not found and does not disable inaccessible stores', async () => {
      storeRepository.findByIdAndUserId.mockResolvedValue(null);

      await expect(
        storeService.softDeleteStore('store-1', 'user-1'),
      ).rejects.toMatchObject({
        message: 'Store not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(storeRepository.disableOne).not.toHaveBeenCalled();
    });
  });

  describe('refreshInviteCode', () => {
    it('updates the invite code for an accessible store', async () => {
      const updatedStore = storeFixture({
        inviteCode: 'aaaa-bbbb-cccc-dddd',
      });

      storeRepository.findByIdAndUserId.mockResolvedValue(storeFixture());
      storeRepository.updateInviteCode.mockResolvedValue(updatedStore);

      const result = await storeService.refreshInviteCode('store-1', 'user-1');

      expect(storeRepository.updateInviteCode).toHaveBeenCalledWith(
        'store-1',
        'aaaa-bbbb-cccc-dddd',
      );
      expect(result.inviteCode).toBe('aaaa-bbbb-cccc-dddd');
    });

    it('throws not found when user has no permission', async () => {
      storeRepository.findByIdAndUserId.mockResolvedValue(null);

      await expect(
        storeService.refreshInviteCode('store-1', 'user-1'),
      ).rejects.toMatchObject({
        message: 'Store not found or you do not have permission',
        status: StatusCodes.NOT_FOUND,
      });
    });
  });

  describe('joinStoreByInviteCode', () => {
    it('creates a staff membership for a new user', async () => {
      const store = storeFixture();

      prismaMocks.transactionClient.store.findFirst.mockResolvedValue(store);
      prismaMocks.transactionClient.storeMember.findFirst.mockResolvedValue(
        null,
      );
      prismaMocks.transactionClient.storeMember.create.mockResolvedValue({
        userId: 'user-2',
        storeId: 'store-1',
        role: 'staff',
        activeStatus: 'active',
        joinedAt: new Date('2026-01-01T00:00:00.000Z'),
      });

      const result = await storeService.joinStoreByInviteCode(
        'user-2',
        'aaaa-bbbb-cccc-dddd',
      );

      expect(
        prismaMocks.transactionClient.store.findFirst,
      ).toHaveBeenCalledWith(
        expect.objectContaining({
          where: {
            inviteCode: 'aaaa-bbbb-cccc-dddd',
            activeStatus: 'active',
          },
        }),
      );
      expect(
        prismaMocks.transactionClient.storeMember.create,
      ).toHaveBeenCalledWith({
        data: {
          userId: 'user-2',
          storeId: 'store-1',
          role: 'staff',
        },
        select: expect.objectContaining({
          userId: true,
          role: true,
        }),
      });
      expect(result).toBe(store);
    });

    it('throws not found for an invalid invite code', async () => {
      prismaMocks.transactionClient.store.findFirst.mockResolvedValue(null);

      await expect(
        storeService.joinStoreByInviteCode('user-2', 'bad-code'),
      ).rejects.toMatchObject({
        message: 'Invalid invite code or store not found',
        status: StatusCodes.NOT_FOUND,
      });
      expect(
        prismaMocks.transactionClient.storeMember.create,
      ).not.toHaveBeenCalled();
    });

    it('throws conflict when the user is already active member', async () => {
      prismaMocks.transactionClient.store.findFirst.mockResolvedValue(
        storeFixture(),
      );
      prismaMocks.transactionClient.storeMember.findFirst.mockResolvedValue({
        userId: 'user-2',
        storeId: 'store-1',
        role: 'staff',
        activeStatus: 'active',
        joinedAt: new Date('2026-01-01T00:00:00.000Z'),
      });

      await expect(
        storeService.joinStoreByInviteCode('user-2', 'aaaa-bbbb-cccc-dddd'),
      ).rejects.toMatchObject({
        message: 'You are already a member of this store',
        status: StatusCodes.CONFLICT,
      });
      expect(
        prismaMocks.transactionClient.storeMember.create,
      ).not.toHaveBeenCalled();
    });

    it('documents inactive membership reactivation branch', async () => {
      prismaMocks.transactionClient.store.findFirst.mockResolvedValue(
        storeFixture(),
      );
      prismaMocks.transactionClient.storeMember.findFirst.mockResolvedValue({
        userId: 'user-2',
        storeId: 'store-1',
        role: 'manager',
        activeStatus: 'inactive',
        joinedAt: new Date('2026-01-01T00:00:00.000Z'),
      });

      await storeService.joinStoreByInviteCode('user-2', 'aaaa-bbbb-cccc-dddd');

      expect(
        prismaMocks.transactionClient.storeMember.update,
      ).toHaveBeenCalledWith({
        where: {
          userId_storeId: {
            userId: 'user-2',
            storeId: 'store-1',
          },
        },
        data: {
          activeStatus: 'active',
          role: 'staff',
        },
      });
    });

    it('surfaces duplicate membership races as database failures', async () => {
      prismaMocks.transactionClient.store.findFirst.mockResolvedValue(
        storeFixture(),
      );
      prismaMocks.transactionClient.storeMember.findFirst.mockResolvedValue(
        null,
      );
      prismaMocks.transactionClient.storeMember.create.mockRejectedValue(
        new CustomError({
          message: 'Duplicate membership',
          status: StatusCodes.CONFLICT,
        }),
      );

      await expect(
        storeService.joinStoreByInviteCode('user-2', 'aaaa-bbbb-cccc-dddd'),
      ).rejects.toMatchObject({
        message: 'Duplicate membership',
        status: StatusCodes.CONFLICT,
      });
    });
  });
});
