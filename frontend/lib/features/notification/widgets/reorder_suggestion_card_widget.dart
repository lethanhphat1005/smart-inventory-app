import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/reorder_suggestion_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ReorderSuggestionCardWidget extends StatelessWidget {
  const ReorderSuggestionCardWidget({
    super.key,
    required this.item,
    required this.onDismiss,
  });

  final ReorderSuggestionModel item;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==============================
          // PHẦN 1: HEADER & TÊN SẢN PHẨM
          // ==============================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Iconsax.box_copy,
                              size: 16, color: AppColors.softGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Tooltip(
                              message: TTexts.productLabel.tr.toUpperCase(),
                              child: Text(
                                TTexts.productLabel.tr.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: AppFonts.mainFont,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: AppColors.softGrey.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Tooltip(
                        message: item.productName,
                        child: Text(
                          item.productName,
                          style: TextStyle(
                            fontFamily: AppFonts.mainFont,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Iconsax.close_circle_copy,
                        color: AppColors.softGrey.withOpacity(0.5), size: 22),
                  ),
                )
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // ==============================
          // PHẦN 2: THÔNG SỐ VÀ ĐỀ XUẤT CHÍNH
          // ==============================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMiniStat(
                          TTexts.currentStockLabel.tr,
                          '${item.currentStock}',
                          AppColors.toastErrorGradientEnd),
                      const SizedBox(height: 12),
                      _buildMiniStat(TTexts.alertThresholdLabel.tr,
                          '${item.suggestedThreshold}', AppColors.subText),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: AppColors.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: TTexts.suggestedImportLabel.tr,
                        child: Text(
                          TTexts.suggestedImportLabel.tr,
                          style: TextStyle(
                            fontFamily: AppFonts.mainFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subText,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Thêm Tooltip để đề phòng FittedBox thu nhỏ chữ lại quá mức khó đọc
                      Tooltip(
                        message: '+${item.suggestedQuantity}',
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '+${item.suggestedQuantity}',
                            style: TextStyle(
                              fontFamily: AppFonts.mainFont,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==============================
          // PHẦN 3: LÝ DO TỪ AI
          // ==============================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.magic_star_copy,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.reason,
                    style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.subText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm helper nội bộ của Widget
  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Tooltip(
            message: label,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.mainFont,
                fontSize: 13,
                color: AppColors.softGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Tooltip(
            message: value,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppFonts.mainFont,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
