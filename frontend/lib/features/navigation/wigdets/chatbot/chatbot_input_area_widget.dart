import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_input_action_menu_widget.dart'; // Import Menu mới
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatbotInputAreaWidget extends StatelessWidget {
  const ChatbotInputAreaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatbotUiController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12), // Giảm margin ngang một xíu
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1. NÚT 3 CHẤM BÊN TRÁI
              const ChatbotInputActionMenuWidget(),
              const SizedBox(width: 4),

              // 2. Ô NHẬP TEXT
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: AppColors.divider.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: controller.textController,
                    focusNode: controller.focusNode,
                    maxLines: 4,
                    minLines: 1,
                    cursorColor:
                        const Color(0xFFF08D9B), // Màu nháy chuột khớp gradient
                    textInputAction: TextInputAction.send,
                    style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                    onSubmitted: (_) => controller.sendMessage(),
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(
                          color: AppColors.subText,
                          fontSize: 13,
                          fontFamily: 'Poppins'),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 3. NÚT SEND GRADIENT MỚI
              GestureDetector(
                onTap: controller.sendMessage,
                child: Container(
                  height: 48,
                  width: 48,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFB374B0),
                        Color(0xFFF08D9B),
                        Color(0xFFF8A875),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF08D9B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Iconsax.send_1_copy,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
