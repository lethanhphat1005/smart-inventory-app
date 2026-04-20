import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatCardProductInfo extends StatelessWidget {
  final ChatMessage message;

  const ChatCardProductInfo({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final data = message.data;
    if (data == null) return const SizedBox.shrink();

    // Tương thích với cách backend bọc data mới
    final dynamic item = data is Map && data.containsKey('productPackage')
        ? data
        : (data['data'] ?? data);

    if (item == null || item['productPackage'] == null) {
      return const SizedBox.shrink();
    }

    final pkg = item['productPackage'];
    final displayName = pkg['displayName'] ?? 'Sản phẩm không xác định';
    final quantity = item['quantity'] ?? 0;
    final unitName = pkg['unit']?['name'] ?? '';

    // Format giá tiền cho đẹp (ví dụ: 15,000)
    final formatCurrency = NumberFormat.decimalPattern('vi_VN');
    final sellingPrice = formatCurrency
        .format(num.tryParse(pkg['sellingPrice'].toString()) ?? 0);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.85),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================== BODY: THÔNG TIN SẢN PHẨM ==================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Ảnh Sản Phẩm
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.15)),
                    ),
                    child: const Icon(Iconsax.box_1,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),

                  // Chi tiết chữ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 15.5,
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Giá Bán Nổi Bật
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              sellingPrice,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00C853), // Xanh lá cây nổi bật
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "VNĐ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00C853),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // ================== BADGES: TỒN KHO & ĐƠN VỊ ==================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Badge Tồn Kho
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: quantity > 0
                          ? Colors.blue.withOpacity(0.08)
                          : Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: quantity > 0
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          quantity > 0
                              ? Iconsax.tick_circle
                              : Iconsax.close_circle,
                          size: 14,
                          color: quantity > 0
                              ? Colors.blue.shade700
                              : Colors.red.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          quantity > 0
                              ? "Còn hàng ($quantity)"
                              : "Hết hàng (0)",
                          style: TextStyle(
                            color: quantity > 0
                                ? Colors.blue.shade700
                                : Colors.red.shade700,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Badge Đơn Vị
                  if (unitName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "Đvt: $unitName",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ================== FOOTER: XEM CHI TIẾT ==================
            const Divider(height: 1, color: AppColors.divider),
            InkWell(
              onTap: () {
                // TODO: Chuyển hướng sang trang chi tiết sản phẩm nếu có
                // Get.toNamed('/product-detail', arguments: pkg['productPackageId']);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Xem chi tiết",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Iconsax.arrow_right_3,
                        size: 16, color: AppColors.primary.withOpacity(0.8)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
