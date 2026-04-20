import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InventoryProductPackageUnitDropdownWidget extends StatefulWidget {
  const InventoryProductPackageUnitDropdownWidget({super.key});

  @override
  State<InventoryProductPackageUnitDropdownWidget> createState() =>
      _InventoryProductPackageUnitDropdownWidgetState();
}

class _InventoryProductPackageUnitDropdownWidgetState
    extends State<InventoryProductPackageUnitDropdownWidget>
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
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _closeDropdown() {
    _animationController.reverse().then((_) {
      if (mounted) {
        _removeOverlay();
      }
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
    final controller = Get.find<ProductFormController>();

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
                        child: Obx(() => ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: controller.allUnits.length,
                              separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.3)),
                              itemBuilder: (context, index) {
                                final unit = controller.allUnits[index];
                                return InkWell(
                                  onTap: () {
                                    controller.selectedUnitId.value =
                                        unit.unitId;
                                    // CHỈ CẦN GÁN TEXT LÀ XONG, LISTENER SẼ LÀM VIỆC CÒN LẠI
                                    controller.unitNameController.text =
                                        unit.name;
                                    _closeDropdown();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(unit.name,
                                            style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                color: AppColors.primaryText,
                                                fontWeight: FontWeight.w600)),
                                        Text(unit.code,
                                            style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: AppColors.subText,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
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
    final controller = Get.find<ProductFormController>();

    // Kiểm tra xem có đang ở trạng thái Edit hay không
    final isEditMode = controller.packageToEdit != null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        // Khóa luôn sự kiện mở dropdown nếu đang ở chế độ Edit
        onTap: isEditMode ? null : _toggleDropdown,
        child: AbsorbPointer(
          child: TTextFormFieldWidget(
            label: TTexts.unitLabel.tr,
            hintText: TTexts.selectUnit.tr,
            controller: controller.unitNameController,
            readOnly: true,
            // Thay đổi icon dựa vào trạng thái Edit
            suffixIcon: isEditMode
                ? const Icon(
                    Iconsax.lock_1_copy,
                    size: 20,
                    color: AppColors.subText,
                  )
                : AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Iconsax.arrow_down_1_copy,
                      size: 20,
                      color: AppColors.primaryText,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
