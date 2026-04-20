import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/notification/utils/notification_constants.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:frontend/core/infrastructure/models/store_model.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRouter {
  static Future<void> navigate(
      String type, String? referenceId, String? notificationStoreId) async {
    if (type.isEmpty) return;

    debugPrint(
        "🚀 [Router] Bắt đầu điều hướng: $type | StoreId: $notificationStoreId");

    // Nếu user đang mở Dialog / BottomSheet thì phải tắt nó trước
    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      Get.back();
      // Chờ 300ms cho animation đóng popup hoàn tất để tránh xung đột GetX
      await Future.delayed(const Duration(milliseconds: 300));
    }
    final supabase = Supabase.instance.client;
    final storeService = Get.find<StoreService>();

    bool isFromSplash =
        Get.currentRoute == AppRoutes.splash || Get.currentRoute.isEmpty;
    bool needsSwitchStore = notificationStoreId != null &&
        notificationStoreId.isNotEmpty &&
        notificationStoreId != storeService.currentStoreId.value;

    bool didSwitchStore = false;

    if (needsSwitchStore) {
      try {
        final workspaceProvider = WorkspaceProvider();
        final List<StoreModel> myStores = await workspaceProvider.getMyStores();

        final targetStore = myStores.firstWhere(
          (store) => store.storeId == notificationStoreId,
          orElse: () => throw Exception('Không tìm thấy cửa hàng.'),
        );

        await storeService.saveSelectedStore(targetStore.storeId,
            targetStore.name, targetStore.role, targetStore.inviteCode ?? '');

        // Đẩy một màn hình Loading lên trước để đổi Route Context.
        // Vừa giúp người dùng biết app đang tải dữ liệu Store mới, vừa chống lỗi kẹt của GetX.
        Get.to(
          () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          transition: Transition.noTransition,
        );

        // Đợi màn hình tạm hiện ra hoàn tất
        await Future.delayed(const Duration(milliseconds: 300));

        didSwitchStore = true;
        debugPrint("✅ [Router] Cập nhật Database sang Store A thành công.");
      } catch (e) {
        debugPrint("⚠️ [Router] Lỗi Switch Store: $e");
        TSnackbarsWidget.error(
            title: TTexts.errorTitle.tr, message: TTexts.cannotAccessStore.tr);
        if (isFromSplash) Get.offAllNamed(AppRoutes.main);
        return;
      }
    }

    if (didSwitchStore || isFromSplash) {
      // Lúc này Get.currentRoute đang là màn hình Loading, lệnh offAllNamed sẽ chạy hoàn hảo 100%
      Get.offAllNamed(AppRoutes.main);

      // Đợi MainScreen build xong các Tab và Controller (Tăng thời gian an toàn)
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _performFinalNavigation(type, referenceId, supabase);
  }

  static Future<void> _performFinalNavigation(
      String type, String? referenceId, SupabaseClient? supabase) async {
    switch (type) {
      // 1. Nhóm Cảnh báo Tồn kho
      case NotificationTypes.lowStock:
      case NotificationTypes.batchLowStock:
        if (referenceId != null && referenceId.isNotEmpty) {
          Get.toNamed(AppRoutes.inventoryDetail, arguments: referenceId);
        } else {
          Get.toNamed(AppRoutes.lowStock);
        }
        break;

      // 2. Nhóm Đề xuất nhập hàng
      case NotificationTypes.reorderSuggestion:
        Get.toNamed(AppRoutes.reorderSuggestion);
        break;

      // 3. Nhóm Giao dịch (Sử dụng chung logic cho Import/Export)
      case NotificationTypes.import:
      case NotificationTypes.export:
        if (referenceId != null && referenceId.isNotEmpty) {
          Get.toNamed(AppRoutes.transactionDetail,
              arguments: {'id': referenceId});
        } else {
          Get.toNamed(AppRoutes.transactionSummary);
        }
        break;

      // 4. Nhóm Lệch kho
      case NotificationTypes.inventoryDiscrepancy:
        if (referenceId != null && referenceId.isNotEmpty) {
          Get.toNamed(AppRoutes.adjustmentHistory,
              arguments: {'batchId': '[Lô-$referenceId]'});
        }
        break;

      case NotificationTypes.roleUpdated:
        // Giữ nguyên logic logout như bạn đã làm rất tốt
        _handleLogout(supabase);
        break;

      default:
        if (Get.currentRoute != AppRoutes.notification) {
          Get.toNamed(AppRoutes.notification);
        }
    }
  }

  static Future<void> _handleLogout(SupabaseClient? supabase) async {
    TSnackbarsWidget.warning(
        title: TTexts.sessionExpiredTitle.tr,
        message: TTexts.sessionExpiredMessage.tr);

    await supabase!.auth.signOut();

    await GoogleSignIn.instance.signOut();

    GetStorage().remove('STORE_ID');

    Get.offAllNamed(AppRoutes.login);
  }
}
