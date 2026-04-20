import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enNotification = {
  // UI
  TTexts.notificationTitle: 'Notifications',
  TTexts.loadingNotifications: 'Loading notifications...',
  TTexts.emptyNotificationTitle: 'No notifications yet',
  TTexts.emptyNotificationSub:
      'When you have new updates, they will appear here.',
  TTexts.reload: 'Reload',

  // Snackbars
  TTexts.notificationDeleted: 'Notification deleted',
  TTexts.undoAvailable: 'Can be undone in 5 seconds',
  TTexts.connectionError: 'Connection Error',
  TTexts.cannotDeleteNotification: 'Cannot delete notification at this time.',
  TTexts.undoButton: 'Undo',

  // Time Ago
  TTexts.daysAgo: 'days ago',
  TTexts.hoursAgo: 'hours ago',
  TTexts.minutesAgo: 'minutes ago',
  TTexts.justNow: 'Just now',

  TTexts.filterAll: 'All',
  TTexts.filterAlerts: 'Alerts',
  TTexts.filterTransactions: 'Transactions',
  TTexts.filterSystem: 'System',

  TTexts.filterLowStock: 'Low Stock',
  TTexts.filterDiscrepancy: 'Discrepancy',
  TTexts.filterReorder: 'Reorder Suggestion',
  TTexts.filterImport: 'Import',
  TTexts.filterExport: 'Export',

  TTexts.storeNotFound: 'Store not found.',
  TTexts.cannotAccessStore: 'Cannot access store.',
  TTexts.sessionExpiredTitle: 'Session Expired',
  TTexts.sessionExpiredMessage:
      'Your permissions have changed. Please log in again.',
};
