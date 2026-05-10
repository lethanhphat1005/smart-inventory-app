// lib/core/ui/widgets/t_app_bar_widget.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/routes/app_routes.dart';

class TAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackArrow;
  final Widget? leadingWidget;
  final List<Widget>? actions;
  final bool showSearchIcon;
  final VoidCallback? onSearchPressed;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final VoidCallback? onBackPress;

  const TAppBarWidget({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackArrow = true,
    this.leadingWidget,
    this.actions,
    this.showSearchIcon = false,
    this.onSearchPressed,
    this.bottom,
    this.centerTitle = true,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: AppColors.background.withOpacity(0.8),
          elevation: 0,
          centerTitle: centerTitle,
          automaticallyImplyLeading: false,
          bottom: bottom,
          leading: leadingWidget ??
              (showBackArrow
                  ? InkWell(
                      onTap: onBackPress ?? () => Get.back(),
                      borderRadius: BorderRadius.circular(AppSizes.radius8),
                      child: const Center(
                        child: Icon(Iconsax.arrow_left_2_copy,
                            color: AppColors.primaryText, size: 20),
                      ),
                    )
                  : null),
          title: titleWidget ??
              (title != null
                  ? Text(title!,
                      style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.mainFont))
                  : null),
          actions: [
            if (showSearchIcon)
              IconButton(
                icon: const Icon(Iconsax.search_normal_copy,
                    color: AppColors.primaryText),
                onPressed: onSearchPressed ??
                    () => Get.toNamed(AppRoutes.search,
                        arguments: {'target': SearchTarget.inventory}),
              ),
            ...?actions,
            const SizedBox(width: AppSizes.p8),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
