import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class InventoryBarcodeListBottomSheetWidget extends StatelessWidget {
  final ProductPackageModel package;

  const InventoryBarcodeListBottomSheetWidget(
      {super.key, required this.package});

  // Chuyển đổi source thô thành text thân thiện
  String _getFriendlySource(String source) {
    switch (source.toLowerCase()) {
      case 'user_confirmed':
        return 'Xác nhận bởi người dùng';
      case 'seed':
        return 'Dữ liệu mẫu (Hệ thống)';
      case 'admin':
        return 'Thêm bởi Quản trị viên';
      case 'barcode_flow_create':
        return 'Tạo từ luồng quét mã';
      case 'api_import':
        return 'Nhập từ API (Hệ thống ngoài)';
      default:
        return 'Khác';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Icon Header
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.softGrey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppSizes.radius16),
            border: Border.all(
              color: AppColors.softGrey.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Text(
              "🤳",
              style: TextStyle(fontSize: 36),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p16),

        // 2. Title
        const Text(
          'Danh sách mã vạch',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: AppSizes.p8),

        // 3. Subtitle
        Text(
          'Sản phẩm: ${package.displayName}',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.subText,
            height: 1.5,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: AppSizes.p24),

        // 4. Danh sách các mã vạch
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.45,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: package.barcodes.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.p12),
            itemBuilder: (context, index) {
              final barcodeItem = package.barcodes[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.barcode_copy,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                barcodeItem.barcode,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              if (barcodeItem.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Iconsax.verify_copy,
                                    color: Colors.green, size: 16),
                              ]
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nguồn: ${_getFriendlySource(barcodeItem.source)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.softGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSizes.p16),
      ],
    );
  }
}
