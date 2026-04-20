// lib/features/workspace/views/widgets/workspace_address_autocomplete.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';

class EditStoreAddressAutocompleteWidgets
    extends GetView<ProfileEditStoreController> {
  const EditStoreAddressAutocompleteWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Ẩn đi nếu không có gợi ý nào
      if (controller.addressPredictions.isEmpty) return const SizedBox.shrink();

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(top: AppSizes.p8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true, // Quan trọng để nằm cuộn trong Column
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.addressPredictions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade100,
              indent: 50, // Lùi đường gạch ngang vào một chút cho đẹp
            ),
            itemBuilder: (context, index) {
              final place = controller.addressPredictions[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.location_tick_copy,
                      size: 18, color: AppColors.primary),
                ),
                title: Text(
                  place['display_name'] ?? "",
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  place['type']?.toString().capitalizeFirst ??
                      TTexts.locationStr.tr,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.softGrey),
                ),
                onTap: () => controller.onSuggestionSelected(place),
              );
            },
          ),
        ),
      );
    });
  }
}
