import 'package:frontend/core/infrastructure/models/store_member_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:frontend/core/state/services/auth_service.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/profile/providers/store_member_provider.dart';
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
  final _storeMemberProvider = StoreMemberProvider();

  final apiClient = ApiClient();

  // Observables để UI lắng nghe
  var fullName = "".obs;
  var email = "".obs;
  var storeName = "".obs;

  // Load role của current user trong store hiện tại
  var currentUserStoreRole = "".obs;

  @override
  void onInit() {
    super.onInit();
    _loadAllData();

    // Lắng nghe thay đổi từ RAM để update UI tự động
    ever(userService.currentUser, (_) {
      _loadUserProfile();
      loadCurrentUserStoreRole();
    });

    ever(storeService.currentStoreName, (_) => _loadStoreInfo());

    // BỔ SUNG: khi đổi store thì load lại role
    ever(storeService.currentStoreId, (_) => loadCurrentUserStoreRole());

    // BỔ SUNG: load role lần đầu
    loadCurrentUserStoreRole();
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

  // Load role của current user từ store members
  Future<void> loadCurrentUserStoreRole() async {
    try {
      final currentStoreId = storeService.currentStoreId.value;
      final currentUser = userService.currentUser.value;

      if (currentStoreId.isEmpty || currentUser == null) {
        currentUserStoreRole.value = '';
        return;
      }

      final rawMembers =
          await _storeMemberProvider.getStoreMembers(currentStoreId);

      final members = rawMembers
          .map(
            (e) => StoreMemberModel.fromJson(
              e as Map<String, dynamic>,
              currentUserId: currentUser.userId,
            ),
          )
          .toList();

      StoreMemberModel? currentMember;

      // Match theo userId trước
      try {
        currentMember =
            members.firstWhere((member) => member.userId == currentUser.userId);
      } catch (_) {}

      // Nếu chưa thấy thì thử match theo authUserId
      if (currentMember == null) {
        try {
          currentMember = members.firstWhere(
            (member) => member.userId == currentUser.authUserId,
          );
        } catch (_) {}
      }

      // Nếu vẫn chưa thấy thì fallback theo isCurrentUser
      if (currentMember == null) {
        try {
          currentMember =
              members.firstWhere((member) => member.isCurrentUser == true);
        } catch (_) {}
      }

      currentUserStoreRole.value =
          currentMember?.role.toString().trim().toLowerCase() ?? '';
    } catch (e) {
      currentUserStoreRole.value = '';
    }
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

      // Load lại role sau khi refresh
      await loadCurrentUserStoreRole();

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

      // Reset role
      currentUserStoreRole.value = '';

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
      TSnackbarsWidget.error(
          title: TTexts.errorTitle, message: TTexts.systemError);
    } else {
      Get.toNamed(AppRoutes.storeSelection);
    }
    _loadStoreInfo();
  }

  void goToEditProfile() => Get.toNamed(AppRoutes.editProfile);
  void goToChangePasswordProfile() => Get.toNamed(AppRoutes.changePassword);
  void goToEditStoreProfile() => Get.toNamed(AppRoutes.editStore);
  void goToSettings() => Get.toNamed(AppRoutes.settings);
  void goToAssignsRoleProfile() {
    // Staff or Manager không được vào
    if (currentUserStoreRole.value == 'staff' ||
        currentUserStoreRole.value == 'manager') {
      return;
    }

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
