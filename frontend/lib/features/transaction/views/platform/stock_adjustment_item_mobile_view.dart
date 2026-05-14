import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_quantity_selector_widget.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_item_controller.dart';
import 'package:frontend/features/transaction/widgets/stock_adjustment_item/stock_adjustment_item_reason_chips_widget.dart';
import 'package:frontend/features/transaction/widgets/stock_adjustment_item/stock_adjustment_item_summary_widget.dart';
import 'package:frontend/features/transaction/widgets/stock_adjustment_item/stock_adjustment_item_header_widget.dart';
import 'package:get/get.dart';

class StockAdjustmentItemMobileView
    extends GetView<StockAdjustmentItemController> {
  const StockAdjustmentItemMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TAppBarWidget(
        title: TTexts.checkComplete.tr,
        showBackArrow: true,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER CHỨA THÔNG TIN SẢN PHẨM
              Padding(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: StockAdjustmentItemHeaderWidget(item: controller.item),
              ),

              // 2. KHỐI NHẬP SỐ LƯỢNG THỰC TẾ (Đã gỡ bỏ Title và Text Actual dư thừa)
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p24),
                child: Center(
                  child: TransactionQuantitySelectorWidget(
                    controller: controller.actualQtyController,
                    onDecrease: controller.decrementActualQty,
                    onIncrease: controller.incrementActualQty,
                    isUnlimited: true,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. KHỐI LÝ DO LỆCH
              const StockAdjustmentItemReasonChipsWidget(),

              const SizedBox(height: 24),

              // 4. KHỐI GHI CHÚ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                child: TTextFormFieldWidget(
                  label: TTexts.noteLabel.tr,
                  hintText: TTexts.specificNoteHint.tr,
                  controller: controller.tempNoteController,
                  maxLines: 3,
                  prefixIcon: Icons.edit_note_rounded,
                ),
              ),

              const SizedBox(height: 32),

              // 5. KHỐI TỔNG HỢP SUMMARY
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
                child: StockAdjustmentItemSummaryWidget(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: TPrimaryButtonWidget(
            text: TTexts.checkComplete.tr,
            backgroundColor: Colors.orange,
            onPressed: controller.confirmItemAdjustment,
          ),
        ),
      ),
    );
  }
}
