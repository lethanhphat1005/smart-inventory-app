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

    _opacity = Tween<double>(begin: AppSizes.p0_35, end: AppSizes.p0_8).animate(
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
    double radius = AppSizes.p12,
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
        vertical: AppSizes.p7,
        horizontal: AppSizes.p16,
      ),
      padding: const EdgeInsets.all(AppSizes.p14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius24),
        border: Border.all(
          color: AppColors.subText.withOpacity(0.08),
          width: AppSizes.p1_2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: AppSizes.p16,
            offset: const Offset(0, AppSizes.p6),
          ),
        ],
      ),
      child: Row(
        children: [
          _bone(
            width: AppSizes.p58,
            height: AppSizes.p58,
            shape: const CircleBorder(),
          ),
          const SizedBox(width: AppSizes.p14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(
                    width: AppSizes.p140,
                    height: AppSizes.p16,
                    radius: AppSizes.p8),
                const SizedBox(height: AppSizes.p10),
                _bone(
                    width: AppSizes.p72,
                    height: AppSizes.p13,
                    radius: AppSizes.p8),
              ],
            ),
          ),
          _bone(
            width: AppSizes.p32,
            height: AppSizes.p32,
            shape: const CircleBorder(),
          ),
        ],
      ),
    );
  }
}
