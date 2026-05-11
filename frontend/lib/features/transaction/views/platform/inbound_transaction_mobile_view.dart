import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_search_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_controller.dart';
import 'package:frontend/features/transaction/widgets/inbound_transaction/inbound_transaction_bottom_bar_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_cart_item_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_empty_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InboundTransactionMobileView
    extends GetView<InboundTransactionController> {
  const InboundTransactionMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.handleExit();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: TAppBarWidget(
            title: TTexts.inboundTransaction.tr,
            onBackPress: controller.handleExit,
          ),
          body: Column(
            children: [
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.p20, 8, AppSizes.p20, AppSizes.p16),
                child: TSearchBarWidget(
                  hintText: TTexts.searchProductToAdd.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.search,
                        arguments: AppRoutes.inboundTransaction);
                  },
                  onScanTap: controller.openScanner,
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.cartItems.isEmpty) {
                    // ĐÃ SỬA: Xóa params để tránh lỗi báo đỏ Widget
                    return const TransactionEmptyWidget();
                  }

                  return ListView(
                    padding: const EdgeInsets.all(AppSizes.p20),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.cartItems[index];

                          return TransactionCartItemWidget(
                            item: item,
                            isOutbound: false,
                            imageUrl: item.packageInfo?.product?.imageUrl,
                            onIncrease: () => controller.updateQuantity(
                                index, item.quantity + 1),
                            onDecrease: () => controller.updateQuantity(
                                index, item.quantity - 1),
                            onQuantityChanged: (newQty) {
                              controller.updateItemQuantity(
                                  item.productPackageId!, newQty);
                            },
                          );
                        },
                      ),
                      _buildNoteSection(),
                    ],
                  );
                }),
              ),
            ],
          ),
          bottomNavigationBar: const InboundTransactionBottomBarWidget(),
        ));
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0, AppSizes.p24, 0, 16),
          child: Divider(color: AppColors.divider),
        ),
        TTextFormFieldWidget(
          label: TTexts.noteLabel.tr,
          controller: controller.noteController,
          hintText: TTexts.noteHint.tr,
          maxLines: 3,
          prefixIcon: Iconsax.document_text_copy,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
