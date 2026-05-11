import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/infrastructure/utils/url_helper_utils.dart';
import 'package:frontend/core/ui/widgets/t_no_image_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/features/inventory/models/inventory_insight_display_model.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';

class TransactionCartItemWidget extends StatefulWidget {
  final TransactionDetailModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final Function(int)? onQuantityChanged;
  final VoidCallback? onDelete;
  final bool isOutbound;
  final String? imageUrl;

  const TransactionCartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    this.onQuantityChanged,
    this.onDelete,
    this.isOutbound = false,
    this.imageUrl,
  });

  @override
  State<TransactionCartItemWidget> createState() =>
      _TransactionCartItemWidgetState();
}

class _TransactionCartItemWidgetState extends State<TransactionCartItemWidget> {
  late TextEditingController _qtyController;
  final FocusNode _focusNode = FocusNode();

  // Khai báo giới hạn tối đa
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
    if (oldWidget.item.quantity != widget.item.quantity &&
        !_focusNode.hasFocus) {
      _qtyController.text = widget.item.quantity.toString();
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChanged(String value) {
    if (value.isEmpty) return;

    int newQty = int.tryParse(value) ?? 1;

    // Chặn không cho nhập lố giới hạn
    if (newQty >= _maxAllowed) {
      newQty = _maxAllowed;
      _qtyController.text = newQty.toString();
      _qtyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyController.text.length));
    }

    // Giới hạn cho chiều Outbound
    if (widget.isOutbound && newQty > widget.item.currentStock) {
      newQty = widget.item.currentStock;
      _qtyController.text = newQty.toString();
      _qtyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyController.text.length));
    }

    // Nếu gõ số > 0 thì lập tức update lên Controller
    if (newQty > 0) {
      widget.onQuantityChanged?.call(newQty);
    }
  }

  void _submitQuantity() {
    if (_qtyController.text.isEmpty || _qtyController.text == '0') {
      _qtyController.text = '1';
      widget.onQuantityChanged?.call(1);
      return;
    }
    _onInputChanged(_qtyController.text);
  }

  // --- XỬ LÝ NÚT + / - DỰA TRÊN SỐ ĐANG GÕ ---
  void _internalDecrement() {
    int current = int.tryParse(_qtyController.text) ?? 1;
    int newQty = current - 1;
    if (newQty < 1) newQty = 1;

    _qtyController.text = newQty.toString();
    widget.onQuantityChanged?.call(newQty);
  }

  void _internalIncrement() {
    int current = int.tryParse(_qtyController.text) ?? 0;
    int newQty = current + 1;

    if (newQty >= _maxAllowed) newQty = _maxAllowed;

    _qtyController.text = newQty.toString();
    widget.onQuantityChanged?.call(newQty);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.item.packageInfo?.displayName ??
        '${TTexts.product.tr} #${widget.item.productPackageId?.substring(0, 5) ?? TTexts.labelNoBarcode.tr}';

    final category = widget.item.packageInfo?.product?.categoryName ??
        TTexts.uncategorized.tr;
    final price = widget.item.unitPrice.toStringAsFixed(2);

    // Nút cộng chỉ vô hiệu hóa nếu chạm ngưỡng thực sự
    final bool canIncrease = widget.item.quantity < _maxAllowed;

    return GestureDetector(
      onTap: () {
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
            'isEditing': true,
          });
        }
      },
      onLongPress: widget.onDelete,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: AppColors.background,
                child: (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl:
                            UrlHelperUtils.normalizeImageUrl(widget.imageUrl) ??
                                '',
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) =>
                            const TNoImageWidget(
                                width: 76, height: 76, borderRadius: 16),
                      )
                    : const TNoImageWidget(
                        width: 76, height: 76, borderRadius: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.primaryText),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(category,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.subText)),

                  const SizedBox(height: 12),

                  // Bọc Column để chứa giá trị và Dòng cảnh báo bên dưới
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$$price',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText)),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 38,
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
                                      onTap: _internalDecrement,
                                      color: AppColors.primaryText),
                                  IntrinsicWidth(
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          minWidth: 30, maxWidth: 100),
                                      alignment: Alignment.center,
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
                                          LengthLimitingTextInputFormatter(
                                              6), // CHẶN NHẬP QUÁ 6 KÝ TỰ (999.999)
                                        ],
                                        onChanged: _onInputChanged,
                                        onFieldSubmitted: (_) =>
                                            _submitQuantity(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
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
                                          ? _internalIncrement
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

                      // HIỂN THỊ CẢNH BÁO KHI CHẠM NGƯỠNG
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _qtyController,
                        builder: (context, value, child) {
                          final current = int.tryParse(value.text) ?? 1;
                          if (current >= _maxAllowed) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                widget.isOutbound
                                    ? TTexts.maxStockReached.tr
                                    : TTexts.maxQuantityReached.tr,
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
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
