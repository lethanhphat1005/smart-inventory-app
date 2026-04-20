import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDetailRelatedPackagesWidget
    extends GetView<InventoryDetailController> {
  const InventoryDetailRelatedPackagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final related = controller.relatedPackages;

      if (related.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
          child: Text(TTexts.noRelatedPackages.tr,
              style: const TextStyle(
                  color: AppColors.subText,
                  fontSize: 13,
                  fontStyle: FontStyle.italic)),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p20, vertical: AppSizes.p8),
        itemCount: related.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = related[index];
          final pkg = item.inventory.productPackage;
          final name = pkg?.displayName ?? TTexts.unknownProduct.tr;
          final barcode = pkg?.barcodeValue ?? TTexts.na.tr;
          final stock = item.inventory.quantity;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius16),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: ListTile(
              onTap: () => controller.pushRelatedItem(item),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius16)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02), blurRadius: 4)
                    ]),
                child: const Icon(Iconsax.box_add_copy,
                    color: AppColors.primaryText, size: 20),
              ),
              title: Text(name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text("${TTexts.barcodeLabel.tr}: $barcode",
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.subText)),
              trailing: Text("$stock ${TTexts.left.tr}",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          );
        },
      );
    });
  }
}
