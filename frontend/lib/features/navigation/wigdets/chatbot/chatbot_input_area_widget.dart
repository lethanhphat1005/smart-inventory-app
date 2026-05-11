import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/wigdets/chatbot/chatbot_input_action_menu_widget.dart';
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
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          // Dùng Obx để lắng nghe trạng thái isTyping
          child: Obx(() {
            final bool isTyping = controller.isTyping.value;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const ChatbotInputActionMenuWidget(),
                const SizedBox(width: 4),

                // Ô NHẬP TEXT
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isTyping
                          ? AppColors.surface.withOpacity(0.5)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: AppColors.divider.withOpacity(0.5)),
                    ),
                    child: TextField(
                      controller: controller.textController,
                      focusNode: controller.focusNode,
                      readOnly: isTyping, // 🛑 Khóa bàn phím khi bot đang rep
                      maxLines: 4,
                      minLines: 1,
                      cursorColor: const Color(0xFFF08D9B),
                      textInputAction: TextInputAction.send,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: AppFonts.mainFont,
                        color: isTyping
                            ? AppColors.subText
                            : AppColors.primaryText,
                      ),
                      // 🛑 Chặn submit từ bàn phím
                      onSubmitted:
                          isTyping ? null : (_) => controller.sendMessage(),
                      decoration: InputDecoration(
                        hintText: isTyping
                            ? 'Tori đang gõ...'
                            : TTexts.chatbotInputHint.tr,
                        hintStyle: TextStyle(
                            color: AppColors.subText,
                            fontSize: 13,
                            fontFamily: AppFonts.mainFont),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // NÚT SEND
                GestureDetector(
                  // 🛑 Chặn tap khi đang typing
                  onTap: isTyping ? null : controller.sendMessage,
                  child: Container(
                    height: 48,
                    width: 48,
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Nếu đang typing thì nút chuyển màu xám mờ, ngược lại hiện dải màu gradient
                      color: isTyping ? Colors.grey.shade300 : null,
                      gradient: isTyping
                          ? null
                          : const LinearGradient(
                              colors: [
                                Color(0xFFB374B0),
                                Color(0xFFF08D9B),
                                Color(0xFFF8A875)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      boxShadow: isTyping
                          ? []
                          : [
                              BoxShadow(
                                  color:
                                      const Color(0xFFF08D9B).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4))
                            ],
                    ),
                    child: Icon(
                      Iconsax.send_1_copy,
                      color: isTyping ? Colors.grey.shade500 : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
