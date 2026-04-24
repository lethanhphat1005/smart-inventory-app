import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/features/profile/providers/store_member_provider.dart';
import 'package:frontend/core/infrastructure/models/store_member_model.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:share_plus/share_plus.dart';

class AddMembersController extends GetxController with TErrorHandler {
  final RxBool isInitialLoading = true.obs;
  final RxList<StoreMemberModel> members = <StoreMemberModel>[].obs;
  final RxBool isLoadingMembers = false.obs;

  late final StoreMemberProvider _storeMemberProvider = StoreMemberProvider();
  late final WorkspaceProvider _workspaceProvider;
  late final StoreService _storeService = Get.find<StoreService>();
  late final UserService _userService = Get.find<UserService>();

  final RxBool hasGeneratedCode = false.obs;
  final RxString activeInviteCode = "".obs;
  final RxString generatedTimeStr = "".obs;

  @override
  void onInit() {
    super.onInit();
    _workspaceProvider = WorkspaceProvider();

    _checkExistingInviteCode();
    _loadInitialData();
  }

  bool get canManageWorkspace =>
      _storeService.currentRole.value == 'owner' ||
      _storeService.currentRole.value == 'manager';

  Future<void> _loadInitialData() async {
    isInitialLoading.value = true;
    await Future.wait([
      _checkExistingInviteCode(),
      _fetchMembers(),
    ]);
    isInitialLoading.value = false;
  }

  Future<void> refreshData() async {
    isInitialLoading.value = true;
    await Future.wait([
      _checkExistingInviteCode(),
      _fetchMembers(),
    ]);
    isInitialLoading.value = false;
  }

  Future<void> removeMemberFromStore(String userId) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loadingTitle.tr);

      await _storeMemberProvider.removeStoreMember(userId);

      members.removeWhere((member) => member.userId == userId);

      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.success(
        title: TTexts.successTitle.tr,
        message: TTexts.memberRemovedSuccess.tr,
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  Future<void> _fetchMembers() async {
    final storeId = _storeService.currentStoreId.value;
    final currentUserId = _userService.currentUser.value?.userId ?? '';

    if (storeId.isEmpty) return;

    try {
      final loadedMembers =
          await _workspaceProvider.getStoreMembers(storeId, currentUserId);

      // Sắp xếp danh sách User
      loadedMembers.sort((a, b) {
        if (a.isCurrentUser) return -1;
        if (b.isCurrentUser) return 1;

        int weightA = a.role == 'owner' ? 3 : (a.role == 'manager' ? 2 : 1);
        int weightB = b.role == 'owner' ? 3 : (b.role == 'manager' ? 2 : 1);

        if (weightA != weightB) {
          return weightB.compareTo(weightA);
        }
        return a.name.compareTo(b.name);
      });

      members.assignAll(loadedMembers);
    } catch (e) {
      handleError(e);
    }
  }

  void changeMemberRole(String targetUserId, String newRole) {
    final memberIndex = members.indexWhere((m) => m.userId == targetUserId);
    if (memberIndex == -1) return;
    final memberName = members[memberIndex].name;

    String roleText =
        newRole == 'manager' ? TTexts.roleManager.tr : TTexts.roleStaff.tr;

    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmChangeRoleTitle.tr,
        description:
            '${TTexts.confirmChangeRoleMessage.tr} $memberName -> $roleText?',
        icon: const Text('🛡', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.confirm.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onPrimaryPressed: () {
          Get.back();
          _executeChangeRole(targetUserId, newRole);
        },
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  Future<void> _executeChangeRole(String targetUserId, String newRole) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.updatingRole.tr);

      await _workspaceProvider.updateMemberRole(targetUserId, newRole);

      final index = members.indexWhere((m) => m.userId == targetUserId);
      if (index != -1) {
        final updatedMember = members[index].copyWith(role: newRole);
        members[index] = updatedMember;
      }

      FullScreenLoaderUtils.stopLoading();

      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr, message: TTexts.roleUpdatedSuccess.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  void onGenerateCodeTapped() {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.generateCodeDialogTitle.tr,
        description: TTexts.generateCodeDialogMessage.tr,
        icon: const Text('📩', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.confirmGenerate.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onPrimaryPressed: () {
          Get.back();
          executeRealCodeGeneration();
        },
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  Future<void> _checkExistingInviteCode() async {
    final savedCode = _storeService.currentInviteCode.value;
    if (savedCode.isNotEmpty &&
        savedCode != TTexts.plsGenerateNewCode.tr &&
        savedCode != "Pls, generate new code!") {
      activeInviteCode.value = savedCode;
      hasGeneratedCode.value = true;
    }

    final storeId = _storeService.currentStoreId.value;
    if (storeId.isEmpty) return;

    try {
      final store = await _workspaceProvider.getStoreById(storeId);

      if (store.inviteCode != null &&
          store.inviteCode!.isNotEmpty &&
          store.inviteCode != TTexts.plsGenerateNewCode.tr &&
          store.inviteCode != "Pls, generate new code!") {
        activeInviteCode.value = store.inviteCode!;
        hasGeneratedCode.value = true;

        _storeService.updateInviteCode(store.inviteCode!);
      } else {
        hasGeneratedCode.value = false;
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy đồng bộ mã mời ngầm: $e');
    }
  }

  Future<void> executeRealCodeGeneration() async {
    final storeId = _storeService.currentStoreId.value;
    if (storeId.isEmpty) return;

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.generatingCode.tr);

      final newCode = await _workspaceProvider.refreshInviteCode(storeId);

      activeInviteCode.value = newCode;
      final now = DateTime.now();
      generatedTimeStr.value = DateFormat('hh:mm a, MMM dd').format(now);
      hasGeneratedCode.value = true;

      _storeService.updateInviteCode(newCode);

      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.inviteCodeGeneratedSuccess.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    }
  }

  void copyCode() {
    Clipboard.setData(ClipboardData(text: activeInviteCode.value));
    TSnackbarsWidget.success(
        title: TTexts.inviteCodeCopiedTitle.tr,
        message: TTexts.inviteCodeCopiedMessage.tr);
  }

  void shareCode() {
    if (activeInviteCode.value.isNotEmpty) {
      final storeName = _storeService.currentStoreName.value;
      Share.share(
          "${TTexts.joinWorkspaceTitle.tr} $storeName! ${TTexts.enterInviteCodeLabel.tr}: ${activeInviteCode.value}",
          subject: TTexts.joinWorkspaceTitle.tr);
    }
  }
}
