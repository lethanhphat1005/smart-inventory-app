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
    // _getArgument();
    fetchNotifications();

    _setupPagination();
    // _setupRealtime();
  }

  // ==========================================
  // HÀM LẤY ARGUMENT TỪ ROUTE
  // ==========================================
  // void _getArgument() {
  //   final args = Get.arguments;

  //   if (args != null) {
  //     if (args is UserProfileModel) {
  //       currentUser = args;
  //     } else if (args is Rxn<UserProfileModel>) {
  //       currentUser = args.value;
  //     }

  //     if (currentUser != null) {
  //       debugPrint("🎯 Đã nhận thông báo cho user: ${currentUser!.fullName}");
  //     } else {
  //       debugPrint(
  //           "⚠️ Argument có tồn tại nhưng dữ liệu bên trong bị rỗng (null)");
  //     }
  //   } else {
  //     // Đây là nơi thông báo lỗi bạn đang thấy xuất hiện
  //     debugPrint("⚠️ Không nhận được bất kỳ argument nào từ trang trước!");
  //   }
  // }

  // ==========================================
  // 1. SETUP REALTIME (SUPABASE)
  // ==========================================
  // void _setupRealtime(String currentUserId) {
  //   // Tạm thời hardcode userId để test, sau này bạn lấy từ State management của bạn (GetX/Provider)
  //   //const currentUserId = '665ef842-704d-4479-b996-fc9e2c663587';

  //   if (currentUserId.isEmpty) return;

  //   Supabase.instance.client
  //       .channel('public:notification')
  //       .onPostgresChanges(
  //         event: PostgresChangeEvent.insert,
  //         schema: 'public',
  //         // 👇 SỬA Ở ĐÂY: Chữ 'notification' phải viết thường y hệt trong Database
  //         table: 'notification',
  //         filter: PostgresChangeFilter(
  //           type: PostgresChangeFilterType.eq,
  //           column:
  //               'user_id', // 👈 LƯU Ý: Prisma thường map xuống DB là snake_case.
  //           // Bạn hãy check lại trong bảng notification xem cột lưu ID
  //           // người dùng là 'userId' hay 'user_id' để truyền cho đúng nhé!
  //           value: currentUserId,
  //         ),
  //         callback: (payload) {
  //           debugPrint(
  //               '🔔 REALTIME BÁO CÓ THÔNG BÁO MỚI: ${payload.newRecord}');

  //           // Tải lại danh sách từ trang 1
  //           fetchNotifications();
  //         },
  //       )
  //       .subscribe();
  // }

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

  void handleNotificationClick(NotificationModel item) {
    if (!item.isRead) {
      markAsRead(item.notificationId);
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
