import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryCategoryDetailProductItemWidget extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const InventoryCategoryDetailProductItemWidget({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        border: Border.all(color: AppColors.softGrey.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p12),
            child: Row(
              children: [
                // Hình ảnh sản phẩm (Giả lập container nếu chưa có hình thật)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius8),
                  ),
                  child: product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radius8),
                          child: Image.network(product.imageUrl!,
                              fit: BoxFit.cover),
                        )
                      : const Icon(Iconsax.image_copy,
                          color: AppColors.softGrey),
                ),
                const SizedBox(width: AppSizes.p16),

                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.mainFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Brand: ${product.brand ?? "N/A"}',
                        style: TextStyle(
                            fontFamily: AppFonts.mainFont,
                            fontSize: 10,
                            color: AppColors.subText),
                      ),
                    ],
                  ),
                ),

                // Nút mũi tên
                const Padding(
                  padding: EdgeInsets.only(left: AppSizes.p8),
                  child: Icon(Icons.chevron_right, color: AppColors.softGrey),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
