import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:frontend/features/auth/controllers/legal_document_controller.dart';

class LegalDocumentMobileView extends GetView<LegalDocumentController> {
  const LegalDocumentMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TBlurAppBarWidget(),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.title,
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: AppSizes.p24),
                Text(
                  controller.content.value,
                  style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontSize: 14,
                    color: AppColors.subText,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSizes.p48),
              ],
            ),
          );
        }),
      ),
    );
  }
}
