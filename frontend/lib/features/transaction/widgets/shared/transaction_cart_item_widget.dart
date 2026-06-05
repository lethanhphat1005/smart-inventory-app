import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/infrastructure/utils/currency_formatter_utils.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TransactionCartItemWidget extends StatefulWidget {
  final TransactionDetailModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final Function(int)? onQuantityChanged;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isOutbound;
  final String? imageUrl;
  final String? stockBadgeText;
  final Color? stockBadgeColor;
  final bool showDeleteButton;

  const TransactionCartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    this.onQuantityChanged,
    this.onTap,
    this.onDelete,
    this.isOutbound = false,
    this.imageUrl,
    this.stockBadgeText,
    this.stockBadgeColor,
    this.showDeleteButton = false,
  });

  @override
  State<TransactionCartItemWidget> createState() =>
      _TransactionCartItemWidgetState();
}

class _TransactionCartItemWidgetState extends State<TransactionCartItemWidget> {
  late TextEditingController _qtyController;
  final FocusNode _focusNode = FocusNode();

  // Ngưỡng tối đa: Số lượng tồn kho (Nếu xuất kho) hoặc 999,999 (Nếu nhập kho)
  int get _maxAllowed => widget.isOutbound ? widget.item.currentStock : 999999;

  @override
  void initState() {
    super.initState();
    _qtyController =
        TextEditingController(text: widget.item.quantity.toString());

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _submitQuantity();
      }
    });
  }

  @override
  void didUpdateWidget(covariant TransactionCartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity) {
      final currentTextQty = int.tryParse(_qtyController.text) ?? 0;
      if (currentTextQty != widget.item.quantity) {
        final previousSelection = _qtyController.selection;
        final newText = widget.item.quantity.toString();
        _qtyController.text = newText;

        if (_focusNode.hasFocus) {
          int offset = previousSelection.baseOffset;
          if (offset > newText.length) offset = newText.length;
          if (offset < 0) offset = 0;
          _qtyController.selection =
              TextSelection.fromPosition(TextPosition(offset: offset));
        }
      }
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChanged(String value) {
    if (value.isEmpty) {
      widget.onQuantityChanged?.call(0);
      return;
    }

    int newQty = int.tryParse(value) ?? 0;

    // Tự động ép về số lớn nhất và kích hoạt trạng thái "Max" nếu cố tình gõ lố
    if (newQty >= _maxAllowed) {
      newQty = _maxAllowed;
      _qtyController.text = newQty.toString();
      _qtyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyController.text.length));
    }

    if (newQty >= 0) {
      widget.onQuantityChanged?.call(newQty);
    }
  }

  void _submitQuantity() {
    if (_qtyController.text.isEmpty) {
      _qtyController.text = '0';
      widget.onQuantityChanged?.call(0);
      return;
    }
    _onInputChanged(_qtyController.text);
  }

  @override
  Widget build(BuildContext context) {
    final String rawId = widget.item.productPackageId ?? '';
    final String displayId = rawId.length > 5 ? rawId.substring(0, 5) : rawId;

    final name = widget.item.packageInfo?.displayName ??
        '${TTexts.product.tr} #${displayId.isEmpty ? TTexts.labelNoBarcode.tr : displayId}';
    final bool canIncrease = widget.item.quantity < _maxAllowed;
    final bool canDecrease = widget.item.quantity > 0;
    final bool hasImage =
        widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _qtyController,
        builder: (context, value, childRow) {
          final current = int.tryParse(value.text) ?? 0;

          // Trạng thái đạt giới hạn (isMaxed) chỉ được bật khi chạm đúng ngưỡng trần
          final bool isMaxed = current >= _maxAllowed;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: widget.onTap ??
                    () {
                      final packageId = widget.item.productPackageId;
                      if (packageId != null && packageId.isNotEmpty) {
                        final inventory = InventoryModel(
                          inventoryId: '',
                          quantity: widget.item.currentStock,
                          reorderThreshold: widget.item.reorderThreshold,
                          lastCount: 0,
                          updatedAt: DateTime.now(),
                          productPackageId: packageId,
                          activeStatus: 'active',
                          productPackage: widget.item.packageInfo,
                        );
                        final displayItem = InventoryInsightDisplayModel(
                          product: widget.item.packageInfo?.product,
                          inventory: inventory,
                        );
                        final routeName = widget.isOutbound
                            ? AppRoutes.outboundTransactionItemAdd
                            : AppRoutes.inboundTransactionItemAdd;
                        Get.toNamed(routeName, arguments: {
                          'displayItem': displayItem,
                          'quantity': widget.item.quantity,
                          'isEditing': true
                        });
                      }
                    },
                onLongPress: widget.onDelete,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: isMaxed
                              ? Colors.red.withOpacity(0.1)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 4)),
                    ],
                    border: Border.all(
                        color: isMaxed
                            ? Colors.red.shade400
                            : (widget.item.quantity > 0)
                                ? AppColors.primary.withOpacity(0.2)
                                : Colors.transparent,
                        width: 1.0),
                  ),
                  child: childRow,
                ),
              ),

              // Hiện cảnh báo nếu chạm ngưỡng
              if (isMaxed)
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 4),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.red, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          // Sử dụng Locale chuẩn của bạn để phân biệt 2 thông báo
                          widget.isOutbound
                              ? TTexts.maxStockReached.tr
                              : TTexts.absoluteMaxQuantity.tr,
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasImage
                        ? CachedNetworkImage(
                            imageUrl: UrlHelperUtils.normalizeImageUrl(
                                widget.imageUrl!)!,
                            fit: BoxFit.cover)
                        : const TNoImageWidget(
                            width: 76, height: 76, borderRadius: 12),
                    if (widget.stockBadgeText != null && hasImage)
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                        child: Container(color: Colors.black.withOpacity(0.1)),
                      ),
                    if (widget.stockBadgeText != null)
                      Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: widget.stockBadgeColor ?? Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.stockBadgeText!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.primaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (widget.showDeleteButton &&
                          widget.onDelete != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: widget.onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.divider),
                              color: AppColors.background,
                            ),
                            child: const Icon(
                              Iconsax.trash_copy,
                              size: 16,
                              color: AppColors.stockOut,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.box_copy,
                          size: 14, color: AppColors.subText),
                      const SizedBox(width: 6),
                      Text(
                          '${TTexts.labelStock.tr}: ${widget.item.currentStock}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.subText,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(() => Text(
                                CurrencyFormatterUtils.formatFull(
                                    widget.item.unitPrice),
                                style: TextStyle(
                                  fontFamily: AppFonts.mainFont,
                                  fontSize: 13,
                                  color: AppColors.subText,
                                ),
                              )),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2))
                                  ]),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildQtyBtn(
                                      icon: Icons.remove,
                                      onTap: canDecrease
                                          ? widget.onDecrease
                                          : null,
                                      color: canDecrease
                                          ? AppColors.primaryText
                                          : AppColors.softGrey),

                                  // Nới rộng bề ngang lên 76px để chữ 999999 không bị cắt xén!
                                  SizedBox(
                                    width: 76,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        textSelectionTheme:
                                            TextSelectionThemeData(
                                          cursorColor: AppColors.primary,
                                          selectionColor: AppColors.primary
                                              .withOpacity(0.3),
                                          selectionHandleColor:
                                              AppColors.primary,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _qtyController,
                                        focusNode: _focusNode,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        showCursor: true,
                                        cursorColor: AppColors.primary,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        onChanged: _onInputChanged,
                                        onFieldSubmitted: (_) =>
                                            _submitQuantity(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  _buildQtyBtn(
                                      icon: Icons.add,
                                      onTap: canIncrease
                                          ? widget.onIncrease
                                          : null,
                                      color: canIncrease
                                          ? AppColors.primaryText
                                          : AppColors.softGrey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(
      {required IconData icon, VoidCallback? onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(icon, size: 16, color: color)),
    );
  }
}
