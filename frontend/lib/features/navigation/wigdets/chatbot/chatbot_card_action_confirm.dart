import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
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

    final actionColor = isImport ? AppColors.stockIn : AppColors.stockOut;
    final actionIcon = isImport ? Iconsax.import_1 : Iconsax.export_1;
    final title = isImport
        ? TTexts.chatbotConfirmImport.tr
        : TTexts.chatbotConfirmExport.tr;

    // HIỂN THỊ KẾT QUẢ SAU KHI RESOLVED
    if (message.isResolved) {
      // Giả sử logic lưu trạng thái hủy trong data: message.data['isCancelled'] == true
      final isCancelled = message.data?['isCancelled'] == true;

      if (isCancelled) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFFCEBEB),
                borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.close_circle, color: Color(0xFFA32D2D), size: 18),
                SizedBox(width: 8),
                Text("Đã hủy phiếu",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFA32D2D),
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
        );
      } else {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFEAF3DE),
                borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.tick_circle, color: Color(0xFF3B6D11), size: 18),
                SizedBox(width: 8),
                Text("Đã tạo phiếu thành công",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B6D11),
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
        );
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.85),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: actionColor.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: Icon(actionIcon, color: actionColor, size: 18)),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        color: actionColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
              ],
            ),
            const SizedBox(height: 12),
            MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText,
                    height: 1.5,
                    fontFamily: 'Poppins'),
                strong: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.cancelTransaction(message);
                    },
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        foregroundColor: Colors.grey.shade700),
                    child: Text(TTexts.cancel.tr,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.confirmTransaction(message),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: actionColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: Text(TTexts.confirm.tr,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins')),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
