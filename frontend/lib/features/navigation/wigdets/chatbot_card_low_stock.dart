import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatCardLowStock extends StatelessWidget {
  final ChatMessage message;

  const ChatCardLowStock({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = [];
    int totalCount = 0;

    // Phân tách dữ liệu lấy từ data mới trả về của Backend
    if (message.data is List) {
      items = message.data as List<dynamic>;
      totalCount = items.length;
    } else if (message.data is Map) {
      final rawData = message.data as Map<String, dynamic>;
      items = (rawData['items'] ?? rawData['data'] ?? []) as List<dynamic>;
      totalCount = rawData['totalCount'] ?? items.length;
    }

    // Nếu không có dữ liệu thì trả về bong bóng text mặc định
    if (items.isEmpty && totalCount == 0) {
      return _buildFallbackBubble(message.text);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.88),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(color: Colors.orange.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.warning_2, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Chú ý: Có $totalCount mặt hàng sắp hết", // Cập nhật số lượng
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // ================= BODY: DANH SÁCH RÚT GỌN =================
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                      height: 1, color: AppColors.divider.withOpacity(0.4)),
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final pkg = item['productPackage'];
                  final displayName =
                      pkg?['displayName'] ?? 'Sản phẩm không xác định';
                  final quantity = item['quantity'] ?? 0;
                  final unitName = pkg?['unit']?['name'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.15)),
                          ),
                          child: Text(
                            "Còn: $quantity $unitName".trim(),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ================= FOOTER: NÚT XEM CHI TIẾT =================
            const Divider(height: 1, color: AppColors.divider),
            InkWell(
              onTap: () {
                // TODO: Open comment
                // Get.toNamed(AppRoutes.lowStock);
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
                    Text(
                      "Xem chi tiết toàn bộ $totalCount mặt hàng", // Cập nhật số lượng
                      style: const TextStyle(
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

  Widget _buildFallbackBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(color: Colors.orange.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
