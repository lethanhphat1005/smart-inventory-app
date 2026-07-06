import { beforeEach, describe, expect, it, vi } from 'vitest';

import { StoreMemberRepository } from '../../../../src/modules/store-member/repository/store-member.repository.js';

const createMockDb = () => ({
  storeMember: {
    findFirst: vi.fn(),
    findUnique: vi.fn(),
    findMany: vi.fn(),
    update: vi.fn(),
    create: vi.fn(),
  },
});

describe('StoreMemberRepository', () => {
  let db: ReturnType<typeof createMockDb>;
  let repository: StoreMemberRepository;

  beforeEach(() => {
    db = createMockDb();
    repository = new StoreMemberRepository(db as never);
  });

  it('findOne scopes membership by user, store, and active status', async () => {
    db.storeMember.findFirst.mockResolvedValue(null);

    await repository.findOne('user-1', 'store-1');

    expect(db.storeMember.findFirst).toHaveBeenCalledWith({
      where: { userId: 'user-1', storeId: 'store-1', activeStatus: 'active' },
      select: {
        userId: true,
        storeId: true,
        role: true,
        joinedAt: true,
        activeStatus: true,
      },
    });
  });

  it('findByIdsWithStore fetches the composite membership with owner id', async () => {
    db.storeMember.findUnique.mockResolvedValue(null);

    await repository.findByIdsWithStore('user-1', 'store-1');

    expect(db.storeMember.findUnique).toHaveBeenCalledWith({
      where: {
        userId_storeId: { userId: 'user-1', storeId: 'store-1' },
      },
      include: {
        store: {
          select: { userId: true },
        },
      },
    });
  });

  it('findManyByStoreId returns active members with active users only', async () => {
    db.storeMember.findMany.mockResolvedValue([]);

    await repository.findManyByStoreId('store-1');

    expect(db.storeMember.findMany).toHaveBeenCalledWith({
      where: {
        storeId: 'store-1',
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
    });
  });

  it('softDeleteMember marks the membership inactive by composite key', async () => {
    db.storeMember.update.mockResolvedValue({ userId: 'user-1' });

    await repository.softDeleteMember('user-1', 'store-1');

    expect(db.storeMember.update).toHaveBeenCalledWith({
      where: {
        userId_storeId: {
          userId: 'user-1',
          storeId: 'store-1',
        },
      },
      data: {
        activeStatus: 'inactive',
      },
    });
  });

  it('updateRole updates only the role by composite key', async () => {
    db.storeMember.update.mockResolvedValue({ userId: 'user-1' });

    await repository.updateRole('user-1', 'store-1', 'manager');

    expect(db.storeMember.update).toHaveBeenCalledWith({
      where: {
        userId_storeId: {
          userId: 'user-1',
          storeId: 'store-1',
        },
      },
      data: {
        role: 'manager',
      },
    });
  });

  it('createOne creates a membership and selects public fields', async () => {
    db.storeMember.create.mockResolvedValue({ userId: 'user-1' });

    await repository.createOne({
      userId: 'user-1',
      storeId: 'store-1',
      role: 'staff',
    });

    expect(db.storeMember.create).toHaveBeenCalledWith({
      data: {
        userId: 'user-1',
        storeId: 'store-1',
        role: 'staff',
      },
      select: {
        userId: true,
        storeId: true,
        role: true,
        activeStatus: true,
        joinedAt: true,
      },
    });
  });

  it('findOneByUserIdAndStoreId scopes RBAC lookup to active store membership', async () => {
    db.storeMember.findFirst.mockResolvedValue(null);

    await repository.findOneByUserIdAndStoreId('user-1', 'store-1');

    expect(db.storeMember.findFirst).toHaveBeenCalledWith({
      where: {
        userId: 'user-1',
        storeId: 'store-1',
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
  });

  it('reactivateMembership restores active status and role', async () => {
    db.storeMember.update.mockResolvedValue({ userId: 'user-1' });

    await repository.reactivateMembership('user-1', 'store-1', 'manager');

    expect(db.storeMember.update).toHaveBeenCalledWith({
      where: { userId_storeId: { userId: 'user-1', storeId: 'store-1' } },
      data: { activeStatus: 'active', role: 'manager' },
    });
  });
});
