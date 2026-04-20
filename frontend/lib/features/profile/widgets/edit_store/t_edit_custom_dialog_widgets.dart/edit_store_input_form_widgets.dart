import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';
import 'package:frontend/features/profile/widgets/edit_store/t_edit_custom_dialog_widgets.dart/edit_store_address_autocomplete_widgets.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EditStoreInputFormWidget extends GetView<ProfileEditStoreController> {
  const EditStoreInputFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = controller.isEditing.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// NAME
          TTextFormFieldWidget(
            controller: controller.nameController,
            label: TTexts.storeNameLabel.tr,
            hintText: TTexts.editStoreNameHint.tr,
            prefixIcon: Iconsax.shop_copy,
            readOnly: !isEditing,
          ),

          const SizedBox(height: AppSizes.p16),

          /// ADDRESS
          TTextFormFieldWidget(
            controller: controller.addressController,
            label: TTexts.editStoreAddressLabel.tr,
            hintText: TTexts.editStoreAddressHint.tr,
            prefixIcon: Iconsax.location_copy,
            maxLines: 2,
            readOnly: !isEditing,
            onChanged:
                isEditing ? (val) => controller.searchAddress(val) : null,
          ),

          /// AUTOCOMPLETE
          if (isEditing) const EditStoreAddressAutocompleteWidgets(),

          const SizedBox(height: AppSizes.p16),

          /// GPS
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
    });
  }
}
