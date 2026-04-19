import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/routes/app_routes.dart';

class TBarcodeExactMatchBottomSheet {
  static void show(
      {required String barcode, required Map<String, dynamic> packageData}) {
    TBottomSheetWidget.show(
      title: 'Sản phẩm đã tồn tại',
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mã vạch này đã được gán cho một sản phẩm trong cửa hàng.',
              style: TextStyle(
                  color: AppColors.subText,
                  fontSize: AppSizes.p14,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: AppSizes.p16),
            Container(
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(AppSizes.radius8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã vạch: $barcode',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText)),
                  const SizedBox(height: AppSizes.p4),
                  Text('Tên: ${packageData['displayName']}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.p4),
                  Text('Giá bán: ${packageData['sellingPrice']} đ',
                      style: const TextStyle(color: AppColors.subText)),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius12)),
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                ),
                onPressed: () {
                  Get.back(); // Đóng Bottom Sheet
                  Get.back(); // Đóng màn Scanner
                  Get.toNamed(AppRoutes.inventoryDetail, arguments: {
                    'packageId': packageData['productPackageId'],
                    'package': packageData,
                  });
                },
                child: const Text('Xem chi tiết sản phẩm',
                    style: TextStyle(
                        color: AppColors.whiteText,
                        fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
