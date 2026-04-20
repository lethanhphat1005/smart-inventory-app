import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/profile/controllers/profile_edit_profile_controller.dart';
import 'package:get/get.dart';

class EditProfileSaveButtonWidget extends StatelessWidget {
  const EditProfileSaveButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileEditController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: SizedBox(
        width: double.infinity,
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    if (!controller.isEditing.value) {
                      controller.toggleEditing();
                      return;
                    }

                    if (!controller.shouldShowConfirmDialog()) {
                      controller.updateProfile();
                      return;
                    }

                    Get.dialog(
                      TCustomDialogWidget(
                        title: TTexts.confirmUpdate.tr,
                        description: TTexts.confirmUpdateDescription.tr,
                        icon: const Text(
                          '📝',
                          style: TextStyle(fontSize: AppSizes.p40),
                        ),
                        primaryButtonText: TTexts.confirm.tr,
                        onPrimaryPressed: () {
                          Get.back();
                          controller.updateProfile();
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
              backgroundColor: AppColors.gradientOrangeStart,
              foregroundColor: AppColors.whiteText,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius16),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: AppSizes.p20,
                    width: AppSizes.p20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    controller.isEditing.value
                        ? TTexts.confirm.tr
                        : TTexts.editUpdate.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.p16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
