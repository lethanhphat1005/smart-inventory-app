import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/profile/widgets/edit_profile/t_edit_profile_phone_filed_widgets.dart';
import 'package:frontend/features/profile/widgets/edit_profile/edit_profile_user_address_autocomplete_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/features/profile/controllers/profile_edit_profile_controller.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EditProfileFormWidget extends GetView<ProfileEditController> {
  const EditProfileFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Obx(() {
        final isEditing = controller.isEditing.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// EMAIL (READ ONLY)
            TTextFormFieldWidget(
              controller: controller.emailController,
              label: TTexts.editEmail.tr,
              hintText: TTexts.editHintEmail.tr,
              prefixIcon: Icons.email,
              readOnly: true,
            ),

            const SizedBox(height: AppSizes.p16),

            /// NAME
            TTextFormFieldWidget(
              controller: controller.nameController,
              label: TTexts.editName.tr,
              hintText: TTexts.editHintName.tr,
              prefixIcon: Icons.person,
              readOnly: !isEditing,
            ),

            const SizedBox(height: AppSizes.p16),

            /// PHONE
            TPhoneFormFieldWidget(
              label: TTexts.editPhoneNumber.tr,
              controller: controller.phoneController,
              onChanged: (value) {
                controller.completePhoneNumber.value = value;
              },
              isRequired: false,
              enabled: isEditing,
            ),

            const SizedBox(height: AppSizes.p16),

            /// ADDRESS
            TTextFormFieldWidget(
              label: TTexts.storeAddressLabel.tr,
              hintText: TTexts.searchAddressHint.tr,
              controller: controller.addressController,
              prefixIcon: Iconsax.location_copy,
              maxLines: 2,
              readOnly: !isEditing,
              onChanged:
                  isEditing ? (val) => controller.searchAddress(val) : null,
            ),

            /// ADDRESS AUTOCOMPLETE
            if (isEditing) const EditProfileUserAddressAutocompleteWidget(),

            const SizedBox(height: AppSizes.p16),

            // 4. CHIP LẤY GPS HIỆN TẠI
            Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                onPressed: (!isEditing || controller.isLoadingAddress.value)
                    ? null
                    : controller.getCurrentLocation,
                avatar: controller.isLoadingAddress.value
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Iconsax.gps_copy,
                        size: 14,
                        color: AppColors.primary,
                      ),
                label: Text(
                  TTexts.useCurrentLocation.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
