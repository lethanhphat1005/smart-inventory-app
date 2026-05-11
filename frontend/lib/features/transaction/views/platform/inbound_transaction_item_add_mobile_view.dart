import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_item_add_controller.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_header_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_quantity_selector_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_product_info_widget.dart';
// IMPORT SHIMMER VÀ BARCODE MỚI TẠO
import 'package:frontend/features/transaction/widgets/shared/transaction_item_add_shimmer_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_barcode_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InboundTransactionItemAddMobileView
    extends GetView<InboundTransactionItemAddController> {
  const InboundTransactionItemAddMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoadingFreshData.value) {
          return const TransactionItemAddShimmerWidget();
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            TransactionHeaderWidget(
              imageUrl: controller.productImageUrl.isEmpty
                  ? null
                  : controller.productImageUrl,
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                transform: Matrix4.translationValues(0, -24, 0),
                child: Column(
                  children: [
                    const SizedBox(height: AppSizes.p40),
                    const TransactionProductInfoWidget(),
                    const SizedBox(height: AppSizes.p16),
                    const TransactionBarcodeWidget(),
                    const SizedBox(height: AppSizes.p8),
                    const _Divider(),
                    _buildSectionTitle(TTexts.details.tr),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p20, vertical: 8),
                      child: TransactionQuantitySelectorWidget(
                        controller: controller.quantityController,
                        onIncrease: controller.incrementQuantity,
                        onDecrease: controller.decrementQuantity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p20, vertical: 16),
                      child: TTextFormFieldWidget(
                        label: TTexts.importPriceLot.tr,
                        hintText: '0.00',
                        controller: controller.priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixIcon: Iconsax.money_send_copy,
                      ),
                    ),
                    const _Divider(),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(TTexts.subtotal.tr,
                              style: TextStyle(
                                  fontFamily: AppFonts.mainFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText)),
                          Text(
                              '\$${controller.totalPrice.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontFamily: AppFonts.mainFont,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // ẨN NÚT BOTTOM KHI ĐANG LOADING
      bottomNavigationBar: Obx(() => controller.isLoadingFreshData.value
          ? const SizedBox.shrink()
          : _buildBottomButton()),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText)),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 15, offset: Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: TPrimaryButtonWidget(
          text: TTexts.addToTransaction.tr,
          onPressed: () => controller.confirmAndAddToCart(),
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
          vertical: AppSizes.p16, horizontal: AppSizes.p20),
      child: Divider(color: AppColors.divider.withOpacity(0.6), height: 1),
    );
  }
}
