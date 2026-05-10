import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/profile/controllers/settings_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SettingsLanguageDropdownWidget extends StatefulWidget {
  const SettingsLanguageDropdownWidget({super.key});

  @override
  State<SettingsLanguageDropdownWidget> createState() =>
      _SettingsLanguageDropdownWidgetState();
}

class _SettingsLanguageDropdownWidgetState
    extends State<SettingsLanguageDropdownWidget>
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
                  constraints: const BoxConstraints(maxHeight: 250),
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
                          itemCount: controller.supportedLanguages.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1, color: Colors.white.withOpacity(0.3)),
                          itemBuilder: (context, index) {
                            final lang = controller.supportedLanguages[index];
                            return InkWell(
                              onTap: () {
                                // 1. Xóa nóng Overlay KHÔNG chờ animation để tránh lỗi defunct
                                if (_overlayEntry != null) {
                                  _overlayEntry!.remove();
                                  _overlayEntry = null;
                                }

                                // 2. Cập nhật state nội bộ
                                if (mounted) {
                                  setState(() => _isOpen = false);
                                }

                                // 3. Gọi GetX đổi ngôn ngữ (rebuild toàn app)
                                controller.changeLanguage(lang);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade200,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      alignment: Alignment.center,
                                      child: Text(
                                        lang.flagEmoji,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(lang.name,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins',
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
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller.languageController,
          builder: (context, value, child) {
            final selectedLang = controller.supportedLanguages.firstWhere(
              (lang) => lang.name == value.text,
              orElse: () => controller.supportedLanguages.first,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Label (Giống TTextFormFieldWidget)
                Text(
                  TTexts.settingsLanguage.tr,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subText,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),

                // 2. Ô Input giả lập
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
                      // --- Cờ hình tròn ---
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          selectedLang.flagEmoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // --- Text ngôn ngữ ---
                      Expanded(
                        child: Text(
                          selectedLang.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subText,
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
          },
        ),
      ),
    );
  }
}
