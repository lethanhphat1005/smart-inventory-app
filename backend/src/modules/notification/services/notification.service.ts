import { getMessaging, type MulticastMessage } from 'firebase-admin/messaging';

import { NotificationRepository } from '../repositories/notification.repository.js';

export class NotificationService {
  constructor(
    private readonly notificationRepository: NotificationRepository,
  ) {}

  // Quản lý Token
  public async registerToken(userId: string, token: string) {
    return await this.notificationRepository.upsertToken(userId, token);
  }

  public async removeToken(token: string) {
    await this.notificationRepository.deleteTokensByValue(token);
  }

  // --- LUỒNG CHÍNH: LƯU DB VÀ BẮN PUSH ---
  public async createAndSendNotification(
    userId: string,
    storeId: string,
    title: string,
    body: string,
    type: string,
    referenceId?: string,
  ): Promise<void> {
    const storeName =
      await this.notificationRepository.getStoreNameById(storeId);
    const displayTitle = `${storeName}\n${title}`;

    // 2. Lưu vào Database
    const newNoti = await this.notificationRepository.createNotification(
      userId,
      storeId,
      displayTitle,
      body,
      type,
      referenceId,
    );

    // 3. Lấy Token để bắn Push
    const tokens = await this.notificationRepository.findTokensByUserId(userId);

    if (tokens.length === 0) {
      return;
    }

    let fcmPriority: 'high' | 'normal' = 'normal';
    const sound: string = 'default';

    if (
      [
        'DISCREPANCY_ALERT',
        'LOW_STOCK',
        'BATCH_LOW_STOCK',
        'REORDER_SUGGESTION',
      ].includes(type)
    ) {
      fcmPriority = 'high';
    }

    // 4. Đóng gói Payload chuẩn
    const message: MulticastMessage = {
      notification: { title: displayTitle, body },
      data: {
        notificationId: newNoti.notificationId,
        type: newNoti.type,
        referenceId: newNoti.referenceId ?? '',
        storeId: storeId,
      },
      tokens: tokens.map((t) => t.token),
      android: {
        priority: fcmPriority,
        notification: {
          sound: sound,
          channelId:
            fcmPriority === 'high'
              ? 'high_importance_channel'
              : 'normal_channel',
        },
      },
      apns: {
        payload: {
          aps: { sound: sound, priority: fcmPriority === 'high' ? 10 : 5 },
        },
      },
    };

    // 4. Bắn qua Firebase và Dọn dẹp Token rác
    try {
      const response = await getMessaging().sendEachForMulticast(message);

      console.info(
        `[FCM] Gửi thành công: ${response.successCount}, Lỗi: ${response.failureCount}`,
      );

      // Nếu có lỗi xảy ra trong quá trình gửi
      if (response.failureCount > 0) {
        const failedTokens: string[] = [];

        // Duyệt qua từng kết quả trả về
        response.responses.forEach((resp, idx) => {
          if (!resp.success && resp.error) {
            const errorCode = resp.error.code;

            // Nếu lỗi là do token đã chết hoặc bị gỡ cài đặt
            if (
              errorCode === 'messaging/invalid-registration-token' ||
              errorCode === 'messaging/registration-token-not-registered'
            ) {
              // Thêm if check để làm hài lòng TypeScript Strict Mode
              if (tokens[idx] && tokens[idx].token) {
                failedTokens.push(tokens[idx].token);
              }
            }
          }
        });

        // Xóa các token rác khỏi Database để nhẹ DB và tăng tốc độ cho lần sau
        if (failedTokens.length > 0) {
          console.info(
            `[FCM] Đang dọn dẹp ${failedTokens.length} token rác khỏi Database...`,
          );
          await this.notificationRepository.deleteMultipleTokens(failedTokens);
        }
      }
    } catch (error) {
      console.error('Lỗi hệ thống khi gửi push notification:', error);
    }
  }

  // Cung cấp dữ liệu cho API Frontend
  public async getUserNotifications(
    userId: string,
    storeId: string,
    page: number,
    size: number,
    type: string,
  ) {
    return await this.notificationRepository.getUserNotifications(
      userId,
      storeId,
      page,
      size,
      type,
    );
  }

  public async markAsRead(userId: string, notificationId: string) {
    await this.notificationRepository.markAsRead(userId, notificationId);
  }

  public async softDeleteNotification(userId: string, notificationId: string) {
    await this.notificationRepository.softDelete(userId, notificationId);
  }

  public async markAllAsRead(userId: string, storeId: string) {
    await this.notificationRepository.markAllAsRead(userId, storeId);
  }
}
