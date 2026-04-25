import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/controllers/customize_catalog_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';

class CustomCatalogMobileView extends GetView<CustomizeCatalogController> {
  const CustomCatalogMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: TAppBarWidget(
        title: TTexts.customizeCatalog.tr,
        actions: [
          TextButton(
            onPressed: controller.saveOrder,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(
              TTexts.save.tr,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.currentOrder.isEmpty) {
          return TEmptyStateWidget(
            icon: Iconsax.folder_open_copy,
            title: TTexts.noCategoriesFound.tr,
            subtitle: TTexts.emptyCategoryMessage.tr,
          );
        }

        return ReorderableListView.builder(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: controller.currentOrder.length,
          onReorder: controller.reorder,
          proxyDecorator:
              (Widget child, int index, Animation<double> animation) {
            return Material(
              elevation: 4,
              color: Colors.transparent,
              shadowColor: Colors.black12,
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final catName = controller.currentOrder[index];
            final isTop4 = index < 4;

            // Bọc bằng ReorderableDelayedDragStartListener để nhấn giữ bất kì đâu cũng kéo được (đã update từ trước)
            return ReorderableDelayedDragStartListener(
              key: ValueKey(catName),
              index: index,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTop4
                        ? AppColors.primary.withOpacity(0.5)
                        : AppColors.softGrey.withOpacity(0.1),
                    width: isTop4 ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(
                    isTop4 ? Iconsax.star_1 : Iconsax.box_copy,
                    color: isTop4 ? AppColors.primary : AppColors.softGrey,
                  ),
                  title: Text(
                    catName,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins'),
                  ),
                  subtitle: Text(
                    isTop4
                        ? TTexts.pinnedOnHome.tr
                        : TTexts.tapAndHoldToDrag.tr,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.softGrey),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
