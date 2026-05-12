import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_search_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/features/transaction/controllers/inbound_transaction_controller.dart';
import 'package:frontend/features/transaction/widgets/inbound_transaction/inbound_transaction_bottom_bar_widget.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_add_more_card_widget.dart';
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
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.p20),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 1. NÚT "THÊM NHANH" - LUÔN LUÔN HIỂN THỊ Ở ĐẦU DANH SÁCH
                    TransactionAddMoreCardWidget(
                      onTap: () {
                        Get.toNamed(AppRoutes.inboundProductSelection);
                      },
                    ),

                    // 2. KHU VỰC HIỂN THỊ GIỎ HÀNG HOẠT EMPTY STATE
                    Obx(() {
                      if (controller.cartItems.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: TransactionEmptyWidget(),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                showDeleteButton: true,
                                onIncrease: () => controller.updateQuantity(
                                    index, item.quantity + 1),
                                onDecrease: () => controller.updateQuantity(
                                    index, item.quantity - 1),
                                onQuantityChanged: (newQty) {
                                  controller.updateItemQuantity(
                                      item.productPackageId!, newQty);
                                },
                                onDelete: () =>
                                    controller.confirmRemoveItem(index),
                              );
                            },
                          ),

                          // Hiển thị khung ghi chú bên dưới giỏ hàng
                          _buildNoteSection(),
                        ],
                      );
                    }),
                  ],
                ),
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
