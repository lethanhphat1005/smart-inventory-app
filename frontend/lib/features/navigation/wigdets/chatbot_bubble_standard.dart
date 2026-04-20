import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // THÊM IMPORT NÀY
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:get/get.dart';

class ChatBubbleStandard extends StatelessWidget {
  final ChatMessage message;

  const ChatBubbleStandard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final textColor = isUser ? Colors.white : AppColors.primaryText;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 20),
          ),
          border: isUser
              ? null
              : Border.all(color: AppColors.divider.withOpacity(0.3)),
          boxShadow: isUser
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: MarkdownBody(
          data: message.text,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
                color: textColor,
                fontSize: 14.5,
                height: 1.5,
                fontWeight: FontWeight.w400),
            strong: TextStyle(
                color: textColor,
                fontSize: 14.5,
                height: 1.5,
                fontWeight: FontWeight.w700),
            listBullet:
                TextStyle(color: textColor), // Đổi màu dấu chấm đầu dòng
          ),
        ),
      ),
    );
  }
}
