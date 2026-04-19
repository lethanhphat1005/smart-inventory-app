import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_animation_loader_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/notification/controller/reorder_suggestion_controller.dart';
import 'package:frontend/features/notification/widgets/reorder_suggestion_card_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ReorderSuggestionMobileScreen
    extends GetView<ReorderSuggestionController> {
  const ReorderSuggestionMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TAppBarWidget(
        title: TTexts.reorderReportTitle.tr,
        showBackArrow: true,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: TAnimationLoaderWidget(
              text: TTexts.aiAnalyzingStock.tr,
              showBackground: false,
            ),
          );
        }

        if (controller.suggestions.isEmpty) {
          return TRefreshIndicatorWidget(
            onRefresh: () async => controller.fetchSuggestions(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: TEmptyStateWidget(
                  icon: Iconsax.health_copy,
                  title: TTexts.optimalStockTitle.tr,
                  subtitle: TTexts.optimalStockDesc.tr,
                ),
              ),
            ),
          );
        }

        return TRefreshIndicatorWidget(
          onRefresh: () async => controller.fetchSuggestions(),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p16),
            itemBuilder: (context, index) {
              final item = controller.suggestions[index];

              return ReorderSuggestionCardWidget(
                item: item,
                onDismiss: () => controller.dismissSuggestion(item.productId),
              );
            },
          ),
        );
      }),
    );
  }
}
