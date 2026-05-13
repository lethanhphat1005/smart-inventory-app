import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

/// Action Confirm Card — phân biệt rõ 2 trạng thái resolved:
///   • isConfirmed = true  → banner xanh lá "Đã tạo phiếu thành công"
///   • isConfirmed = false → banner đỏ "Đã hủy phiếu"
/// Trước đây cả 2 trường hợp đều hiện cùng 1 dòng chữ xám mờ "Resolved".
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

    // ── Resolved state ──
    if (message.isResolved) {
      final wasConfirmed = message.data?['wasConfirmed'] as bool? ?? true;
      return _buildResolvedBanner(wasConfirmed: wasConfirmed, title: title);
    }

    // ── Active state ──
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.88),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: actionColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(actionIcon, color: actionColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: actionColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText,
                    height: 1.55,
                    fontFamily: 'Poppins',
                  ),
                  strong: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),
            Divider(height: 1, color: Colors.grey.shade100),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.cancelTransaction(message),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: Text(
                        TTexts.cancel.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        TTexts.confirm.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolvedBanner({
    required bool wasConfirmed,
    required String title,
  }) {
    final Color bgColor =
        wasConfirmed ? const Color(0xFFEAF3DE) : const Color(0xFFFCEBEB);
    final Color textColor =
        wasConfirmed ? const Color(0xFF3B6D11) : const Color(0xFFA32D2D);
    final IconData icon =
        wasConfirmed ? Iconsax.tick_circle : Iconsax.close_circle;
    final String label = wasConfirmed
        ? TTexts.chatbotTransactionConfirmedLabel.tr
        : TTexts.chatbotTransactionCancelledLabel.tr;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '$title — $label',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
