import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/inventory/widgets/inventory/inventory_empty_category_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_custom_fade_overlay_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryDynamicCategoryWidget extends GetView<InventoryController> {
  const InventoryDynamicCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Color> avatarColors = [
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo
    ];

    return Obx(() {
      final dynamicCategories = controller.categoryStats;

      const int fullyVisibleCount = 4;
      const int renderCount = 6;
      final bool hasMore = dynamicCategories.length > fullyVisibleCount;

      final int itemCount = dynamicCategories.length > renderCount
          ? renderCount
          : dynamicCategories.length;

      if (dynamicCategories.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: InventoryEmptyCategoryWidget(),
        );
      }

      Widget gridView = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),
        itemBuilder: (context, index) {
          final cat = dynamicCategories[index];
          final String name = cat.name;
          final int count = cat.count;
          final String firstLetter =
              name.isNotEmpty ? name[0].toUpperCase() : "?";
          final Color bgColor = avatarColors[index % avatarColors.length];

          final bool isClickable = index < fullyVisibleCount;

          return InkWell(
            onTap: isClickable
                ? () => controller.onCategorySelected(cat.name)
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softGrey.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: bgColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text(firstLetter,
                        style: TextStyle(
                            color: bgColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.mainFont)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10)),
                        const SizedBox(height: 2),
                        Text("$count ${TTexts.items.tr}",
                            style: const TextStyle(
                                color: AppColors.softGrey,
                                fontWeight: FontWeight.w400,
                                fontSize: 8)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Nếu có >4 mục (hasMore == true): CHỈ trả về GridView phủ Overlay, ẨN NÚT
      if (hasMore) {
        final int hiddenCount = dynamicCategories.length - fullyVisibleCount;
        return Stack(
          children: [
            gridView,
            TCustomFadeOverlayWidget(
              text: "+$hiddenCount ${TTexts.more.tr}",
              onTap: () => Get.toNamed(AppRoutes.productCatalog),
            ),
          ],
        );
      }

      // Nếu có <=4 mục (hasMore == false): TRẢ VỀ GridView + Nút View All ĐỂ TRÁNH BỊ KẸT
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          gridView,
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.productCatalog),
            icon: const Icon(Iconsax.category_2_copy, size: 18),
            label: Text(
              TTexts.seeAllCategories.tr,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontFamily: AppFonts.mainFont),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.primary.withOpacity(0.05),
            ),
          )
        ],
      );
    });
  }
}
