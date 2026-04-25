import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';

class ProductCatalogSearchBarWidget extends GetView<ProductCatalogController> {
  const ProductCatalogSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Trả lại thiết kế Container bóng mờ (floating) ban đầu cực đẹp
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: (value) => controller.searchQuery.value = value,
        cursorColor: AppColors.primary, // Vẫn giữ con trỏ màu cam
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: AppColors.primaryText,
        ),
        decoration: InputDecoration(
          hintText: TTexts.searchCategories.tr,
          hintStyle: const TextStyle(color: AppColors.subText, fontSize: 12),
          prefixIcon: const Icon(Iconsax.search_normal_1_copy,
              color: AppColors.softGrey, size: 20),

          // ĐÂY NÈ: Dùng đúng chuẩn nút X của TTextFormFieldWidget
          suffixIcon: _buildClearButton(),

          border: InputBorder.none, // Giữ thiết kế không viền
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// Nút Xóa nhanh (Bê y nguyên logic từ TTextFormFieldWidget qua)
  Widget? _buildClearButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.searchController,
      builder: (context, value, child) {
        if (value.text.isNotEmpty) {
          return IconButton(
            icon: const Icon(
              Icons.cancel,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {
              controller.searchController.clear();
              controller.searchQuery.value = "";
            },
            splashColor: Colors.transparent,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
