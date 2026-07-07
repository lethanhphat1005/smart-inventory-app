import { beforeEach, describe, expect, it, vi } from 'vitest';

import { NotificationRepository } from '../../../../src/modules/notification/repositories/notification.repository.js';

const prismaMock = vi.hoisted(() => ({
  prisma: {
    fcmToken: {
      upsert: vi.fn(),
      deleteMany: vi.fn(),
      findMany: vi.fn(),
    },
    notification: {
      create: vi.fn(),
      findMany: vi.fn(),
      updateMany: vi.fn(),
    },
    store: {
      findUnique: vi.fn(),
    },
  },
}));

vi.mock('../../../../src/db/prismaClient.js', () => ({
  prisma: prismaMock.prisma,
}));

describe('NotificationRepository', () => {
  let repository: NotificationRepository;

  beforeEach(() => {
    vi.clearAllMocks();
    repository = new NotificationRepository();
  });

  it('upsertToken creates or reassigns a token by token value', async () => {
    const tokenRow = { userId: 'user-1', token: 'token-1' };

    prismaMock.prisma.fcmToken.upsert.mockResolvedValue(tokenRow);

    const result = await repository.upsertToken('user-1', 'token-1');

    expect(result).toEqual(tokenRow);
    expect(prismaMock.prisma.fcmToken.upsert).toHaveBeenCalledWith({
      where: { token: 'token-1' },
      update: { userId: 'user-1' },
      create: { token: 'token-1', userId: 'user-1' },
    });
  });

  it('deleteTokensByValue deletes all rows for a token value', async () => {
    await repository.deleteTokensByValue('token-1');

    expect(prismaMock.prisma.fcmToken.deleteMany).toHaveBeenCalledWith({
      where: { token: 'token-1' },
    });
  });

  it('findTokensByUserId queries tokens for one user', async () => {
    const rows = [{ token: 'token-1' }];

    prismaMock.prisma.fcmToken.findMany.mockResolvedValue(rows);

    await expect(repository.findTokensByUserId('user-1')).resolves.toEqual(
      rows,
    );
    expect(prismaMock.prisma.fcmToken.findMany).toHaveBeenCalledWith({
      where: { userId: 'user-1' },
    });
  });

  it('createNotification stores notification data and normalizes missing referenceId to null', async () => {
    const row = { notificationId: 'notification-1' };

    prismaMock.prisma.notification.create.mockResolvedValue(row);

    await expect(
      repository.createNotification(
        'user-1',
        'store-1',
        'Title',
        'Body',
        'GENERAL',
      ),
    ).resolves.toEqual(row);
    expect(prismaMock.prisma.notification.create).toHaveBeenCalledWith({
      data: {
        userId: 'user-1',
        storeId: 'store-1',
        title: 'Title',
        body: 'Body',
        type: 'GENERAL',
        referenceId: null,
      },
    });
  });

  it('createNotification preserves a provided referenceId', async () => {
    await repository.createNotification(
      'user-1',
      'store-1',
      'Title',
      'Body',
      'GENERAL',
      'product-1',
    );

    expect(prismaMock.prisma.notification.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ referenceId: 'product-1' }),
      }),
    );
  });

  it('getUserNotifications queries active store-scoped notifications without type filter for ALL', async () => {
    const rows = [{ notificationId: 'notification-1' }];

    prismaMock.prisma.notification.findMany.mockResolvedValue(rows);

    await expect(
      repository.getUserNotifications('user-1', 'store-1', 2, 15, 'ALL'),
    ).resolves.toEqual(rows);
    expect(prismaMock.prisma.notification.findMany).toHaveBeenCalledWith({
      where: {
        userId: 'user-1',
        storeId: 'store-1',
        activeStatus: 'active',
      },
      orderBy: { createdAt: 'desc' },
      skip: 15,
      take: 15,
      include: {
        store: { select: { name: true } },
      },
    });
  });

  it('getUserNotifications applies comma-separated type filters', async () => {
    await repository.getUserNotifications(
      'user-1',
      'store-1',
      1,
      20,
      'LOW_STOCK,ROLE_UPDATED',
    );

    expect(prismaMock.prisma.notification.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          userId: 'user-1',
          storeId: 'store-1',
          activeStatus: 'active',
          type: { in: ['LOW_STOCK', 'ROLE_UPDATED'] },
        },
        skip: 0,
        take: 20,
      }),
    );
  });

  it('markAsRead only updates the active notification owned by the user', async () => {
    await repository.markAsRead('user-1', 'notification-1');

    expect(prismaMock.prisma.notification.updateMany).toHaveBeenCalledWith({
      where: {
        notificationId: 'notification-1',
        userId: 'user-1',
        activeStatus: 'active',
      },
      data: { isRead: true },
    });
  });

  it('softDelete marks the user notification inactive', async () => {
    await repository.softDelete('user-1', 'notification-1');

    expect(prismaMock.prisma.notification.updateMany).toHaveBeenCalledWith({
      where: { notificationId: 'notification-1', userId: 'user-1' },
      data: { activeStatus: 'inactive' },
    });
  });

  it('deleteMultipleTokens deletes stale tokens in bulk', async () => {
    await repository.deleteMultipleTokens(['token-1', 'token-2']);

    expect(prismaMock.prisma.fcmToken.deleteMany).toHaveBeenCalledWith({
      where: {
        token: { in: ['token-1', 'token-2'] },
      },
    });
  });

  it('markAllAsRead updates unread active notifications for a user and store', async () => {
    await repository.markAllAsRead('user-1', 'store-1');

    expect(prismaMock.prisma.notification.updateMany).toHaveBeenCalledWith({
      where: {
        userId: 'user-1',
        storeId: 'store-1',
        activeStatus: 'active',
        isRead: false,
      },
      data: { isRead: true },
    });
  });

  it('getStoreNameById returns the store name when present', async () => {
    prismaMock.prisma.store.findUnique.mockResolvedValue({
      name: 'Main Store',
    });

    await expect(repository.getStoreNameById('store-1')).resolves.toBe(
      'Main Store',
    );
    expect(prismaMock.prisma.store.findUnique).toHaveBeenCalledWith({
      where: { storeId: 'store-1' },
      select: { name: true },
    });
  });

  it('getStoreNameById falls back when the store is missing', async () => {
    prismaMock.prisma.store.findUnique.mockResolvedValue(null);

    await expect(repository.getStoreNameById('store-missing')).resolves.toBe(
      'Cửa hàng',
    );
  });
});
