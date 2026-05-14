import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionAddMoreCardWidget extends StatelessWidget {
  final VoidCallback onTap;

  const TransactionAddMoreCardWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      decoration: BoxDecoration(
        color: Colors.white, // TRẢ VỀ NỀN TRẮNG SẠCH SẼ
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15), // Viền mỏng, nhẹ nhàng
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.03), // Đổ bóng màu đen siêu mờ để tạo khối
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withOpacity(0.08),
          highlightColor: AppColors.primary.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // KHỐI ICON: Làm điểm nhấn chính với nền pha màu Primary
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(0.08), // Nền mờ, không dùng viền
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Iconsax.add_square_copy,
                    color: AppColors.primary, // Icon nổi bật
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.p16),

                // KHỐI TEXT: Dùng màu chuẩn để dễ đọc và sang trọng
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TTexts.quickAddProducts.tr,
                        style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors
                              .primaryText, // CHỮ MÀU ĐEN/TỐI (Bỏ màu xanh lòe loẹt đi)
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        TTexts.quickAddProductsSubtitle.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontSize: 11,
                          height: 1.3,
                          color: AppColors.subText, // CHỮ MÀU XÁM PHỤ
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.p8),

                // MŨI TÊN
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.subText.withOpacity(
                      0.5), // Màu xám mờ để không tranh giành sự chú ý
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
