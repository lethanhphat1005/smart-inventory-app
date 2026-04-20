import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/profile/controllers/profile_change_password_controller.dart';

class ChangePasswordButtonWidget
    extends GetView<ProfileChangePasswordController> {
  const ChangePasswordButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileChangePasswordController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: SizedBox(
        width: double.infinity,
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    /// Kiểm tra form trước khi submit
                    final isValid = await controller.validateBeforeSubmit();
                    if (!isValid) return;

                    // Hiển thị dialog xác nhận
                    Get.dialog(
                      TCustomDialogWidget(
                        title: TTexts.changePasswordConfirm.tr,
                        description: TTexts.changePasswordDialogDescription.tr,
                        icon: const Text('🔐', style: TextStyle(fontSize: 40)),
                        primaryButtonText: TTexts.confirm.tr,
                        onPrimaryPressed: () {
                          Get.back();
                          controller.updatePassword();
                        },
                        secondaryButtonText: TTexts.cancel.tr,
                        onSecondaryPressed: () {
                          Get.back();
                        },
                      ),
                      barrierDismissible: false,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius16),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    TTexts.changePasswordConfirm.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
