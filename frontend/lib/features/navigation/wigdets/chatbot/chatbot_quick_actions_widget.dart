import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:get/get.dart';

class ChatbotQuickActionsWidget extends StatelessWidget {
  const ChatbotQuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatbotUiController>();

    final actions = [
      {
        "label": "Low stock",
        "template": "What items are running low?",
        "autoSend": true
      },
      {"label": "Import", "template": "Create import: ", "autoSend": false},
      {"label": "Export", "template": "Create export: ", "autoSend": false},
    ];

    return Container(
      height: 52, // Tăng nhẹ chiều cao để nút dễ bấm
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final action = actions[index];
          return InkWell(
            onTap: () {
              final text = action["template"] as String;
              final autoSend = action["autoSend"] as bool;

              if (autoSend) {
                controller.textController.text = text;
                controller.sendMessage();
              } else {
                controller.textController.text = text;
                controller.textController.selection =
                    TextSelection.fromPosition(TextPosition(
                        offset: controller.textController.text.length));
                controller.focusNode.requestFocus();
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08), // Nền cam siêu nhạt
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3)), // Viền cam
              ),
              child: Text(
                action["label"] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary, // Chữ cam
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
