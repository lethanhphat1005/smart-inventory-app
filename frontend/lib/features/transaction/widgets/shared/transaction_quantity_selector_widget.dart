import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class TransactionQuantitySelectorWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final int? maxQuantity;
  final bool isUnlimited;

  const TransactionQuantitySelectorWidget({
    super.key,
    required this.controller,
    required this.onIncrease,
    required this.onDecrease,
    this.maxQuantity,
    this.isUnlimited = false,
  });

  @override
  State<TransactionQuantitySelectorWidget> createState() =>
      _TransactionQuantitySelectorWidgetState();
}

class _TransactionQuantitySelectorWidgetState
    extends State<TransactionQuantitySelectorWidget> {
  late FocusNode _focusNode;

  // ĐÃ SỬA: Nếu isUnlimited là true thì cho max là xấp xỉ 1 tỷ
  int get _effectiveMax =>
      widget.isUnlimited ? 999999999 : (widget.maxQuantity ?? 999999);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (widget.controller.text.isEmpty) {
          widget.controller.text = '0';
        }
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChanged(String value) {
    if (value.isEmpty) return;
    int val = int.tryParse(value) ?? 0;

    // Tự động ép về ngưỡng tối đa nếu cố tình gõ lố
    if (val >= _effectiveMax) {
      widget.controller.text = _effectiveMax.toString();
      widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        int current = int.tryParse(value.text) ?? 0;

        bool canDecrease = current > 0;
        bool canIncrease = current < _effectiveMax;

        // Trạng thái đạt giới hạn (isMaxed) chỉ được bật khi CHẠM ĐÚNG NGƯỠNG TRẦN
        bool isMaxed = current >= _effectiveMax;

        // Xác định câu thông báo tương ứng
        String errorText = '';
        if (isMaxed) {
          if (widget.maxQuantity != null) {
            errorText = TTexts.maxStockReached.tr;
          } else {
            errorText = TTexts.absoluteMaxQuantity.tr;
          }
        }

        return Column(
          // Đảm bảo khối luôn ở giữa, không bị dạt sang phải khi Tag đỏ xuất hiện
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isMaxed
                      ? Colors.red.shade400
                      : AppColors.divider.withOpacity(0.5),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMaxed
                        ? Colors.red.withOpacity(0.1)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBtn(
                    icon: Icons.remove,
                    onTap: canDecrease ? widget.onDecrease : null,
                    color: canDecrease
                        ? AppColors.primaryText
                        : AppColors.softGrey,
                  ),
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 84,
                      maxWidth: 140,
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        textSelectionTheme: TextSelectionThemeData(
                          cursorColor: AppColors.primary,
                          selectionColor: AppColors.primary.withOpacity(0.3),
                          selectionHandleColor: AppColors.primary,
                        ),
                      ),
                      child: TextFormField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: _onInputChanged,
                        cursorColor: AppColors.primary,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  _buildBtn(
                    icon: Icons.add,
                    onTap: canIncrease ? widget.onIncrease : null,
                    color: canIncrease
                        ? AppColors.primaryText
                        : AppColors.softGrey,
                  ),
                ],
              ),
            ),

            // Hiện tag nếu chạm ngưỡng
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.red, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        errorText,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
          ],
        );
      },
    );
  }

  Widget _buildBtn(
      {required IconData icon, VoidCallback? onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
