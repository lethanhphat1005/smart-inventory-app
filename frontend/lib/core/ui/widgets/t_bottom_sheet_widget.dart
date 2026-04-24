import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class TBottomSheetWidget extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const TBottomSheetWidget({
    super.key,
    this.title,
    required this.child,
    this.padding,
  });

  static void show({
    String? title,
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) {
    Get.bottomSheet(
      TBottomSheetWidget(
        title: title,
        padding: padding,
        child: child,
      ),
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enterBottomSheetDuration: const Duration(milliseconds: 350),
      exitBottomSheetDuration: const Duration(milliseconds: 250),
      barrierColor: Colors.black.withOpacity(0.4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final defaultPadding = padding ?? const EdgeInsets.all(AppSizes.p24);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 80.0, end: 0.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, value),
          child: childWidget,
        );
      },
      child: Container(
        padding: defaultPadding.add(EdgeInsets.only(bottom: bottomPadding)),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppSizes.radius24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: AppSizes.p20),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppSizes.radius8),
              ),
            ),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.p16),
              const Divider(
                  color: AppColors.divider, thickness: 1.5, height: 1),
              const SizedBox(height: AppSizes.p24),
            ],
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
