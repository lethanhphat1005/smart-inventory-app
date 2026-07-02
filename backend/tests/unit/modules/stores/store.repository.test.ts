import { beforeEach, describe, expect, it, vi } from 'vitest';

import { StoreRepository } from '../../../../src/modules/stores/store.repository.js';

const createMockDb = () => ({
  store: {
    findMany: vi.fn(),
    findFirst: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
  },
});

describe('StoreRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let storeRepository: StoreRepository;

  beforeEach(() => {
    db = createMockDb();
    storeRepository = new StoreRepository(db as never);
  });

  it('findManybyUserId scopes stores by active store and membership', async () => {
    db.store.findMany.mockResolvedValue([]);

    await storeRepository.findManybyUserId('user-1');

    expect(db.store.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          activeStatus: 'active',
          storeMembers: {
            some: {
              userId: 'user-1',
              activeStatus: 'active',
            },
          },
        },
      }),
    );
  });

  it('findByIdAndUserId enforces membership ownership', async () => {
    db.store.findFirst.mockResolvedValue(null);

    await storeRepository.findByIdAndUserId('store-1', 'user-1');

    expect(db.store.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          storeId: 'store-1',
          activeStatus: 'active',
          storeMembers: {
            some: {
              userId: 'user-1',
              activeStatus: 'active',
            },
          },
        },
      }),
    );
  });

  it('findById returns active stores by storeId', async () => {
    db.store.findFirst.mockResolvedValue({ storeId: 'store-1' });

    await storeRepository.findById('store-1');

    expect(db.store.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          storeId: 'store-1',
          activeStatus: 'active',
        },
      }),
    );
  });

  it('createOne writes the generated invite code and payload', async () => {
    db.store.create.mockResolvedValue({ storeId: 'store-1' });

    await storeRepository.createOne({
      name: 'Main Store',
      address: null,
      timezone: null,
      currencyCode: 'VND',
      userId: 'user-1',
      inviteCode: 'aaaa-bbbb-cccc-dddd',
    });

    expect(db.store.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: {
          name: 'Main Store',
          address: null,
          timezone: null,
          currencyCode: 'VND',
          userId: 'user-1',
          inviteCode: 'aaaa-bbbb-cccc-dddd',
        },
      }),
    );
  });

  it('updateOne updates by storeId only', async () => {
    db.store.update.mockResolvedValue({ storeId: 'store-1' });

    await storeRepository.updateOne('store-1', { name: 'Updated Store' });

    expect(db.store.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { storeId: 'store-1' },
        data: { name: 'Updated Store' },
      }),
    );
  });

  it('disableOne soft deletes the store', async () => {
    db.store.update.mockResolvedValue({ storeId: 'store-1' });

    await storeRepository.disableOne('store-1');

    expect(db.store.update).toHaveBeenCalledWith({
      where: { storeId: 'store-1' },
      data: {
        activeStatus: 'inactive',
      },
    });
  });

  it('updateInviteCode updates the invite code by storeId', async () => {
    db.store.update.mockResolvedValue({ storeId: 'store-1' });

    await storeRepository.updateInviteCode('store-1', 'eeee-ffff-gggg-hhhh');

    expect(db.store.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { storeId: 'store-1' },
        data: {
          inviteCode: 'eeee-ffff-gggg-hhhh',
        },
      }),
    );
  });

  it('findByInviteCode only returns active stores', async () => {
    db.store.findFirst.mockResolvedValue(null);

    await storeRepository.findByInviteCode('aaaa-bbbb-cccc-dddd');

    expect(db.store.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          inviteCode: 'aaaa-bbbb-cccc-dddd',
          activeStatus: 'active',
        },
      }),
    );
  });
});
