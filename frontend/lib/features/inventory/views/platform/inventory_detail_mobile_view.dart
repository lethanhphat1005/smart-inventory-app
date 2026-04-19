import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_data_error_layout.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/inventory/controllers/inventory_detail_controller.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_shimmer_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_header_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_health_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_product_info_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_barcode_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_pricing_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_history_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_related_packages_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_basic_info_widget.dart';
import 'package:frontend/features/inventory/widgets/inventory_detail/inventory_detail_stock_stats_widget.dart';

class InventoryDetailMobileView extends GetView<InventoryDetailController> {
  const InventoryDetailMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryDetailController>(
      builder: (ctrl) {
        final hasData =
            !ctrl.isLoading.value && ctrl.currentDisplayItem.value != null;

        return PopScope(
            canPop: ctrl.historyStack.isEmpty,
            onPopInvoked: (didPop) {
              if (!didPop) {
                // Bấm back hệ thống thì gọi hàm back chuẩn của Controller
                ctrl.goBack();
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.background,

              // APP BAR DỰ PHÒNG CHỈ HIỆN KHI BỊ LỖI
              appBar: hasData || ctrl.isLoading.value
                  ? null
                  : AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Iconsax.arrow_left_2_copy,
                            color: AppColors.primaryText),
                        onPressed: () => ctrl.goBack(),
                      ),
                    ),

              // MAIN BODY
              body: ctrl.isLoading.value
                  // 1. KHI ĐANG TẢI (KỂ CẢ VÀO LẦN ĐẦU HAY QUA RELATED) -> HIỂN THỊ SHIMMER
                  ? const InventoryDetailShimmerWidget()

                  // 2. KHI ĐÃ TẢI XONG NHƯNG KHÔNG CÓ DỮ LIỆU HOẶC LỖI
                  : (!hasData
                      ? TDataErrorLayout(
                          onPressed: () => Get.back(),
                          message: TTexts.errorNotFoundMessage.tr,
                        )

                      // 3. KHI CÓ DỮ LIỆU -> BỌC LẠI REFRESH INDICATOR Ở ĐÂY
                      : TRefreshIndicatorWidget(
                          onRefresh:
                              ctrl.refreshData, // ĐÃ TRẢ LẠI REFRESH INDICATOR
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              final slide = Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero)
                                  .animate(animation);
                              final fade = Tween<double>(begin: 0, end: 1)
                                  .animate(animation);
                              return SlideTransition(
                                position: slide,
                                child:
                                    FadeTransition(opacity: fade, child: child),
                              );
                            },
                            child: _DetailContent(key: ValueKey(ctrl.barcode)),
                          ),
                        )),
            ));
      },
    );
  }
}

// =========================================================
// WIDGET NỘI DUNG CHI TIẾT (TỐI ƯU HIỆU SUẤT VỚI SLIVERS)
// =========================================================
class _DetailContent extends StatelessWidget {
  const _DetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // Cho phép luôn cuộn để mượt mà (chống lag)
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // 1. Header Slivers (Ảnh, Nút Back, Menu)
        const InventoryDetailHeaderWidget(),

        // 2. Nội dung Slivers
        // TỐI ƯU: Đập bỏ Column/SingleChildScrollView khổng lồ bằng SliverList
        // giúp Flutter chỉ render những component đang nằm trên màn hình -> FPS tăng vọt.
        SliverPadding(
          padding: const EdgeInsets.only(
            top: AppSizes.p12,
            bottom: AppSizes.p24,
          ),
          sliver: SliverList.list(
            children: [
              const InventoryDetailProductInfoWidget(),
              const SizedBox(height: AppSizes.p16),
              const InventoryDetailBarcodeWidget(),
              const _Divider(),
              const InventoryDetailPricingWidget(),
              const _Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                child: Text(
                  TTexts.inventoryStatus.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.p12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Expanded(flex: 4, child: InventoryDetailHealthWidget()),
                    SizedBox(width: AppSizes.p20),
                    Expanded(flex: 5, child: InventoryDetailBasicInfoWidget()),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
                child: InventoryDetailStockStatsWidget(),
              ),
              const _Divider(),
              _buildSectionTitle(TTexts.relatedPackages.tr),
              const InventoryDetailRelatedPackagesWidget(),
              const _Divider(),
              _buildSectionTitle(TTexts.inventoryHistory.tr),
              const InventoryDetailHistoryWidget(),
              const SizedBox(height: AppSizes.bottomNavSpacer),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p20,
        vertical: 4,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.p16,
        horizontal: AppSizes.p20,
      ),
      child: Divider(
        color: AppColors.divider.withOpacity(0.6),
        height: 1,
      ),
    );
  }
}
