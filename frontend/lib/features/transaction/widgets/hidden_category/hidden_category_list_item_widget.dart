import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/inventory/controllers/hidden_category_controller.dart';
import 'package:get/get.dart';

class HiddenCategoryListItemWidget extends StatelessWidget {
  const HiddenCategoryListItemWidget({
    super.key,
    required this.category,
    required this.index,
  });

  final CategoryModel category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HiddenCategoryController>();
    final List<Color> avatarColors = [
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo
    ];

    final String name = category.name;
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "?";

    // Dùng hashcode để lấy màu cố định cho tên danh mục, không cần truyền index
    final Color bgColor =
        avatarColors[name.hashCode.abs() % avatarColors.length];

    return Obx(() {
      final isSelected = controller.selectedIds.contains(category.categoryId);
      final isSelectMode = controller.isSelectMode.value;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSizes.p12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.softGrey.withOpacity(0.05),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          child: Stack(
            children: [
              // 1. Nội dung chính
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => isSelectMode
                      ? controller.toggleSelection(category.categoryId)
                      : null,
                  onLongPress: () =>
                      controller.handleLongPress(category.categoryId),
                  splashColor: AppColors.primary.withOpacity(0.1),
                  highlightColor: AppColors.primary.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: bgColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            firstLetter,
                            style: TextStyle(
                                color: bgColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.mainFont),
                          ),
                        ),
                        const SizedBox(width: AppSizes.p16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: AppFonts.mainFont,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (category.description != null &&
                                        category.description!.isNotEmpty)
                                    ? category.description!
                                    : TTexts.na.tr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: AppFonts.mainFont,
                                    fontSize: 10,
                                    height: 1.3,
                                    color: AppColors.subText),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.p8),

                        // 3. NÚT BIẾN ĐỔI: RESTORE <=> RADIO
                        if (!isSelectMode)
                          InkWell(
                            onTap: () => controller.restoreSingle(category),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.restore_rounded,
                                      color: AppColors.primary, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    TTexts.restore.tr,
                                    style: TextStyle(
                                      fontFamily: AppFonts.mainFont,
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        else
                          // Nút Radio (Vòng tròn tinh tế)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.softGrey,
                                  width: 2),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle)))
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Tag vuông ở góc trái phía trên (Mặc định giữ lại nếu là Default)
              if (category.isDefault)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      TTexts.defaultCategory.tr.toUpperCase(),
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
