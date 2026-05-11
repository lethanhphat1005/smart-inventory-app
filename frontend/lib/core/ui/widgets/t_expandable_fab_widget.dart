import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class TExpandableFabWidget extends StatefulWidget {
  final VoidCallback onManualAdd;
  final VoidCallback onScanAdd;
  final bool isStaffMode;

  const TExpandableFabWidget({
    super.key,
    required this.onManualAdd,
    required this.onScanAdd,
    this.isStaffMode = false,
  });

  @override
  State<TExpandableFabWidget> createState() => _TExpandableFabWidgetState();
}

class _TExpandableFabWidgetState extends State<TExpandableFabWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ==============================================================
    // NẾU LÀ STAFF: HIỆN NÚT ĐƠN ĐỂ QUÉT BÌNH THƯỜNG
    // ==============================================================
    if (widget.isStaffMode) {
      return SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          heroTag: "fab_scan_staff",
          shape: const CircleBorder(),
          backgroundColor: Colors.black,
          elevation: 6,
          onPressed: widget.onScanAdd,
          child: const Icon(Iconsax.scan_barcode_copy,
              color: Colors.white, size: 28),
        ),
      );
    }

    // ==============================================================
    // NẾU LÀ MANAGER: HIỆN FAB EXPANDABLE CÓ TEXT
    // ==============================================================
    return SizedBox(
      width: 250, // Mở rộng chiều ngang để chứa chữ
      height: 220,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.bottomRight, // Canh phải để các nút thẳng hàng
            clipBehavior: Clip.none,
            children: [
              // --- Nút 1: Scan Barcode ---
              _buildActionItem(
                bottomOffset: 140 * _expandAnimation.value,
                label: TTexts.fabScanBarcode.tr,
                icon: Iconsax.scan_barcode_copy,
                onPressed: () {
                  _toggle();
                  widget.onScanAdd();
                },
              ),

              // --- Nút 2: Add Manual ---
              _buildActionItem(
                bottomOffset: 75 * _expandAnimation.value,
                label: TTexts.fabAddManual.tr,
                icon: Iconsax.edit_2_copy,
                onPressed: () {
                  _toggle();
                  widget.onManualAdd();
                },
              ),

              // --- Nút Chính Ở Dưới Cùng ---
              Positioned(
                bottom: 0,
                right: 0, // Cố định sát lề phải
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    heroTag: "fab_main",
                    shape: const CircleBorder(),
                    backgroundColor:
                        _isOpen ? const Color(0xFF1E1E24) : Colors.black,
                    elevation: 6,
                    onPressed: _toggle,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.125)
                          .animate(_controller),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Hàm phụ để tạo 1 hàng gồm Text và Nút
  Widget _buildActionItem({
    required double bottomOffset,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Positioned(
      bottom: bottomOffset,
      right: 4, // (56 - 48)/2 = 4 -> Giúp tâm nút nhỏ nằm ngay tâm nút to
      child: Transform.scale(
        scale: _expandAnimation.value,
        child: FadeTransition(
          opacity: _expandAnimation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onPressed,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryText,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppFonts.mainFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16), // Khoảng cách giữa chữ và nút
              // Nút bấm nhỏ
              SizedBox(
                width: 48,
                height: 48,
                child: FloatingActionButton(
                  heroTag: label, // Đảm bảo mỗi nút có tag riêng biệt
                  shape: const CircleBorder(),
                  backgroundColor: const Color(0xFF1E1E24),
                  elevation: 4,
                  onPressed: onPressed,
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
