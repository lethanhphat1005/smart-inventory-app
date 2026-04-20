import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatCardChooseProduct extends StatelessWidget {
  final ChatMessage message;

  const ChatCardChooseProduct({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final data = message.data;
    if (data == null || data['items'] == null) return const SizedBox.shrink();

    final List<dynamic> items = data['items'];
    final controller = Get.find<ChatbotUiController>();

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
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.task_square,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Danh sách sản phẩm cho phép click
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = items[index];
                final pkg = item['productPackage'];
                final displayName = pkg?['displayName'] ?? 'Không tên';
                final stock = item['quantity'] ?? 0;
                final unit = pkg?['unit']?['name'] ?? '';

                return InkWell(
                  onTap: () {
                    if (message.isResolved) return; // Tránh bấm nhiều lần

                    final originalIntent = data[
                        'originalIntent']; // 'create_import' hoặc 'create_export'
                    final quantity = data['quantity'] ?? 1;

                    // Ghép thành câu lệnh hoàn chỉnh
                    String command = "";
                    if (originalIntent == 'get_product_info') {
                      command =
                          "Xem thông tin chính xác sản phẩm \"$displayName\"";
                    } else if (originalIntent == 'create_import') {
                      command =
                          "Yêu cầu nhập $quantity sản phẩm mang tên chính xác là \"$displayName\"";
                    } else if (originalIntent == 'create_export') {
                      command =
                          "Yêu cầu xuất $quantity sản phẩm mang tên chính xác là \"$displayName\"";
                    }

                    // Vô hiệu hóa thẻ này
                    message.isResolved = true;
                    controller.messages.refresh();

                    // Đưa câu lệnh lên ô nhập và tự động gửi
                    controller.textController.text = command;
                    controller.sendMessage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Iconsax.box,
                              size: 20, color: AppColors.subText),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: message.isResolved
                                      ? Colors.grey
                                      : AppColors.primaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Tồn kho: $stock $unit",
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.subText),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: 18,
                          color: message.isResolved
                              ? Colors.grey.shade300
                              : AppColors.primary,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
