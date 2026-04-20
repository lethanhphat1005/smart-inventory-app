import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

class ProfileChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Biến trạng thái (State)
  final RxBool isOldPasswordHidden = true.obs;
  final RxBool isNewPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;

  // --- HÀM XỬ LÝ GIAO DIỆN ---
  void toggleOldPasswordVisibility() =>
      isOldPasswordHidden.value = !isOldPasswordHidden.value;
  void toggleNewPasswordVisibility() =>
      isNewPasswordHidden.value = !isNewPasswordHidden.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  final supabase = Supabase.instance.client;

  Future<bool> validateBeforeSubmit() async {
    // 1. Kiểm tra form có hợp lệ không
    if (!formKey.currentState!.validate()) return false;

    // 2. Kiểm tra các trường có bị bỏ trống không
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      TSnackbarsWidget.warning(
        title: TTexts.warningTitle.tr,
        message: TTexts.fillAllFields.tr,
      );
      return false;
    }

    // 3. Kiểm tra mật khẩu mới có khớp với xác nhận mật khẩu không
    if (newPasswordController.text != confirmPasswordController.text) {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.passwordNotMatch.tr,
      );
      return false;
    }

    // 4. Kiểm tra mật khẩu mới có khác mật khẩu cũ không
    if (newPasswordController.text == oldPasswordController.text) {
      TSnackbarsWidget.warning(
        title: TTexts.warningTitle.tr,
        message: TTexts.passwordSameAsOld.tr,
      );
      return false;
    }

    // 5. Xác thực lại mật khẩu cũ
    final user = supabase.auth.currentUser;
    if (user == null || user.email == null) {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.authSessionExpired.tr,
      );
      return false;
    }

    try {
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPasswordController.text,
      );
    } on AuthException {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.oldPasswordIncorrect.tr,
      );
      return false;
    }

    // Nếu tất cả đều hợp lệ
    return true;
  }

  Future<void> updatePassword() async {
    if (!await validateBeforeSubmit()) return;

    isLoading.value = true;

    try {
      // 1. Xác thực lại bằng mật khẩu cũ
      final user = supabase.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception(TTexts.authSessionExpired.tr);
      }

      try {
        await supabase.auth.signInWithPassword(
          email: user.email!,
          password: oldPasswordController.text,
        );
      } on AuthException {
        TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message: TTexts.oldPasswordIncorrect.tr,
        );
        return;
      }
      // 2. Nếu xác thực thành công, tiến hành cập nhật mật khẩu mới
      final AuthResponse authResponse = await supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPasswordController.text,
      );

      // 3. Nếu xác thực thành công, cập nhật mật khẩu mới
      if (authResponse.session != null) {
        await supabase.auth.updateUser(
          UserAttributes(password: newPasswordController.text),
        );

        // 4. Hiển thị thông báo thành công
        TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.passwordChangedSuccess.tr,
        );

        _clearForm();
      } else {
        throw Exception(TTexts.systemError.tr);
      }
    } on AuthException catch (e) {
      String errorMsg = e.message;
      if (e.message.contains('Invalid login credentials')) {
        errorMsg = TTexts.oldPasswordIncorrect.tr;
      }

      TSnackbarsWidget.error(
        title: TTexts.authError.tr,
        message: errorMsg,
      );
    } catch (e) {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.systemError.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Hàm dọn dẹp dữ liệu trên Form
  void _clearForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    // Giải phóng bộ nhớ cho các controller
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
