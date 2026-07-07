import { StatusCodes } from 'http-status-codes';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { NotificationController } from '../../../../src/modules/notification/controllers/notification.controller.js';
import { createRequest, createResponse } from '../../../helpers/index.js';

type MockNotificationService = {
  registerToken: ReturnType<typeof vi.fn>;
  removeToken: ReturnType<typeof vi.fn>;
  getUserNotifications: ReturnType<typeof vi.fn>;
  markAsRead: ReturnType<typeof vi.fn>;
  softDeleteNotification: ReturnType<typeof vi.fn>;
  markAllAsRead: ReturnType<typeof vi.fn>;
  createAndSendNotification: ReturnType<typeof vi.fn>;
};

const user = {
  userId: 'user-1',
  authUserId: 'auth-user-1',
  email: 'user@example.com',
};

const createMockService = (): MockNotificationService => ({
  registerToken: vi.fn(),
  removeToken: vi.fn(),
  getUserNotifications: vi.fn(),
  markAsRead: vi.fn(),
  softDeleteNotification: vi.fn(),
  markAllAsRead: vi.fn(),
  createAndSendNotification: vi.fn(),
});

describe('NotificationController', () => {
  let service: MockNotificationService;
  let controller: NotificationController;

  beforeEach(() => {
    service = createMockService();
    controller = new NotificationController(service as never);
  });

  it('registerToken uses the authenticated user and request token', async () => {
    const savedToken = { userId: 'user-1', token: 'token-1' };
    const req = createRequest({ user, body: { token: 'token-1' } });
    const res = createResponse<typeof savedToken>();

    service.registerToken.mockResolvedValue(savedToken);

    await controller.registerToken(req, res);

    expect(service.registerToken).toHaveBeenCalledWith('user-1', 'token-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: savedToken,
    });
  });

  it('removeToken removes the request token', async () => {
    const req = createRequest({ body: { token: 'token-1' } });
    const res = createResponse<null>();

    await controller.removeToken(req, res);

    expect(service.removeToken).toHaveBeenCalledWith('token-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: null,
    });
  });

  it('getNotifications uses defaults and the store header', async () => {
    const notifications = [{ notificationId: 'notification-1' }];
    const req = createRequest({
      user,
      headers: { 'x-store-id': 'store-1' },
      query: {},
    });
    const res = createResponse<typeof notifications>();

    service.getUserNotifications.mockResolvedValue(notifications);

    await controller.getNotifications(req, res);

    expect(service.getUserNotifications).toHaveBeenCalledWith(
      'user-1',
      'store-1',
      1,
      15,
      undefined,
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: notifications,
    });
  });

  it('getNotifications parses pagination and type filters', async () => {
    const req = createRequest({
      user,
      headers: { 'x-store-id': 'store-1' },
      query: { page: '3', size: '20', type: 'LOW_STOCK' },
    });
    const res = createResponse();

    service.getUserNotifications.mockResolvedValue([]);

    await controller.getNotifications(req, res);

    expect(service.getUserNotifications).toHaveBeenCalledWith(
      'user-1',
      'store-1',
      3,
      20,
      'LOW_STOCK',
    );
  });

  it('getNotifications returns bad request when x-store-id is missing', async () => {
    const req = createRequest({ user, headers: {}, query: {} });
    const res = createResponse();

    await controller.getNotifications(req, res);

    expect(service.getUserNotifications).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(StatusCodes.BAD_REQUEST);
    expect(res.json).toHaveBeenCalledWith({
      success: false,
      message: 'Thiếu x-store-id trong Header',
    });
  });

  it('markAsRead marks the user notification as read', async () => {
    const req = createRequest({
      user,
      params: { notificationId: 'notification-1' },
    });
    const res = createResponse<null>();

    await controller.markAsRead(req, res);

    expect(service.markAsRead).toHaveBeenCalledWith('user-1', 'notification-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: null,
      message: 'Đã đánh dấu đọc',
    });
  });

  it('deleteNotification soft-deletes the user notification', async () => {
    const req = createRequest({
      user,
      params: { notificationId: 'notification-1' },
    });
    const res = createResponse<null>();

    await controller.deleteNotification(req, res);

    expect(service.softDeleteNotification).toHaveBeenCalledWith(
      'user-1',
      'notification-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: null,
      message: 'Đã xóa thông báo',
    });
  });

  it('markAllAsRead requires the store header', async () => {
    const req = createRequest({ user, headers: {} });
    const res = createResponse();

    await controller.markAllAsRead(req, res);

    expect(service.markAllAsRead).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(StatusCodes.BAD_REQUEST);
    expect(res.json).toHaveBeenCalledWith({
      success: false,
      message: 'Thiếu x-store-id trong Header',
    });
  });

  it('markAllAsRead marks all active store notifications as read', async () => {
    const req = createRequest({
      user,
      headers: { 'x-store-id': 'store-1' },
    });
    const res = createResponse<null>();

    await controller.markAllAsRead(req, res);

    expect(service.markAllAsRead).toHaveBeenCalledWith('user-1', 'store-1');
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: null,
      message: 'Đã đánh dấu đọc tất cả',
    });
  });

  it('testSend requires the store header', async () => {
    const req = createRequest({ user, headers: {}, body: {} });
    const res = createResponse();

    await controller.testSend(req, res);

    expect(service.createAndSendNotification).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(StatusCodes.BAD_REQUEST);
    expect(res.json).toHaveBeenCalledWith({
      success: false,
      message: 'Thiếu x-store-id trong Header',
    });
  });

  it('testSend creates and sends a notification', async () => {
    const req = createRequest({
      user,
      headers: { 'x-store-id': 'store-1' },
      body: {
        title: 'Title',
        body: 'Body',
        type: 'GENERAL',
        referenceId: 'product-1',
      },
    });
    const res = createResponse<null>();

    await controller.testSend(req, res);

    expect(service.createAndSendNotification).toHaveBeenCalledWith(
      'user-1',
      'store-1',
      'Title',
      'Body',
      'GENERAL',
      'product-1',
    );
    expect(res.status).toHaveBeenCalledWith(StatusCodes.OK);
    expect(res.json).toHaveBeenCalledWith({
      success: true,
      data: null,
    });
  });

  it('propagates service failures to the async route wrapper', async () => {
    const error = new Error('service unavailable');
    const req = createRequest({ user, body: { token: 'token-1' } });
    const res = createResponse();

    service.registerToken.mockRejectedValue(error);

    await expect(controller.registerToken(req, res)).rejects.toThrow(error);
    expect(res.status).not.toHaveBeenCalled();
    expect(res.json).not.toHaveBeenCalled();
  });
});
