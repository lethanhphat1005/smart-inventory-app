import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/routes/app_routes.dart';

class JoinStoreController extends GetxController with TErrorHandler {
  final inviteCodeController = TextEditingController();

  // Biến này giờ đây chỉ dùng để điều khiển Nút Bấm
  final isLoading = false.obs;

  late final WorkspaceProvider _workspaceProvider;
  late final _storeService = Get.find<StoreService>();

  @override
  void onInit() {
    super.onInit();
    _workspaceProvider = WorkspaceProvider();
  }

  Future<void> onJoinWorkspace() async {
    // 1. Nếu đang xoay loading trên nút rồi thì không cho bấm nữa
    if (isLoading.value) return;

    // Đóng snackbar cũ nếu có cho gọn mắt
    Get.closeAllSnackbars();

    final code = inviteCodeController.text.trim();
    debugPrint('MÃ CHUẨN BỊ GỬI LÊN SERVER LÀ: "$code"');

    if (code.isEmpty || code.length < 6) {
      TSnackbarsWidget.warning(
          title: TTexts.joinMissingCodeTitle.tr,
          message: TTexts.joinMissingCodeMessage.tr);
      return;
    }

    try {
      // 2. Kích hoạt Loading trên nút bấm (Vô hiệu hóa nút, đổi text)
      isLoading.value = true;

      // --- GỌI API THẬT ---
      final joinedStore = await _workspaceProvider.joinStore(code);

      TSnackbarsWidget.success(
          title: TTexts.joinSuccessTitle.tr,
          message: TTexts.joinSuccessMessage.tr);

      await _storeService.saveSelectedStore(
        joinedStore.storeId,
        joinedStore.name,
        joinedStore.role,
        joinedStore.inviteCode ?? '',
        joinedStore.currencyCode ?? 'VND',
      );

      Get.offAllNamed(AppRoutes.main);
    } on DioException catch (e) {
      // Bắt lỗi rành mạch
      if (e.response?.statusCode == 409) {
        TSnackbarsWidget.error(
            title: TTexts.joinAlreadyMemberTitle.tr,
            message: TTexts.joinAlreadyMemberMessage.tr);
      } else if (e.response?.statusCode == 404) {
        TSnackbarsWidget.error(
            title: TTexts.joinInvalidCodeTitle.tr,
            message: TTexts.joinInvalidCodeMessage.tr);
      } else {
        handleError(e);
      }
    } catch (e) {
      handleError(e);
    } finally {
      // 3. API chạy xong (dù lỗi hay thành công), trả nút bấm về trạng thái bình thường
      isLoading.value = false;
    }
  }
}
