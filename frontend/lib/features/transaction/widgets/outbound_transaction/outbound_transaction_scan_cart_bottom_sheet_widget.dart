import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';
import 'package:frontend/features/transaction/widgets/shared/transaction_cart_item_widget.dart';
import 'package:get/get.dart';

class OutboundScanCartBottomSheetWidget
    extends GetView<OutboundTransactionController> {
  const OutboundScanCartBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TBottomSheetWidget(
      child: Obx(() {
        if (controller.cartItems.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.softGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radius16),
              ),
              child: const Center(
                  child: Text("🛒", style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              TTexts.currentCart.tr,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.p24),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.45),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  // Tự động sử dụng giới hạn của Tồn Kho (isOutbound: true)
                  return TransactionCartItemWidget(
                    item: item,
                    isOutbound: true,
                    imageUrl: item.packageInfo?.product?.imageUrl,
                    showDeleteButton: true,
                    onIncrease: () =>
                        controller.updateQuantity(index, item.quantity + 1),
                    onDecrease: () =>
                        controller.updateQuantity(index, item.quantity - 1),
                    onQuantityChanged: (newQty) => controller
                        .updateItemQuantity(item.productPackageId!, newQty),
                    onDelete: () => controller.confirmRemoveItem(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${controller.totalItems} ${TTexts.labelItemsCount.tr}',
                        style: const TextStyle(
                            color: AppColors.subText, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(TTexts.subtotal.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                  ],
                ),
                Text('\$${controller.totalFunds.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryText,
                        fontSize: 20)),
              ],
            ),
            const SizedBox(height: 24),
            TPrimaryButtonWidget(
              text: TTexts.done.tr,
              onPressed: () => Get.back(),
              fontSize: 16.0,
            ),
          ],
        );
      }),
    );
  }
}
