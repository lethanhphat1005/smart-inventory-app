import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/notification_model.dart';
import 'package:frontend/core/infrastructure/models/user_profile_model.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/notification/providers/notification_provider.dart';
import 'package:frontend/features/notification/utils/notification_router.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

class NotificationController extends GetxController {
  final NotificationProvider _provider = NotificationProvider();

  // State quản lý danh sách và loading
  var notifications = <NotificationModel>[].obs;
  var isLoading = true.obs;
  var isLoadMore = false.obs;
  var unreadCount = 0.obs;
  UserProfileModel? currentUser;

  // Logic phân trang
  final ScrollController scrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 15;
  bool _hasMore = true;

  // Biến quản lý Filter
  var selectedFilter = 'ALL'.obs;

  // Service lấy storeId
  final storeService = Get.find<StoreService>();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();

    _setupPagination();
  }

  void _setupPagination() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!_hasMore || isLoadMore.value || isLoading.value) return;
        fetchMoreNotifications();
      }
    });
  }

  Future<void> fetchNotifications() async {
    try {
      _currentPage = 1;
      _hasMore = true;
      isLoading.value = true;

      final String currentStoreId = storeService.currentStoreId.value;
      if (currentStoreId.isEmpty) {
        return;
      }

      final response = await _provider.fetchNotifications(
          page: _currentPage,
          size: _pageSize,
          type: selectedFilter.value,
          storeId: currentStoreId);

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        notifications.value =
            data.map((json) => NotificationModel.fromJson(json)).toList();

        if (data.length < _pageSize) _hasMore = false;
        _updateUnreadCount();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreNotifications() async {
    try {
      isLoadMore.value = true;
      _currentPage++;

      final String currentStoreId = storeService.currentStoreId.value;
      if (currentStoreId.isEmpty) {
        return;
      }

      final response = await _provider.fetchNotifications(
          page: _currentPage, size: _pageSize, storeId: currentStoreId);

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        if (data.isEmpty) {
          _hasMore = false;
        } else {
          final nextItems =
              data.map((json) => NotificationModel.fromJson(json)).toList();
          notifications.addAll(nextItems);
          if (data.length < _pageSize) _hasMore = false;
        }
      }
    } finally {
      isLoadMore.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.notificationId == id);
    if (index == -1 || notifications[index].isRead) return;

    notifications[index].isRead = true;
    notifications.refresh();
    _updateUnreadCount();

    try {
      await _provider.markAsRead(id);
    } catch (e) {
      debugPrint("⚠️ Lỗi API markAsRead: $e");
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0) return;

    for (var noti in notifications) {
      noti.isRead = true;
    }
    notifications.refresh();
    _updateUnreadCount();

    try {
      await _provider.markAllAsRead();
    } catch (e) {
      debugPrint("⚠️ Lỗi API markAllAsRead: $e");
    }
  }

  void deleteNotificationWithUndo(NotificationModel item, int index) {
    final context = Get.context;
    if (context == null) return;

    notifications.removeAt(index);
    _updateUnreadCount();

    bool isUndone = false;

    final snackbar = TSnackbarsWidget.undoSnackBar(
      context: context,
      title: TTexts.notificationDeleted.tr,
      message: TTexts.undoAvailable.tr,
      buttonName: TTexts.undoButton.tr,
      onUndo: () {
        isUndone = true;
        int safeIndex =
            index > notifications.length ? notifications.length : index;
        notifications.insert(safeIndex, item);
        _updateUnreadCount();
      },
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(snackbar)
        .closed
        .then((reason) async {
      if (!isUndone && reason != SnackBarClosedReason.action) {
        try {
          await _provider.deleteNotification(item.notificationId);
        } catch (e) {
          int safeIndex =
              index > notifications.length ? notifications.length : index;
          notifications.insert(safeIndex, item);
          _updateUnreadCount();

          TSnackbarsWidget.error(
              title: TTexts.connectionError.tr,
              message: TTexts.cannotDeleteNotification.tr);
        }
      }
    });
  }

  void changeFilter(String newFilter) {
    if (selectedFilter.value == newFilter) return;
    selectedFilter.value = newFilter;
    fetchNotifications();
  }

  Future<void> handleNotificationClick(NotificationModel item) async {
    if (item.type == 'ROLE_UPDATED') {
      if (item.isRead) {
        TSnackbarsWidget.info(
          title: TTexts.informationTitle.tr,
          message: TTexts.informationContent.tr,
        );
        return;
      }
    }

    if (!item.isRead) {
      await markAsRead(item.notificationId);
    }

    NotificationRouter.navigate(item.type, item.referenceId, item.storeId);
  }

  String formatTimeAgo(dynamic timeData) {
    if (timeData == null) return '';
    try {
      DateTime date = (timeData is DateTime)
          ? timeData.toLocal()
          : DateTime.parse(timeData.toString()).toLocal();
      final difference = DateTime.now().difference(date);

      if (difference.inDays > 7) {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${TTexts.daysAgo.tr}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${TTexts.hoursAgo.tr}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${TTexts.minutesAgo.tr}';
      } else {
        return TTexts.justNow.tr;
      }
    } catch (e) {
      return '';
    }
  }
}
