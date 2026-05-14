import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/profile/controllers/settings_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SettingsCurrencyDropdownWidget extends StatefulWidget {
  const SettingsCurrencyDropdownWidget({super.key});

  @override
  State<SettingsCurrencyDropdownWidget> createState() =>
      _SettingsCurrencyDropdownWidgetState();
}

class _SettingsCurrencyDropdownWidgetState
    extends State<SettingsCurrencyDropdownWidget>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    _isOpen ? _closeDropdown() : _openDropdown();
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _closeDropdown() {
    _animationController.reverse().then((_) {
      if (mounted) _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  // Widget tạo Icon Tiền Tệ "Premium" (Có Gradient và Viền)
  Widget _buildCurrencyIcon(String symbol) {
    return Container(
      width: 32, // Tăng size lên xíu cho đẹp
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        symbol,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final controller = Get.find<SettingsController>();

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 8),
            child: Material(
              color: Colors.transparent,
              child: SizeTransition(
                sizeFactor: _animation,
                axisAlignment: -1,
                child: Container(
                  width: size.width,
                  constraints: const BoxConstraints(
                      maxHeight:
                          280), // Nới chiều cao thêm chút cho nhiều tiền tệ
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radius16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.6),
                              Colors.white.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.7), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: controller.supportedCurrencies.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1, color: Colors.white.withOpacity(0.3)),
                          itemBuilder: (context, index) {
                            final currency =
                                controller.supportedCurrencies[index];
                            return InkWell(
                              onTap: () {
                                if (_overlayEntry != null) {
                                  _overlayEntry!.remove();
                                  _overlayEntry = null;
                                }
                                if (mounted) {
                                  setState(() => _isOpen = false);
                                }
                                controller.changeCurrency(currency);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12), // Giảm padding dọc 1 chút
                                child: Row(
                                  children: [
                                    _buildCurrencyIcon(
                                        currency['symbol'] ?? ''),
                                    const SizedBox(width: 12),
                                    Text(currency['name'] ?? '',
                                        style: TextStyle(
                                            fontFamily: AppFonts.mainFont,
                                            fontSize: 14,
                                            color: AppColors.primaryText,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Obx(() {
          final selectedCurrency = controller.supportedCurrencies.firstWhere(
            (c) => c['code'] == controller.currentCurrencyCode.value,
            orElse: () => controller.supportedCurrencies.first,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label Tiền tệ (Đã dùng Locale)
              Text(
                TTexts.currencyLabel.tr,
                style: TextStyle(
                  fontFamily: AppFonts.mainFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subText,
                ),
              ),
              const SizedBox(height: AppSizes.p8),

              // Ô Input giả lập
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radius8),
                ),
                child: Row(
                  children: [
                    // --- Ký hiệu tiền tệ hình tròn ---
                    _buildCurrencyIcon(selectedCurrency['symbol'] ?? ''),
                    const SizedBox(width: 12),

                    // --- Text tên tiền tệ ---
                    Expanded(
                      child: Text(
                        selectedCurrency['name'] ?? '',
                        style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors
                              .subText, // Chỉnh lại subText hoặc primaryText tuỳ ý bạn
                        ),
                      ),
                    ),

                    // --- Suffix Icon (Mũi tên xoay) ---
                    AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Iconsax.arrow_down_1_copy,
                        size: 20,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
