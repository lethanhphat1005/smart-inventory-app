import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:get/get.dart';

class ChatbotMessage extends StatelessWidget {
  final ChatMessage message;

  const ChatbotMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.82),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [
                    Color(0xFFB374B0), // Softened Purple
                    Color(0xFFF08D9B), // Softened Pink
                    Color(0xFFF8A875), // Softened Orange
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : const Color.fromARGB(255, 251, 251, 251),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: MarkdownBody(
          data: message.text,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              fontSize: 15,
              color: isUser ? Colors.white : AppColors.primaryText,
              height: 1.4,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
            ),
            strong: TextStyle(
              fontSize: 15,
              color: isUser ? Colors.white : AppColors.primaryText,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
            listBullet: TextStyle(
              color: isUser ? Colors.white : AppColors.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}
