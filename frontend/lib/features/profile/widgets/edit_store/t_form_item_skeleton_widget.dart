import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class TStoreItemSkeleton extends StatefulWidget {
  const TStoreItemSkeleton({super.key});

  @override
  State<TStoreItemSkeleton> createState() => _TStoreItemSkeletonState();
}

class _TStoreItemSkeletonState extends State<TStoreItemSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.35, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bone({
    required double width,
    required double height,
    double radius = 12,
    ShapeBorder? shape,
  }) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: AppColors.subText.withOpacity(0.12),
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 7,
        horizontal: AppSizes.p16,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.subText.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _bone(
            width: 58,
            height: 58,
            shape: const CircleBorder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(width: 140, height: 16, radius: 8),
                const SizedBox(height: 10),
                _bone(width: 72, height: 13, radius: 8),
              ],
            ),
          ),
          _bone(
            width: 32,
            height: 32,
            shape: const CircleBorder(),
          ),
        ],
      ),
    );
  }
}
