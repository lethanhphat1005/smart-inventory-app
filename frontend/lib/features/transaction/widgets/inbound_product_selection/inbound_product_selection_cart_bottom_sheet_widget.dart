import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/currency_formatter_utils.dart';
import 'package:frontend/core/infrastructure/utils/get_package_full_display_name.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/transaction/controllers/inbound_product_selection_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class InboundProductSelectionCartBottomSheetWidget
    extends GetView<InboundProductSelectionController> {
  const InboundProductSelectionCartBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TBottomSheetWidget(
      child: Obx(() {
        if (controller.draftCart.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
          return const SizedBox.shrink();
        }

        final cartKeys = controller.draftCart.keys.toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==========================================
            // HEADER CUSTOM XỊN XÒ TƯƠNG TỰ TRANSACTION_BOTTOM_SHEET
            // ==========================================
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.softGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radius16),
              ),
              child: const Center(
                  child: Text("📦", style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: AppSizes.p16),
            Text(
              TTexts.selectedItems.tr,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText),
              textAlign: TextAlign.center,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => controller.clearDraft(),
                icon:
                    const Icon(Iconsax.trash_copy, size: 16, color: Colors.red),
                label: Text(TTexts.clearAll.tr,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),

            // Giới hạn chiều cao cụ thể (45% màn hình) để List có thể tự vuốt trượt nếu số lượng nhiều.
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: Get.height * 0.45),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: cartKeys.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pkgId = cartKeys[index];
                  final qty = controller.draftCart[pkgId]!;
                  final inventory = controller.draftCartModels[pkgId]!;

                  // final name =
                  //     inventory.productPackage?.displayName ?? 'Hàng hóa';
                  final name = DisplayNameUtils.getFullPackageDisplayName(
                      inventory.productPackage);
                  final price = inventory.productPackage?.importPrice ?? 0.0;
                  final imageUrl = inventory.productPackage?.product?.imageUrl;

                  final bool isMaxed = qty >= 999999;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMaxed
                            ? Colors.red.shade400
                            : AppColors.divider.withOpacity(0.5),
                        width: isMaxed ? 1.2 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: isMaxed
                                ? Colors.red.withOpacity(0.05)
                                : Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 46,
                            height: 46,
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: UrlHelperUtils.normalizeImageUrl(
                                        imageUrl)!,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        const TNoImageWidget(
                                            width: 46,
                                            height: 46,
                                            borderRadius: 10),
                                  )
                                : const TNoImageWidget(
                                    width: 46, height: 46, borderRadius: 10),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(CurrencyFormatterUtils.formatFull(price),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBtn(
                                  Icons.remove,
                                  () => controller.decreaseItem(inventory),
                                  AppColors.primaryText),
                              Container(
                                constraints: const BoxConstraints(minWidth: 46),
                                alignment: Alignment.center,
                                child: Text('$qty',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isMaxed
                                            ? Colors.red
                                            : AppColors.primaryText)),
                              ),
                              _buildBtn(
                                  Icons.add,
                                  isMaxed
                                      ? null
                                      : () =>
                                          controller.increaseItem(inventory),
                                  isMaxed
                                      ? AppColors.softGrey
                                      : AppColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ==========================================
            // FOOTER: TỔNG KẾT & XÁC NHẬN
            // ==========================================
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
                        '${controller.totalDraftItems} ${TTexts.labelItemsCount.tr}',
                        style: const TextStyle(
                            color: AppColors.subText, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(TTexts.subtotal.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                  ],
                ),
                Text(
                    CurrencyFormatterUtils.formatFull(
                        controller.totalDraftPrice),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryText,
                        fontSize: 20)),
              ],
            ),
            const SizedBox(height: 24),

            TPrimaryButtonWidget(
              text: TTexts.done.tr,
              onPressed: () => controller.confirmAndAddToMainCart(),
              fontSize: 16.0,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBtn(IconData icon, VoidCallback? onTap, Color iconColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(icon, size: 14, color: iconColor),
      ),
    );
  }
}
