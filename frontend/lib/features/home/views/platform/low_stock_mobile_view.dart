import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_animation_loader_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/features/home/controllers/low_stock_controller.dart';
import 'package:frontend/features/home/widgets/low_stock/low_stock_item_widget.dart';
import 'package:frontend/features/home/widgets/low_stock/low_stock_overview_widget.dart';
import 'package:frontend/features/home/widgets/low_stock/low_stock_shimmer_widget.dart'; // ĐÃ THÊM IMPORT SHIMMER
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

class LowStockMobileView extends GetView<LowStockController> {
  const LowStockMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: TAppBarWidget(
        title: TTexts.lowStockTitle.tr,
      ),
      body: TRefreshIndicatorWidget(
        onRefresh: () => controller.fetchLowStock(isRefresh: true),
        child: Obx(() {
          // 1. TRẠNG THÁI LOADING -> HIỆN SHIMMER THAY VÌ VÒNG XOAY CŨ
          if (controller.isLoading.value) {
            return const LowStockShimmerWidget();
          }

          // Tách data ban đầu
          final outOfStockData =
              controller.lowStockItems.where((e) => e.quantity <= 0).toList();
          final lowStockData =
              controller.lowStockItems.where((e) => e.quantity > 0).toList();

          final List<dynamic> flattenedList = [];

          // 1. LUÔN HIỂN THỊ THẺ OVERVIEW VỚI TRẠNG THÁI CHỌN
          flattenedList.add({
            'type': 'HEADER_CARDS',
            'outCount': outOfStockData.length,
            'lowCount': lowStockData.length,
            'filter': controller.activeFilter.value
          });

          // 2. LOGIC LỌC DANH SÁCH THEO STATE
          final String currentFilter = controller.activeFilter.value;

          if ((currentFilter == '' || currentFilter == TTexts.tabOutStock) &&
              outOfStockData.isNotEmpty) {
            flattenedList.add('HEADER_OUT_OF_STOCK');
            flattenedList.addAll(outOfStockData);
          }

          if ((currentFilter == '' || currentFilter == TTexts.tabLowStock) &&
              lowStockData.isNotEmpty) {
            flattenedList.add('HEADER_LOW_STOCK');
            flattenedList.addAll(lowStockData);
          }

          if (controller.isLoadMore.value) flattenedList.add('LOADING');

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 50) {
                controller.onLoadMore();
              }
              return false;
            },
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top +
                    kToolbarHeight +
                    AppSizes.p20,
                left: AppSizes.p20,
                right: AppSizes.p20,
                bottom: AppSizes.p20,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: flattenedList.length,
              itemBuilder: (context, index) {
                final item = flattenedList[index];

                if (item is Map && item['type'] == 'HEADER_CARDS') {
                  return LowStockOverviewWidget(
                    outCount: item['outCount'],
                    lowCount: item['lowCount'],
                    activeFilter: item['filter'],
                    onToggle: (f) => controller.toggleFilter(f),
                  );
                }

                if (item == 'HEADER_OUT_OF_STOCK') {
                  return _buildSectionHeader(
                      TTexts.outOfStockSection.tr, AppColors.alertText);
                }

                if (item == 'HEADER_LOW_STOCK') {
                  return _buildSectionHeader(
                      TTexts.lowStockSection.tr, Colors.orange);
                }

                if (item == 'LOADING') {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                        child: TAnimationLoaderWidget(
                            text: TTexts.loading.tr, showBackground: false)),
                  );
                }

                return LowStockItemWidget(
                  model: item,
                  onTap: () {
                    final pkg = item.productPackage;
                    final productId = pkg?.productId ?? pkg?.product?.productId;
                    final packageId =
                        pkg?.productPackageId ?? item.productPackageId;
                    final barcode = pkg?.barcodeValue ?? '';

                    if (productId != null || packageId.isNotEmpty) {
                      Get.toNamed(
                        AppRoutes.inventoryDetail,
                        arguments: productId?.toString(),
                        parameters: {
                          if (packageId.isNotEmpty) 'packageId': packageId,
                          if (barcode.isNotEmpty) 'barcode': barcode,
                        },
                      );
                    }
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p16, top: AppSizes.p8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
