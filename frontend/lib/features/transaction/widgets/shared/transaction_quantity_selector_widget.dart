import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class TransactionQuantitySelectorWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final int? maxQuantity;

  const TransactionQuantitySelectorWidget({
    super.key,
    required this.controller,
    required this.onIncrease,
    required this.onDecrease,
    this.maxQuantity,
  });

  @override
  State<TransactionQuantitySelectorWidget> createState() =>
      _TransactionQuantitySelectorWidgetState();
}

class _TransactionQuantitySelectorWidgetState
    extends State<TransactionQuantitySelectorWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Chỉ đưa về 1 khi người dùng click ra chỗ khác
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (widget.controller.text.isEmpty || widget.controller.text == '0') {
          widget.controller.text = '1';
        }
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tăng giới hạn mặc định lên 7 số (9.999.999) phòng trường hợp stock cực lớn
    final int limit = widget.maxQuantity ?? 9999999;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.labelQuantity.tr,
          style: TextStyle(
            fontFamily: AppFonts.mainFont,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.subText,
          ),
        ),
        const SizedBox(height: AppSizes.p16),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // NÚT TRỪ (CLEAN GLASS)
              _buildPremiumGlassButton(
                icon: Iconsax.minus_copy,
                onTap: () {
                  if (widget.controller.text.isEmpty) {
                    widget.controller.text = '1';
                  }
                  final current = int.tryParse(widget.controller.text) ?? 1;
                  if (current <= 1) return;
                  widget.onDecrease();
                },
                color: AppColors.primaryText,
              ),

              const SizedBox(width: 16),

              // Ô NHẬP SỐ (CLEAN BOX)
              Container(
                width: 140, // Mở rộng không gian hiển thị
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                  // Đã xóa Shadow để giao diện phẳng và sạch hơn
                ),
                child: Center(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        selectionHandleColor: AppColors.primary,
                        selectionColor: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: TextFormField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7),
                      ],
                      onChanged: (val) {
                        if (val.isEmpty) return;
                        int current = int.tryParse(val) ?? 1;

                        if (current > limit) {
                          widget.controller.text = limit.toString();
                          widget.controller.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: widget.controller.text.length));
                        }
                      },
                      onTapOutside: (_) => _focusNode.unfocus(),
                      cursorColor: AppColors.primary,
                      style: TextStyle(
                        fontFamily: AppFonts.mainFont,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // NÚT CỘNG (CLEAN GLASS)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, child) {
                  final current = int.tryParse(value.text) ?? 1;
                  final isMaxed = current >= limit;
                  return _buildPremiumGlassButton(
                    icon: Iconsax.add_copy,
                    isMaxed: isMaxed,
                    onTap: isMaxed
                        ? () {}
                        : () {
                            if (widget.controller.text.isEmpty) {
                              widget.controller.text = '1';
                            }
                            widget.onIncrease();
                          },
                    color: AppColors.primary,
                  );
                },
              ),
            ],
          ),
        ),

        // CẢNH BÁO MÀU CAM BÊN DƯỚI
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            final current = int.tryParse(value.text) ?? 1;
            if (current >= limit) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    widget.maxQuantity != null
                        ? '* ${TTexts.maxStockReached.tr}'
                        : '* ${TTexts.maxQuantityReached.tr}',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  // WIDGET KÍNH MỜ PHẲNG (KHÔNG ĐỔ BÓNG)
  Widget _buildPremiumGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    bool isMaxed = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // Đã xóa Shadow bên ngoài để tạo cảm giác "Clean"
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isMaxed ? null : onTap,
              splashColor: color.withOpacity(0.2),
              highlightColor: color.withOpacity(0.1),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Phản quang tinh tế
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.6),
                      color.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.9),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(icon,
                      size: 24, color: isMaxed ? AppColors.softGrey : color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
