import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';

class StockAdjustmentFabWidget extends StatefulWidget {
  final VoidCallback onCheckAll;
  final VoidCallback onUncheckAll;

  const StockAdjustmentFabWidget({
    super.key,
    required this.onCheckAll,
    required this.onUncheckAll,
  });

  @override
  State<StockAdjustmentFabWidget> createState() =>
      _StockAdjustmentFabWidgetState();
}

class _StockAdjustmentFabWidgetState extends State<StockAdjustmentFabWidget>
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
    return SizedBox(
      width: 200,
      height: 220,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              // --- Nút 1: Uncheck All ---
              _buildActionItem(
                bottomOffset: 140 * _expandAnimation.value,
                label: TTexts.uncheckAll.tr,
                icon: Icons.remove_done,
                color: AppColors.primaryText,
                onPressed: () {
                  _toggle();
                  widget.onUncheckAll();
                },
              ),

              // --- Nút 2: Check All ---
              _buildActionItem(
                bottomOffset: 75 * _expandAnimation.value,
                label: TTexts.checkAll.tr,
                icon: Icons.checklist_rtl,
                color: AppColors.primaryText,
                onPressed: () {
                  _toggle();
                  widget.onCheckAll();
                },
              ),

              // --- Nút Chính ---
              Positioned(
                bottom: 0,
                right: 0,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    heroTag: "fab_adjustment_main",
                    shape: const CircleBorder(),
                    backgroundColor:
                        _isOpen ? AppColors.primaryText : AppColors.primaryText,
                    elevation: 6,
                    onPressed: _toggle,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.125)
                          .animate(_controller),
                      child: const Icon(Icons.flash_on_rounded,
                          color: Colors.white, size: 28),
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

  Widget _buildActionItem(
      {required double bottomOffset,
      required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return Positioned(
      bottom: bottomOffset,
      right: 4,
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
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white)),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 48,
                height: 48,
                child: FloatingActionButton(
                  heroTag: label,
                  shape: const CircleBorder(),
                  backgroundColor: color,
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
