import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionStandardSearchBarWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const TransactionStandardSearchBarWidget({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        boxShadow: [
          BoxShadow(
            color: AppColors.softGrey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSizes.p16),
          const Icon(Iconsax.search_normal_copy,
              color: AppColors.softGrey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.primary,
              style:
                  const TextStyle(color: AppColors.primaryText, fontSize: 13),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle:
                    const TextStyle(color: AppColors.softGrey, fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          // SỬ DỤNG VALUELISTENABLE ĐỂ NÚT X HIỆN/ẨN TỨC THÌ KHI GÕ
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              return value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel,
                          color: AppColors.softGrey, size: 20),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : const SizedBox(width: 16);
            },
          ),
        ],
      ),
    );
  }
}
