import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/routes/app_routes.dart';

class TBarcodePrefillBottomSheet {
  static void show({required String barcode, required Map<String, dynamic> prefill}) {
    final name = prefill['name'] ?? 'Chưa xác định';
    final brand = prefill['brand'] ?? 'Chưa xác định';

    TBottomSheetWidget.show(
      title: 'Sản phẩm mới',
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tìm thấy thông tin sản phẩm này trên mạng nhưng chưa có trong cửa hàng của bạn.',
              style: TextStyle(color: AppColors.subText, fontSize: AppSizes.p14, fontFamily: 'Poppins'),
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
                  Text('Mã vạch: $barcode', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  const SizedBox(height: AppSizes.p4),
                  Text('Tên: $name', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  const SizedBox(height: AppSizes.p4),
                  Text('Thương hiệu: $brand', style: const TextStyle(color: AppColors.subText)),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radius12)),
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                ),
                onPressed: () {
                  Get.back();
                  Get.back();
                  Get.toNamed(AppRoutes.productForm, arguments: {
                    'mode': 'create',
                    'freshName': name,
                    'freshBrand': brand,
                    'barcode': barcode,
                  });
                },
                child: const Text('Thêm vào cửa hàng', style: TextStyle(color: AppColors.whiteText, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}