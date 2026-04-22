import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/features/search/widgets/search_input_field_widget.dart';
import 'package:frontend/features/search/widgets/search_transaction_header_widget.dart'; // IMPORT WIDGET MỚI
import 'package:frontend/features/search/widgets/search_results_list_widget.dart';

class SearchMobileView extends GetView<TSearchController> {
  const SearchMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER DYNAMIC ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.primaryText, size: 20),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),

                  // TÁCH LUỒNG RÕ RÀNG Ở ĐÂY
                  Expanded(
                    child: Obx(() {
                      if (controller.isTransactionSearch) {
                        return const SearchTransactionHeaderWidget(); // Header cho Transaction
                      } else {
                        return const SearchInputFieldWidget(); // Thanh nhập liệu cho Product
                      }
                    }),
                  ),
                ],
              ),
            ),

            // --- BODY ---
            const Expanded(child: SearchResultsListWidget()),
          ],
        ),
      ),
    );
  }
}
