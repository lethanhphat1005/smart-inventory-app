import { prisma } from '../../../db/prismaClient.js';

export class NotificationRepository {
  // --- XỬ LÝ FCM TOKEN ---
  async upsertToken(userId: string, token: string) {
    return await prisma.fcmToken.upsert({
      where: { token },
      update: { userId },
      create: { token, userId },
    });
  }

  async deleteTokensByValue(token: string) {
    await prisma.fcmToken.deleteMany({ where: { token } });
  }

  async findTokensByUserId(userId: string) {
    return await prisma.fcmToken.findMany({ where: { userId } });
  }

  // --- XỬ LÝ IN-APP NOTIFICATION ---
  async createNotification(
    userId: string,
    storeId: string,
    title: string,
    body: string,
    type: string,
    referenceId?: string,
  ) {
    return await prisma.notification.create({
      data: {
        userId,
        storeId,
        title,
        body,
        type,
        referenceId: referenceId ?? null,
      },
    });
  }

  async getUserNotifications(
    userId: string,
    storeId: string,
    page: number,
    size: number,
    type?: string,
  ) {
    const skip = (page - 1) * size;

    const typeArray = type && type !== 'ALL' ? type.split(',') : undefined;

    return await prisma.notification.findMany({
      where: {
        userId,
        storeId,
        activeStatus: 'active',
        ...(typeArray ? { type: { in: typeArray } } : {}),
      },
      orderBy: { createdAt: 'desc' },
      skip: skip,
      take: size,
      include: {
        store: { select: { name: true } },
      },
    });
  }

  async markAsRead(userId: string, notificationId: string) {
    return await prisma.notification.updateMany({
      where: { notificationId, userId, activeStatus: 'active' },
      data: { isRead: true },
    });
  }

  async softDelete(userId: string, notificationId: string) {
    return await prisma.notification.updateMany({
      where: { notificationId, userId },
      data: { activeStatus: 'inactive' }, // Xóa mềm
    });
  }

  // Thêm hàm này để xóa một lúc nhiều token rác
  async deleteMultipleTokens(tokens: string[]) {
    await prisma.fcmToken.deleteMany({
      where: {
        token: { in: tokens },
      },
    });
  }

  async markAllAsRead(userId: string, storeId: string) {
    return await prisma.notification.updateMany({
      where: { userId, storeId, activeStatus: 'active', isRead: false },
      data: { isRead: true },
    });
  }

  async getStoreNameById(storeId: string): Promise<string> {
    const store = await prisma.store.findUnique({
      where: { storeId: storeId },
      select: { name: true }, // Chỉ lấy mỗi cột name cho nhẹ DB
    });

    // Nếu có store thì trả về tên, nếu không có (null) thì trả về 'Cửa hàng'
    return store?.name ?? 'Cửa hàng';
  }
}
