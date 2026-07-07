import { beforeEach, describe, expect, it, vi } from 'vitest';

import { NotificationService } from '../../../../src/modules/notification/services/notification.service.js';

const firebaseMocks = vi.hoisted(() => ({
  sendEachForMulticast: vi.fn(),
}));

vi.mock('firebase-admin/messaging', () => ({
  getMessaging: vi.fn(() => ({
    sendEachForMulticast: firebaseMocks.sendEachForMulticast,
  })),
}));

type MockNotificationRepository = {
  upsertToken: ReturnType<typeof vi.fn>;
  deleteTokensByValue: ReturnType<typeof vi.fn>;
  getStoreNameById: ReturnType<typeof vi.fn>;
  createNotification: ReturnType<typeof vi.fn>;
  findTokensByUserId: ReturnType<typeof vi.fn>;
  deleteMultipleTokens: ReturnType<typeof vi.fn>;
  getUserNotifications: ReturnType<typeof vi.fn>;
  markAsRead: ReturnType<typeof vi.fn>;
  softDelete: ReturnType<typeof vi.fn>;
  markAllAsRead: ReturnType<typeof vi.fn>;
};

const createMockRepository = (): MockNotificationRepository => ({
  upsertToken: vi.fn(),
  deleteTokensByValue: vi.fn(),
  getStoreNameById: vi.fn(),
  createNotification: vi.fn(),
  findTokensByUserId: vi.fn(),
  deleteMultipleTokens: vi.fn(),
  getUserNotifications: vi.fn(),
  markAsRead: vi.fn(),
  softDelete: vi.fn(),
  markAllAsRead: vi.fn(),
});

describe('NotificationService', () => {
  let repository: MockNotificationRepository;
  let service: NotificationService;

  beforeEach(() => {
    vi.clearAllMocks();
    repository = createMockRepository();
    service = new NotificationService(repository as never);
  });

  it('registerToken upserts the user FCM token', async () => {
    const savedToken = { userId: 'user-1', token: 'token-1' };

    repository.upsertToken.mockResolvedValue(savedToken);

    const result = await service.registerToken('user-1', 'token-1');

    expect(result).toEqual(savedToken);
    expect(repository.upsertToken).toHaveBeenCalledWith('user-1', 'token-1');
  });

  it('removeToken deletes all matching token rows', async () => {
    await service.removeToken('token-1');

    expect(repository.deleteTokensByValue).toHaveBeenCalledWith('token-1');
  });

  it('creates an in-app notification and skips Firebase when the user has no tokens', async () => {
    repository.getStoreNameById.mockResolvedValue('Main Store');
    repository.createNotification.mockResolvedValue({
      notificationId: 'notification-1',
      type: 'GENERAL',
      referenceId: null,
    });
    repository.findTokensByUserId.mockResolvedValue([]);

    await service.createAndSendNotification(
      'user-1',
      'store-1',
      'Hello',
      'Body',
      'GENERAL',
    );

    expect(repository.createNotification).toHaveBeenCalledWith(
      'user-1',
      'store-1',
      'Main Store\nHello',
      'Body',
      'GENERAL',
      undefined,
    );
    expect(firebaseMocks.sendEachForMulticast).not.toHaveBeenCalled();
  });

  it('sends normal-priority push notifications with reference data', async () => {
    repository.getStoreNameById.mockResolvedValue('Main Store');
    repository.createNotification.mockResolvedValue({
      notificationId: 'notification-1',
      type: 'GENERAL',
      referenceId: 'product-1',
    });
    repository.findTokensByUserId.mockResolvedValue([
      { token: 'token-1' },
      { token: 'token-2' },
    ]);
    firebaseMocks.sendEachForMulticast.mockResolvedValue({
      failureCount: 0,
      responses: [{ success: true }, { success: true }],
    });

    await service.createAndSendNotification(
      'user-1',
      'store-1',
      'Hello',
      'Body',
      'GENERAL',
      'product-1',
    );

    expect(firebaseMocks.sendEachForMulticast).toHaveBeenCalledWith({
      notification: { title: 'Main Store\nHello', body: 'Body' },
      data: {
        notificationId: 'notification-1',
        type: 'GENERAL',
        referenceId: 'product-1',
        storeId: 'store-1',
      },
      tokens: ['token-1', 'token-2'],
      android: {
        priority: 'normal',
        notification: {
          sound: 'default',
          channelId: 'normal_channel',
        },
      },
      apns: {
        payload: {
          aps: { sound: 'default', priority: 5 },
        },
      },
    });
  });

  it('uses high priority for urgent notification types and cleans invalid tokens', async () => {
    repository.getStoreNameById.mockResolvedValue('Main Store');
    repository.createNotification.mockResolvedValue({
      notificationId: 'notification-1',
      type: 'LOW_STOCK',
      referenceId: null,
    });
    repository.findTokensByUserId.mockResolvedValue([
      { token: 'alive-token' },
      { token: 'invalid-token' },
      { token: 'retryable-token' },
      { token: 'unregistered-token' },
    ]);
    firebaseMocks.sendEachForMulticast.mockResolvedValue({
      failureCount: 3,
      responses: [
        { success: true },
        {
          success: false,
          error: { code: 'messaging/invalid-registration-token' },
        },
        {
          success: false,
          error: { code: 'messaging/internal-error' },
        },
        {
          success: false,
          error: { code: 'messaging/registration-token-not-registered' },
        },
      ],
    });

    await service.createAndSendNotification(
      'user-1',
      'store-1',
      'Low stock',
      'Restock milk',
      'LOW_STOCK',
    );

    expect(firebaseMocks.sendEachForMulticast).toHaveBeenCalledWith(
      expect.objectContaining({
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'high_importance_channel',
          },
        },
        apns: {
          payload: {
            aps: { sound: 'default', priority: 10 },
          },
        },
      }),
    );
    expect(repository.deleteMultipleTokens).toHaveBeenCalledWith([
      'invalid-token',
      'unregistered-token',
    ]);
  });

  it('does not delete tokens for non-stale Firebase failures', async () => {
    repository.getStoreNameById.mockResolvedValue('Main Store');
    repository.createNotification.mockResolvedValue({
      notificationId: 'notification-1',
      type: 'GENERAL',
      referenceId: null,
    });
    repository.findTokensByUserId.mockResolvedValue([{ token: 'token-1' }]);
    firebaseMocks.sendEachForMulticast.mockResolvedValue({
      failureCount: 1,
      responses: [
        {
          success: false,
          error: { code: 'messaging/internal-error' },
        },
      ],
    });

    await service.createAndSendNotification(
      'user-1',
      'store-1',
      'Hello',
      'Body',
      'GENERAL',
    );

    expect(repository.deleteMultipleTokens).not.toHaveBeenCalled();
  });

  it('ignores stale Firebase failures that do not map to a local token', async () => {
    repository.getStoreNameById.mockResolvedValue('Main Store');
    repository.createNotification.mockResolvedValue({
      notificationId: 'notification-1',
      type: 'GENERAL',
      referenceId: null,
    });
    repository.findTokensByUserId.mockResolvedValue([{ token: 'token-1' }]);
    firebaseMocks.sendEachForMulticast.mockResolvedValue({
      failureCount: 1,
      responses: [
        { success: true },
        {
          success: false,
          error: { code: 'messaging/invalid-registration-token' },
        },
      ],
    });

    await service.createAndSendNotification(
      'user-1',
      'store-1',
      'Hello',
      'Body',
      'GENERAL',
    );

    expect(repository.deleteMultipleTokens).not.toHaveBeenCalled();
  });

  it('does not clean stale Firebase failures for blank token values', async () => {
    repository.getStoreNameById.mockResolvedValue('Main Store');
    repository.createNotification.mockResolvedValue({
      notificationId: 'notification-1',
      type: 'GENERAL',
      referenceId: null,
    });
    repository.findTokensByUserId.mockResolvedValue([{ token: '' }]);
    firebaseMocks.sendEachForMulticast.mockResolvedValue({
      failureCount: 1,
      responses: [
        {
          success: false,
          error: { code: 'messaging/registration-token-not-registered' },
        },
      ],
    });

    await service.createAndSendNotification(
      'user-1',
      'store-1',
      'Hello',
      'Body',
      'GENERAL',
    );

    expect(repository.deleteMultipleTokens).not.toHaveBeenCalled();
  });

  it('logs and swallows Firebase send failures after persisting the notification', async () => {
    const consoleErrorSpy = vi
      .spyOn(console, 'error')
      .mockImplementation(() => undefined);

    repository.getStoreNameById.mockResolvedValue('Main Store');
    repository.createNotification.mockResolvedValue({
      notificationId: 'notification-1',
      type: 'GENERAL',
      referenceId: null,
    });
    repository.findTokensByUserId.mockResolvedValue([{ token: 'token-1' }]);
    firebaseMocks.sendEachForMulticast.mockRejectedValue(
      new Error('firebase unavailable'),
    );

    await expect(
      service.createAndSendNotification(
        'user-1',
        'store-1',
        'Hello',
        'Body',
        'GENERAL',
      ),
    ).resolves.toBeUndefined();
    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'Lỗi hệ thống khi gửi push notification:',
      expect.any(Error),
    );

    consoleErrorSpy.mockRestore();
  });

  it('delegates notification queries and mutations to the repository', async () => {
    const notifications = [{ notificationId: 'notification-1' }];

    repository.getUserNotifications.mockResolvedValue(notifications);

    await expect(
      service.getUserNotifications('user-1', 'store-1', 2, 20, 'LOW_STOCK'),
    ).resolves.toEqual(notifications);
    await service.markAsRead('user-1', 'notification-1');
    await service.softDeleteNotification('user-1', 'notification-1');
    await service.markAllAsRead('user-1', 'store-1');

    expect(repository.getUserNotifications).toHaveBeenCalledWith(
      'user-1',
      'store-1',
      2,
      20,
      'LOW_STOCK',
    );
    expect(repository.markAsRead).toHaveBeenCalledWith(
      'user-1',
      'notification-1',
    );
    expect(repository.softDelete).toHaveBeenCalledWith(
      'user-1',
      'notification-1',
    );
    expect(repository.markAllAsRead).toHaveBeenCalledWith('user-1', 'store-1');
  });
});
