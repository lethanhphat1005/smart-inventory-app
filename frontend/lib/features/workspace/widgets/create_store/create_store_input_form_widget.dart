import 'package:flutter/material.dart';
import 'package:frontend/features/workspace/widgets/create_store/create_store_currency_dropdown_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/workspace/controllers/create_store_controller.dart';
import 'create_store_address_autocomplete_widget.dart';

class CreateStoreInputFormWidget extends GetView<CreateStoreController> {
  const CreateStoreInputFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. INPUT TÊN CỬA HÀNG
        TTextFormFieldWidget(
          label: TTexts.storeNameLabel.tr,
          hintText: TTexts.storeNameHint.tr,
          controller: controller.nameController,
          prefixIcon: Iconsax.shop_copy,
        ),
        const SizedBox(height: AppSizes.p24),
        const CreateStoreCurrencyDropdownWidget(),
        const SizedBox(height: AppSizes.p24),

        // 2. INPUT ĐỊA CHỈ & TÌM KIẾM
        TTextFormFieldWidget(
          label: TTexts.storeAddressLabel.tr,
          hintText: TTexts.searchAddressHint.tr,
          controller: controller.addressController,
          prefixIcon: Iconsax.location_copy,
          maxLines: 2,
          onChanged: (val) => controller.searchAddress(val),
        ),

        // 3. WIDGET GỢI Ý ĐỊA CHỈ
        const CreateStoreAddressAutocompleteWidget(),
        const SizedBox(height: AppSizes.p16),

        // 4. CHIP LẤY GPS HIỆN TẠI
        Align(
          alignment: Alignment.centerLeft,
          child: Obx(() => ActionChip(
                onPressed: controller.isLoadingAddress.value
                    ? null
                    : controller.getCurrentLocation,
                avatar: controller.isLoadingAddress.value
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Iconsax.gps_copy,
                        size: 14, color: AppColors.primary),
                label: Text(TTexts.useCurrentLocation.tr,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
              )),
        ),
      ],
    );
  }
}
