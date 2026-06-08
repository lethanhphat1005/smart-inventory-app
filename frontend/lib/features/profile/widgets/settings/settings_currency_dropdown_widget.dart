import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/profile/controllers/settings_controller.dart';
import 'package:frontend/features/profile/widgets/settings/settings_currency_skeleton_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

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
        vsync: this, duration: const Duration(milliseconds: 200));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _animationController.reverse().then((_) {
        _removeOverlay();
        if (mounted) setState(() => _isOpen = false);
      });
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isOpen = true);
      _animationController.forward();
    }
  }

  Widget _buildCurrencyIcon(String symbol) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [
          AppColors.primary.withOpacity(0.2),
          AppColors.primary.withOpacity(0.05)
        ]),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      alignment: Alignment.center,
      child: Text(symbol,
          style: TextStyle(
              fontSize: 12,
              fontFamily: AppFonts.mainFont,
              fontWeight: FontWeight.bold,
              color: AppColors.primary)),
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
              onTap: _toggleDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent)),
          CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, size.height + 8),
            child: Material(
              color: Colors.transparent,
              child: SizeTransition(
                sizeFactor: _animation,
                child: Container(
                  width: size.width,
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radius8),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 20)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radius8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius8)),
                        child: Obx(() {
                          // Thuật toán tách lọc và đưa currency được chọn lên đầu danh sách
                          final selectedCode =
                              controller.selectedCurrency.value?['code'];
                          final sortedList =
                              List.from(controller.supportedCurrencies);

                          if (selectedCode != null) {
                            final selectedIndex = sortedList
                                .indexWhere((c) => c['code'] == selectedCode);
                            if (selectedIndex != -1) {
                              final selectedItem =
                                  sortedList.removeAt(selectedIndex);
                              sortedList.insert(0, selectedItem);
                            }
                          }

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: sortedList.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              final currency = sortedList[index];
                              final isSelected =
                                  currency['code'] == selectedCode;

                              return InkWell(
                                onTap: () {
                                  _toggleDropdown();
                                  controller.changeCurrency(currency);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.p16, vertical: 12),
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.05)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      _buildCurrencyIcon(
                                          currency['symbol'] ?? ''),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(currency['name'] ?? '',
                                            style: TextStyle(
                                                fontFamily: AppFonts.mainFont,
                                                fontSize: 12,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.primaryText)),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_circle,
                                            color: AppColors.primary, size: 18),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
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
      child: Obx(() {
        if (controller.isLoadingCurrencies.value) {
          return const SettingsCurrencySkeletonWidget();
        }

        final selected = controller.selectedCurrency.value;
        final role = controller.currentUserRole.value.toLowerCase();
        final isRestricted = role == 'staff' || role == 'employee';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            InkWell(
              onTap: () {
                if (isRestricted) {
                  TSnackbarsWidget.warning(
                    title: TTexts.errorAccessRestrictedTitle.tr,
                    message: TTexts.currencyRestrictedMessage.tr,
                  );
                  return;
                }
                _toggleDropdown();
              },
              borderRadius: BorderRadius.circular(AppSizes.radius8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p16, vertical: 14),
                decoration: BoxDecoration(
                  color: isRestricted
                      ? Colors.grey.withOpacity(0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radius8),
                  border: Border.all(
                      color: _isOpen ? AppColors.primary : Colors.grey.shade300,
                      width: _isOpen ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    if (selected != null) ...[
                      _buildCurrencyIcon(selected['symbol'] ?? ''),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(selected['name'] ?? '',
                              style: TextStyle(
                                  fontFamily: AppFonts.mainFont,
                                  fontSize: 12,
                                  color: isRestricted
                                      ? AppColors.subText
                                      : AppColors.primaryText,
                                  fontWeight: FontWeight.w500))),
                    ] else ...[
                      Expanded(
                          child: Text(TTexts.loading.tr,
                              style: TextStyle(
                                  color: AppColors.softGrey,
                                  fontSize: 12,
                                  fontFamily: AppFonts.mainFont))),
                    ],
                    if (isRestricted)
                      const Icon(Iconsax.lock_1_copy,
                          size: 20, color: AppColors.softGrey)
                    else
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Iconsax.arrow_down_1_copy,
                            size: 20, color: AppColors.softGrey),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
