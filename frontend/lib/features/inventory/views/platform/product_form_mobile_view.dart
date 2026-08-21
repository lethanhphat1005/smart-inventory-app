import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_form_action_buttons_widget.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_form_base_info_widget.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_form_image_widget.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_form_multiple_packages_widget.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_form_shimmer_widget.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_package_form_fields_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:frontend/features/inventory/widgets/product_form/product_form_progress_bar_widget.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProductFormMobileView extends GetView<ProductFormController> {
  const ProductFormMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = controller.formMode.value;
      final step = controller.currentStep.value;
      final isLoading = controller.isLoadingData.value;

      final isViewOnly = mode == 'view_package';

      return PopScope(
        canPop: isViewOnly,
        onPopInvoked: (didPop) {
          if (didPop) return;
          controller.confirmExit();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: TAppBarWidget(
            title: _getAppBarTitle(mode),
            centerTitle: true,
            showBackArrow: true,
            onBackPress: () {
              if (isViewOnly) {
                Get.back();
              } else {
                controller.confirmExit();
              }
            },
            actions: [
              IconButton(
                icon: const Icon(Iconsax.info_circle_copy,
                    color: AppColors.primaryText),
                onPressed: () => controller.showInstructionBottomSheet(),
              ),
            ],
          ),
          body: SafeArea(
            child: isLoading
                ? const InventoryProductFormShimmerWidget()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        if (mode == 'create')
                          const ProductFormProgressBarWidget(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.p20,
                              vertical: mode == 'create'
                                  ? AppSizes.p12
                                  : AppSizes.p24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getHeaderTitle(mode, step),
                                style: TextStyle(
                                    fontFamily: AppFonts.mainFont,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getHeaderSubtitle(mode, step),
                                style: TextStyle(
                                    fontFamily: AppFonts.mainFont,
                                    fontSize: 13,
                                    color: AppColors.subText,
                                    height: 1.4),
                              ),
                              const SizedBox(height: 32),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                switchInCurve: Curves.easeOutBack,
                                switchOutCurve: Curves.easeIn,
                                child: _renderCurrentForm(mode, step),
                              ),
                            ],
                          ),
                        ),
                        const InventoryProductFormActionButtonsWidget(),
                      ],
                    ),
                  ),
          ),
        ),
      );
    });
  }

  String _getAppBarTitle(String mode) {
    switch (mode) {
      case 'view_package':
        return TTexts.packageInfo.tr;
      case 'info':
        return TTexts.editProductTitle.tr;
      case 'image':
        return TTexts.editProductImageTitle.tr;
      case 'edit_package':
        return TTexts.editPackageTitle.tr;
      case 'add_package':
        return TTexts.addPackageTitle.tr;
      default:
        return TTexts.addNewProductTitle.tr;
    }
  }

  String _getHeaderTitle(String mode, int step) {
    if (mode == 'view_package') return TTexts.packageInfo.tr;
    if (mode == 'info') return TTexts.productBaseTitle.tr;
    if (mode == 'image') return TTexts.productImageTitle.tr;
    if (mode == 'edit_package') return TTexts.editPackageTitle.tr;
    if (mode == 'add_package') return TTexts.addPackageTitle.tr;
    return step == 1
        ? TTexts.productBaseTitle.tr
        : (step == 2
            ? TTexts.productImageTitle.tr
            : TTexts.productPackageTitle.tr);
  }

  String _getHeaderSubtitle(String mode, int step) {
    if (mode == 'info') return TTexts.step1Sub.tr;
    if (mode == 'image') return TTexts.editProductImageSub.tr;
    if (mode == 'edit_package') return TTexts.editPackageSub.tr;
    if (mode == 'add_package') return TTexts.addPackageSub.tr;
    if (mode == 'view_package') return TTexts.productPackageInfoSub.tr;
    return step == 1
        ? TTexts.productBaseSub.tr
        : (step == 2 ? TTexts.productImageSub.tr : TTexts.productPackageSub.tr);
  }

  Widget _renderCurrentForm(String mode, int step) {
    if (mode == 'info') {
      return const InventoryProductFormBaseInfoWidget(key: ValueKey('info'));
    }
    if (mode == 'image') {
      return const InventoryProductFormImageWidget(key: ValueKey('image'));
    }
    if (mode == 'edit_package' ||
        mode == 'add_package' ||
        mode == 'view_package') {
      return const InventoryProductPackageFormFieldsWidget(
          key: ValueKey('package_form'));
    }

    if (step == 1) {
      return const InventoryProductFormBaseInfoWidget(key: ValueKey('step1'));
    }
    if (step == 2) {
      return const InventoryProductFormImageWidget(key: ValueKey('step2'));
    }
    return const InventoryProductFormMultiplePackagesWidget();
  }
}
