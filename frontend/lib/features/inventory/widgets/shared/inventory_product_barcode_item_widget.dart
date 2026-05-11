import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryProductBarcodeItemWidget extends StatelessWidget {
  final String barcode;
  final bool isDeleted;
  final VoidCallback onRemove;
  final VoidCallback onUndo;

  const InventoryProductBarcodeItemWidget({
    super.key,
    required this.barcode,
    this.isDeleted = false,
    required this.onRemove,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            isDeleted ? AppColors.softGrey.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        border: Border.all(
          color: isDeleted
              ? AppColors.divider.withOpacity(0.5)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          // Icon Barcode
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isDeleted ? 0.5 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDeleted
                    ? AppColors.softGrey.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Iconsax.barcode_copy,
                  color: isDeleted ? AppColors.softGrey : AppColors.primary,
                  size: 18),
            ),
          ),
          const SizedBox(width: 12),

          // Dãy số mã vạch với hiệu ứng gạch ngang chạy qua
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color:
                        isDeleted ? AppColors.softGrey : AppColors.primaryText,
                  ),
                  child: Text(barcode),
                ),
                // Đường gạch ngang animated
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                  height: 1.5,
                  width: isDeleted ? 150 : 0, // Độ dài tăng dần khi xóa
                  color: AppColors.softGrey.withOpacity(0.8),
                ),
              ],
            ),
          ),

          // Nút Xóa / Hoàn Tác
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDeleted ? onUndo : onRemove,
              borderRadius: BorderRadius.circular(8),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                turns: isDeleted ? 1 : 0, // Xoay nhẹ icon khi đổi trạng thái
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                      isDeleted ? Iconsax.undo_copy : Iconsax.trash_copy,
                      color:
                          isDeleted ? AppColors.primary : AppColors.alertText,
                      size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
