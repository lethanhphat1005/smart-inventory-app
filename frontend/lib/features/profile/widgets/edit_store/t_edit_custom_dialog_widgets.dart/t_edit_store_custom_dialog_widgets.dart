import 'package:flutter/material.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';
import 'package:frontend/features/profile/widgets/edit_store/t_edit_custom_dialog_widgets.dart/create_store_map_preview_widgets.dart';
import 'package:frontend/features/profile/widgets/edit_store/t_edit_custom_dialog_widgets.dart/edit_store_btn_dialog_widgets.dart';
import 'package:frontend/features/profile/widgets/edit_store/t_edit_custom_dialog_widgets.dart/edit_store_input_form_widgets.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class TEditStoreCustomDialogWidgets
    extends GetView<ProfileEditStoreController> {
  const TEditStoreCustomDialogWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius16),
      ),
      backgroundColor: AppColors.background,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.p12),

              /// HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.p20,
                  AppSizes.p16,
                  AppSizes.p12,
                  AppSizes.p12,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TTexts.editStoreTitleDialog.tr,
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: AppSizes.p24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Text(
                            TTexts.editStoreSubtitleDialog.tr,
                            style: const TextStyle(
                              color: AppColors.subText,
                              fontSize: AppSizes.p14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -8),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, color: AppColors.subText),
                        iconSize: AppSizes.p32,
                      ),
                    ),
                  ],
                ),
              ),

              /// BODY
              Expanded(
                child: ScrollConfiguration(
                  behavior: const MaterialScrollBehavior().copyWith(
                    scrollbars: false,
                    overscroll: false,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.p24,
                      AppSizes.p20,
                      AppSizes.p24,
                      AppSizes.p24,
                    ),
                    child: Form(
                      key: controller.editStoreFormKey,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FORM NHẬP LIỆU & GPS
                          EditStoreInputFormWidget(),
                          SizedBox(height: AppSizes.p24),

                          // BẢN ĐỒ
                          EditStoreMapPreviewWidget(),
                          SizedBox(height: AppSizes.p24),

                          // NÚT
                          EditStoreSaveButtonWidgetDialog(),
                          SizedBox(height: AppSizes.p12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
