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
    final isImport = message.intent == 'confirm_import';
    final actionColor = isImport ? Colors.blueAccent : Colors.orangeAccent;

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
          border: Border.all(color: AppColors.divider.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: actionColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isImport ? Iconsax.arrow_down_2 : Iconsax.arrow_up_2, color: actionColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isImport ? "Xác nhận Nhập kho" : "Xác nhận Xuất kho",
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primaryText),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message.text,
                style: const TextStyle(fontSize: 14.5, color: AppColors.primaryText, height: 1.4),
              ),
            ),
            if (!message.isResolved)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          message.isResolved = true;
                          controller.messages.refresh();
                          controller.messages.add(ChatMessage(text: "Đã hủy thao tác.", isUser: false));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: AppColors.primaryText,
                          side: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Hủy bỏ", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.confirmTransaction(message),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.6),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.tick_circle, color: Colors.grey.shade400, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Giao dịch đã được xử lý",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}