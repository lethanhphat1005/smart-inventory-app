import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> viNotification = {
  // UI
  TTexts.notificationTitle: 'Thông Báo',
  TTexts.loadingNotifications: 'Đang tải thông báo...',
  TTexts.emptyNotificationTitle: 'Chưa có thông báo',
  TTexts.emptyNotificationSub:
      'Khi có cập nhật mới, chúng sẽ xuất hiện tại đây.',
  TTexts.reload: 'Tải Lại',

  // Snackbars
  TTexts.notificationDeleted: 'Đã xóa thông báo',
  TTexts.undoAvailable: 'Có thể hoàn tác trong 5 giây',
  TTexts.connectionError: 'Lỗi Kết Nối',
  TTexts.cannotDeleteNotification: 'Không thể xóa thông báo vào lúc này.',
  TTexts.undoButton: 'Hoàn Tác',
  TTexts.noPermissionTitle: 'Thay Đổi Quyền Hạn',
  TTexts.noPermissionContent:
      'Vui lòng đăng nhập lại để cập nhật quyền của bạn.',
  TTexts.informationTitle: 'Thông Tin',
  TTexts.informationContent: 'Thông báo này đã được xử lý trước đó.',

  // Time Ago
  TTexts.daysAgo: 'ngày trước',
  TTexts.hoursAgo: 'giờ trước',
  TTexts.minutesAgo: 'phút trước',
  TTexts.justNow: 'Vừa xong',

  TTexts.filterAll: 'Tất Cả',
  TTexts.filterAlerts: 'Cảnh Báo',
  TTexts.filterTransactions: 'Giao Dịch',
  TTexts.filterSystem: 'Hệ Thống',

  TTexts.filterLowStock: 'Tồn Kho Thấp',
  TTexts.filterDiscrepancy: 'Chênh Lệch',
  TTexts.filterReorder: 'Gợi Ý Nhập Hàng',
  TTexts.filterImport: 'Nhập Kho',
  TTexts.filterExport: 'Xuất Kho',

  TTexts.storeNotFound: 'Không tìm thấy cửa hàng.',
  TTexts.cannotAccessStore: 'Không thể truy cập cửa hàng.',
  TTexts.sessionExpiredTitle: 'Phiên Đăng Nhập Hết Hạn',
  TTexts.sessionExpiredMessage:
      'Quyền của bạn đã thay đổi. Vui lòng đăng nhập lại.',
};
