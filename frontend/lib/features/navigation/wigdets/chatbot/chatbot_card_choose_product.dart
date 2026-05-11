import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
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
    final selectedIndex = data['selectedIndex']; // Lưu vị trí item được click

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.85),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(message.text,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryText,
                      fontFamily: 'Poppins')),
            ),
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final item = items[index];
                final pkg = item['productPackage'] ?? item;
                final displayName = pkg['displayName'] ??
                    pkg['product']?['name'] ??
                    TTexts.unknownProduct.tr;
                final quantity = item['quantity'] ?? pkg['quantity'] ?? 0;

                final isSelected = message.isResolved && selectedIndex == index;
                final isNotSelected =
                    message.isResolved && selectedIndex != index;

                return AbsorbPointer(
                  absorbing: message.isResolved,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isNotSelected ? 0.35 : 1.0,
                    child: InkWell(
                      onTap: () {
                        // Lưu index đã chọn
                        message.data['selectedIndex'] = index;
                        message.isResolved = true;

                        final originalIntent = data['originalIntent'];
                        final qty = data['quantity'] ?? 1;
                        String command = "";
                        if (originalIntent == 'create_import') {
                          command = 'Nhập $qty "$displayName"';
                        } else if (originalIntent == 'create_export') {
                          command = 'Xuất $qty "$displayName"';
                        } else {
                          command = 'Thông tin "$displayName"';
                        }

                        controller.messages.refresh();
                        controller.textController.text = command;
                        controller.sendMessage();
                      },
                      child: Container(
                        color: isSelected
                            ? const Color(0xFFEEEDFE)
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0x337F77DD)
                                      : const Color(0xFFF8F9FA),
                                  shape: BoxShape.circle),
                              child: Icon(
                                  isSelected
                                      ? Iconsax.tick_circle
                                      : Iconsax.box,
                                  size: 16,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.subText),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(displayName,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.primaryText,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins')),
                                  const SizedBox(height: 2),
                                  Text(
                                      isSelected
                                          ? "Đã chọn"
                                          : "Còn $quantity sản phẩm",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected
                                              ? AppColors.primary
                                              : const Color(0xFF3B6D11),
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Iconsax.tick_circle,
                                  color: AppColors.primary, size: 18)
                          ],
                        ),
                      ),
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
