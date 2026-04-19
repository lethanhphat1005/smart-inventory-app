import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatCardActionConfirm extends StatelessWidget {
  final ChatMessage message;

  const ChatCardActionConfirm({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatbotUiController>();
    final isImport =
        message.intent == 'confirm_import' || message.intent == 'create_import';

    // Màu sắc và Icon chủ đạo theo logic của các card mẫu
    final actionColor = isImport ? Colors.blue : Colors.orange;
    final actionIcon = isImport ? Iconsax.import_1 : Iconsax.export_1;
    final title = isImport ? "Xác nhận Nhập kho" : "Xác nhận Xuất kho";

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
          border: Border.all(color: actionColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: actionColor.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================== HEADER (Giống mẫu Low Stock) ==================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(actionIcon, color: actionColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: actionColor.shade800,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // ================== BODY: NỘI DUNG CHI TIẾT ==================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.primaryText,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ================== FOOTER: ACTIONS HOẶC STATUS ==================
            if (!message.isResolved) ...[
              const Divider(height: 1, color: AppColors.divider),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Nút Hủy - Style nhẹ nhàng
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          message.isResolved = true;
                          controller.messages.refresh();
                          controller.messages.add(ChatMessage(
                              text: "Đã hủy thao tác.", isUser: false));
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Hủy bỏ",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút Xác nhận - Style nổi bật giống Product Info footer
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.confirmTransaction(message),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Xác nhận",
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              )
            ] else ...[
              // Trạng thái đã xử lý - Giống mẫu ảnh bạn gửi nhưng trau chuốt hơn
              const Divider(height: 1, color: AppColors.divider),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.tick_circle,
                        color: Color(0xFF00C853), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Giao dịch đã được ghi nhận",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
