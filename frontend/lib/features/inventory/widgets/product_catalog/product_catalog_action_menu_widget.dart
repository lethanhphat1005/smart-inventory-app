import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProductCatalogActionMenuWidget extends GetView<ProductCatalogController> {
  const ProductCatalogActionMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Chỉ Quản lý (Manager/Owner) mới thấy menu này
    if (!controller.canManageCategory) return const SizedBox.shrink();

    return const _GlassmorphismDropdownMenu();
  }
}

class _GlassmorphismDropdownMenu extends StatefulWidget {
  const _GlassmorphismDropdownMenu();

  @override
  State<_GlassmorphismDropdownMenu> createState() =>
      _GlassmorphismDropdownMenuState();
}

class _GlassmorphismDropdownMenuState extends State<_GlassmorphismDropdownMenu>
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
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _closeMenu() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) {
        setState(() => _isOpen = false);
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeMenu,
            behavior: HitTestBehavior.translucent,
            child: FadeTransition(
              opacity: _animation,
              child: Container(color: Colors.black.withOpacity(0.02)),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            followerAnchor: Alignment.topRight,
            targetAnchor: Alignment.centerRight,
            offset: Offset(-8, size.height / 2 + 10),
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _animation,
                child: ScaleTransition(
                  scale: _animation,
                  alignment: Alignment.topRight,
                  child: IntrinsicWidth(
                    child: _buildGlassmorphismCard(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismCard() {
    final controller = Get.find<ProductCatalogController>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radius20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppSizes.radius20),
            border:
                Border.all(color: Colors.white.withOpacity(0.5), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                icon: Iconsax.eye_slash_copy, // Icon mắt bị gạch chéo
                text: TTexts.hiddenCategories.tr,
                onTap: () {
                  _closeMenu();
                  controller.goToHiddenCategories(); // Gọi hàm vừa tạo
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radius12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primaryText, size: 20),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                color: color ?? AppColors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        splashColor: AppColors.divider.withOpacity(0.1),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: 6),
          child:
              Icon(Iconsax.more_copy, color: AppColors.primaryText, size: 24),
        ),
      ),
    );
  }
}
