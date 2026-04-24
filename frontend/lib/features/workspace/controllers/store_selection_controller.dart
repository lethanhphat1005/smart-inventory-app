import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/store_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/workspace/widgets/store_selection/store_selection_help_bottom_widget.dart';

class StoreSelectionController extends GetxController with TErrorHandler {
  final isLoading = false.obs;

  // Sử dụng StoreModel thật
  final stores = <StoreModel>[].obs;

  late final WorkspaceProvider _workspaceProvider;
  final _storeService = Get.find<StoreService>();

  // Lấy ID cửa hàng đang được active từ StoreService
  String get currentStoreId => _storeService.currentStoreId.value;

  @override
  void onInit() {
    super.onInit();
    _workspaceProvider = WorkspaceProvider();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      isLoading.value = true;
      final fetchedStores = await _workspaceProvider.getMyStores();

      final activeId = currentStoreId;
      if (activeId.isNotEmpty) {
        fetchedStores.sort((a, b) {
          if (a.storeId == activeId) return -1;
          if (b.storeId == activeId) return 1;
          return 0;
        });
      }

      stores.assignAll(fetchedStores);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectStore(StoreModel store) async {
    try {
      debugPrint("==== DỮ LIỆU STORE: ${store.toJson()} ====");

      // Lấy storeId trực tiếp từ thuộc tính của StoreModel
      final String currentId = store.storeId;
      final String currentName = store.name;
      final String currentRole = store.role;
      final String currentInviteCode = store.inviteCode ?? '';

      if (currentId.isEmpty) {
        debugPrint("LỖI CRITICAL: ID Cửa hàng bị rỗng!");
        TSnackbarsWidget.error(
            title: TTexts.errorTitle.tr,
            message: TTexts.errorUnknownMessage.tr);
        return;
      }

      debugPrint("LƯU VÀO MÁY STORE_ID: $currentId");

      // 1. Lưu vào máy và RAM
      await _storeService.saveSelectedStore(
          currentId, currentName, currentRole, currentInviteCode);

      // 2. Hiện thông báo Snackbar tham gia thành công
      TSnackbarsWidget.success(
          title: TTexts.storeSelectionSuccessTitle.tr,
          message: "${TTexts.storeSelectionSuccessMessage.tr} $currentName");

      // 3. Nhảy vào trang Home
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> refreshStores() async {
    await fetchStores();
  }

  void showHelpBottomSheet() {
    Get.bottomSheet(
      const StoreSelectionHelpBottomWidget(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void goToJoinStore() {
    Get.toNamed(AppRoutes.joinStore);
  }

  void goToCreateStore() {
    Get.toNamed(AppRoutes.createStore);
  }
}
