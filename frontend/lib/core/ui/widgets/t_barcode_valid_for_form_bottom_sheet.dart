import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:get/get.dart';

class TBarcodeValidForFormBottomSheet {
  static void show({required String barcode, Map<String, dynamic>? prefill}) {
    TBottomSheetWidget.show(
      title: 'Mã vạch hợp lệ',
      child: Column(
        children: [
          const Text(
              'Mã vạch này chưa có trong hệ thống và có thể sử dụng cho sản phẩm này.'),
          const SizedBox(height: 16),
          Text(barcode,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.primary)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Điền vào controller của ProductForm
                final formCtrl = Get.find<ProductFormController>();
                formCtrl.barcodeController.text = barcode;
                if (prefill != null) {
                  if (formCtrl.nameController.text.isEmpty) {
                    formCtrl.nameController.text = prefill['name'] ?? '';
                  }
                  if (formCtrl.brandController.text.isEmpty) {
                    formCtrl.brandController.text = prefill['brand'] ?? '';
                  }
                }
                Get.back(); // Đóng Bottom Sheet
                Get.back(); // Đóng Scanner
              },
              child: const Text('Xác nhận sử dụng mã này'),
            ),
          )
        ],
      ),
    );
  }
}
