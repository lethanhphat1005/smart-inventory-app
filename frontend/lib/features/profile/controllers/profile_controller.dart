import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/profile/providers/store_provider.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class ProfileController extends GetxController {
  // Services
  final userService = Get.find<UserService>();
  final storeService = Get.find<StoreService>();

  // Providers
  final _profileProvider = UserProfileProvider();
  final _storeProvider = StoreProvider();

  final apiClient = ApiClient();

  // Observables để UI lắng nghe
  var fullName = "".obs;
  var email = "".obs;
  var storeName = "".obs;

  @override
  void onInit() {
    super.onInit();
    _loadAllData();

    // Lắng nghe thay đổi từ RAM để update UI tự động
    ever(userService.currentUser, (_) => _loadUserProfile());
    ever(storeService.currentStoreName, (_) => _loadStoreInfo());
  }

  void _loadAllData() {
    _loadUserProfile();
    _loadStoreInfo();
  }

  void _loadUserProfile() {
    final user = userService.currentUser.value;
    if (user != null) {
      fullName.value = user.fullName;
      email.value = user.email;
    }
  }

  void _loadStoreInfo() {
    storeName.value = storeService.currentStoreName.value.isNotEmpty
        ? storeService.currentStoreName.value
        : TTexts.profileNoStoreSelected.tr;
  }

  /// Làm mới dữ liệu từ Server
  Future<void> refreshProfile() async {
    try {
      // 1. Làm mới thông tin User
      final updatedUser = await _profileProvider.fetchMyProfile();
      userService.currentUser.value = updatedUser;

      // 2. Làm mới thông tin Store (nếu đã chọn store)
      final currentStoreId = storeService.currentStoreId.value;
      if (currentStoreId.isNotEmpty) {
        final storeData = await _storeProvider.getStoreDetail(currentStoreId);
        final newName = storeData['name'] ?? "";
        // Cập nhật cả RAM của StoreService để các màn hình khác cũng đổi theo
        storeService.currentStoreName.value = newName;
      }

      // Thông báo thành công
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.profileUpdateSuccess.tr);
    } catch (e) {
      // Thêm catch để bắt lỗi và hiển thị thông báo lỗi
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: TTexts.profileUpdateErrorTitle.tr);
    }
  }

  /// Đăng xuất
  Future<void> executeLogout() async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loggingOut.tr);

      await AuthProvider(apiClient: apiClient).logout();
      await Get.find<AuthService>().clearAuthData();
      await Get.find<StoreService>().clearWorkspaceData();
      userService.clearUser();

      FullScreenLoaderUtils.stopLoading();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.logoutErrorTitle.tr, message: e.toString());
    }
  }

  void goToStoreSelect() {
    if (userService.currentUser.value == null) {
      Get.toNamed(AppRoutes.createStore);
    } else {
      Get.toNamed(AppRoutes.storeSelection);
    }
    _loadStoreInfo();
  }

  void goToEditProfile() => Get.toNamed(AppRoutes.editProfile);
  void goToChangePasswordProfile() => Get.toNamed(AppRoutes.changePassword);
  void goToEditStoreProfile() => Get.toNamed(AppRoutes.editStore);
  void goToAssignsRoleProfile() {
    // 1. Lấy storeId hiện tại từ RAM
    final currentStoreId = storeService.currentStoreId.value;

    // 2. Kiểm tra nếu chưa có storeId thì chặn lại và báo lỗi
    if (currentStoreId.isEmpty) {
      TSnackbarsWidget.warning(
        title: TTexts.warningTitle.tr,
        message: TTexts.profileNoStoreSelected.tr,
      );
      return;
    }

    // 3. Nếu đã có storeId hợp lệ thì mới cho chuyển trang
    Get.toNamed(AppRoutes.addMembers);
  }
}
