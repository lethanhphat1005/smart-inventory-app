import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { StoreController } from '../../../../src/modules/stores/store.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

import type { StoreResponseDto } from '../../../../src/modules/stores/store.dto.js';

type MockStoreService = {
  getStoresByUserId: ReturnType<typeof vi.fn>;
  getStoreById: ReturnType<typeof vi.fn>;
  createNewStore: ReturnType<typeof vi.fn>;
  updateStore: ReturnType<typeof vi.fn>;
  softDeleteStore: ReturnType<typeof vi.fn>;
  refreshInviteCode: ReturnType<typeof vi.fn>;
  joinStoreByInviteCode: ReturnType<typeof vi.fn>;
};

const storeFixture = (
  overrides: Partial<StoreResponseDto> = {},
): StoreResponseDto => ({
  storeId: '550e8400-e29b-41d4-a716-446655440000',
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

vi.mock('../../../../src/modules/products/index.js', () => ({
  ProductRepository: class {
    findAllImagePathsByStoreId = vi.fn();
  },
}));

const createMockService = (): MockStoreService => ({
  getStoresByUserId: vi.fn(),
  getStoreById: vi.fn(),
  createNewStore: vi.fn(),
  updateStore: vi.fn(),
  softDeleteStore: vi.fn(),
  refreshInviteCode: vi.fn(),
  joinStoreByInviteCode: vi.fn(),
});

describe('StoreController', () => {
  let storeService: MockStoreService;
  let storeController: StoreController;

  beforeEach(() => {
    storeService = createMockService();
    storeController = new StoreController(storeService as never);
  });

  it('returns stores for the authenticated user', async () => {
    const stores = [
      {
        ...storeFixture(),
        role: 'owner',
      },
    ];
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
    });
    const res = createResponse<StoreResponseDto[]>();

    storeService.getStoresByUserId.mockResolvedValue(stores);

    await storeController.getStores(req, res);

    expect(storeService.getStoresByUserId).toHaveBeenCalledWith('user-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: stores,
    });
  });

  it('returns a store by path id for the authenticated user', async () => {
    const store = storeFixture();
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      params: {
        storeId: '550e8400-e29b-41d4-a716-446655440000',
      },
    });
    const res = createResponse<StoreResponseDto>();

    storeService.getStoreById.mockResolvedValue(store);

    await storeController.getStoreById(req, res);

    expect(storeService.getStoreById).toHaveBeenCalledWith(
      '550e8400-e29b-41d4-a716-446655440000',
      'user-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: store,
    });
  });

  it('creates a store for the authenticated user', async () => {
    const store = storeFixture();
    const payload = {
      name: 'Main Store',
      currencyCode: 'VND',
    };
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      body: payload,
    });
    const res = createResponse<StoreResponseDto>();

    storeService.createNewStore.mockResolvedValue(store);

    await storeController.createStore(req, res);

    expect(storeService.createNewStore).toHaveBeenCalledWith('user-1', payload);
    expect(res.status).toHaveBeenCalledWith(StatusCodes.CREATED);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: store,
    });
  });

  it('updates the store from request store context', async () => {
    const store = storeFixture({ name: 'Updated Store' });
    const payload = {
      name: 'Updated Store',
    };
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      storeContext: {
        storeId: '550e8400-e29b-41d4-a716-446655440000',
        role: 'owner',
      },
      body: payload,
    });
    const res = createResponse<StoreResponseDto>();

    storeService.updateStore.mockResolvedValue(store);

    await storeController.updateStore(req, res);

    expect(storeService.updateStore).toHaveBeenCalledWith(
      '550e8400-e29b-41d4-a716-446655440000',
      'user-1',
      payload,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: store,
    });
  });

  it('soft deletes a store by path id', async () => {
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      params: {
        storeId: '660e8400-e29b-41d4-a716-446655440000',
      },
    });
    const res = createResponse<StoreResponseDto>();

    storeService.softDeleteStore.mockResolvedValue(undefined);

    await storeController.softDeleteStore(req, res);

    expect(storeService.softDeleteStore).toHaveBeenCalledWith(
      '660e8400-e29b-41d4-a716-446655440000',
      'user-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: null,
    });
  });

  it('refreshes invite code for the current store context', async () => {
    const store = storeFixture({ inviteCode: 'eeee-ffff-gggg-hhhh' });
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      storeContext: {
        storeId: '550e8400-e29b-41d4-a716-446655440000',
        role: 'owner',
      },
    });
    const res = createResponse<StoreResponseDto>();

    storeService.refreshInviteCode.mockResolvedValue(store);

    await storeController.refreshInviteCode(req, res);

    expect(storeService.refreshInviteCode).toHaveBeenCalledWith(
      '550e8400-e29b-41d4-a716-446655440000',
      'user-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: store,
    });
  });

  it('joins a store by invite code without store context', async () => {
    const store = storeFixture();
    const req = createRequest({
      user: {
        userId: 'user-1',
        authUserId: 'auth-user-1',
        email: null,
      },
      body: {
        inviteCode: 'aaaa-bbbb-cccc-dddd',
      },
    });
    const res = createResponse<StoreResponseDto>();

    storeService.joinStoreByInviteCode.mockResolvedValue(store);

    await storeController.joinStore(req, res);

    expect(storeService.joinStoreByInviteCode).toHaveBeenCalledWith(
      'user-1',
      'aaaa-bbbb-cccc-dddd',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: store,
    });
  });

  it('throws when a protected controller method has no authenticated user', async () => {
    const req = createRequest({});
    const res = createResponse<StoreResponseDto[]>();

    await expect(storeController.getStores(req, res)).rejects.toMatchObject({
      message: 'User is not authenticated',
      status: StatusCodes.UNAUTHORIZED,
    });
    expect(storeService.getStoresByUserId).not.toHaveBeenCalled();
  });
});
