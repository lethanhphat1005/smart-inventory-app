import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/routes/app_routes.dart';

class TBarcodeNotFoundBottomSheet {
  static void show({required String barcode}) {
    TBottomSheetWidget.show(
      title: 'Chưa có dữ liệu',
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mã vạch này hoàn toàn mới. Bạn có muốn thêm sản phẩm này vào hệ thống không?',
              style: TextStyle(
                  color: AppColors.subText,
                  fontSize: AppSizes.p14,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: AppSizes.p16),
            Container(
              padding: const EdgeInsets.all(AppSizes.p12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(AppSizes.radius8),
              ),
              child: Center(
                child: Text(
                  barcode,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.p20,
                      letterSpacing: 1.5,
                      color: AppColors.primaryText),
                ),
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
                  Get.back();
                  Get.back();
                  Get.toNamed(AppRoutes.productForm, arguments: {
                    'mode': 'create',
                    'barcode': barcode,
                  });
                },
                child: const Text('Thêm mới sản phẩm',
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
