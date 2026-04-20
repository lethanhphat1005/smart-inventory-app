import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';
import 'package:get/get.dart';

class EditStoreSaveButtonWidgetDialog extends StatelessWidget {
  const EditStoreSaveButtonWidgetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileEditStoreController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: SizedBox(
        width: double.infinity,
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    /// Lần đầu: chuyển readonly -> editable
                    if (!controller.isEditing.value) {
                      controller.toggleEditing();
                      return;
                    }

                    /// Đang edit nhưng chưa đủ điều kiện confirm
                    if (!controller.shouldShowConfirmDialog()) {
                      controller.updateStore();
                      return;
                    }

                    /// Đủ điều kiện thì mở dialog xác nhận
                    Get.dialog(
                      TCustomDialogWidget(
                        title: TTexts.confirmUpdate.tr,
                        description: TTexts.editStoreDialogDescription.tr,
                        icon: const Text(
                          '📝',
                          style: TextStyle(fontSize: AppSizes.p40),
                        ),
                        primaryButtonText: TTexts.confirm.tr,
                        onPrimaryPressed: () {
                          Get.back();
                          controller.updateStore();
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
                        : TTexts.editStoreBtnEdit.tr,
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
