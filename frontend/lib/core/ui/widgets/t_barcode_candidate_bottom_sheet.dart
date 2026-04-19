import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/routes/app_routes.dart';

class TBarcodeCandidateBottomSheet {
  static void show(
      {required String barcode,
      required List<dynamic> candidates,
      required Map<String, dynamic> prefill}) {
    final InventoryProvider provider = InventoryProvider();

    TBottomSheetWidget.show(
      title: 'Sản phẩm tương tự',
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hệ thống tìm thấy sản phẩm có thể khớp với mã vạch này. Chọn một sản phẩm để gán mã, hoặc tạo mới.',
              style: TextStyle(
                  color: AppColors.subText,
                  fontSize: AppSizes.p14,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: AppSizes.p16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.4),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: candidates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final candidate = candidates[index]['productPackage'];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(AppSizes.radius8),
                    ),
                    child: ListTile(
                      title: Text(candidate['displayName'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              fontSize: 14)),
                      subtitle: Text('Giá: ${candidate['sellingPrice']} đ',
                          style: const TextStyle(color: AppColors.primary)),
                      trailing:
                          const Icon(Icons.link, color: AppColors.subText),
                      onTap: () async {
                        Get.back(); // Đóng Bottom Sheet
                        FullScreenLoaderUtils.openLoadingDialog(
                            'Đang liên kết mã vạch...');
                        try {
                          await provider.confirmBarcodeMapping(
                            barcode: barcode,
                            productPackageId: candidate['productPackageId'],
                          );
                          FullScreenLoaderUtils.stopLoading();
                          Get.back(); // Đóng màn Scanner

                          Get.toNamed(AppRoutes.inventoryDetail, arguments: {
                            'packageId': candidate['productPackageId'],
                            'package': candidate,
                          });
                          TSnackbarsWidget.success(
                              title: 'Thành công',
                              message: 'Đã liên kết mã vạch với sản phẩm này.');
                        } catch (e) {
                          FullScreenLoaderUtils.stopLoading();
                          TSnackbarsWidget.error(
                              title: 'Lỗi',
                              message:
                                  'Mã vạch bị trùng hoặc kẹt ở sản phẩm khác.');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius12)),
                ),
                onPressed: () {
                  Get.back();
                  Get.back();
                  Get.toNamed(AppRoutes.productForm, arguments: {
                    'mode': 'create',
                    'barcode': barcode,
                    'freshName': prefill['name'],
                    'freshBrand': prefill['brand'],
                  });
                },
                child: const Text('Tạo sản phẩm mới hoàn toàn',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
