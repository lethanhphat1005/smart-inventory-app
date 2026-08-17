import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/get_package_full_display_name.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

/// Choose Product Card — khi user chọn một item:
///   • Item đã chọn: highlight tím + icon ✓ rõ ràng
///   • Các item còn lại: mờ hẳn + không tap được
/// Trước đây toàn bộ list fade đều → không rõ đã chọn cái nào.
///
/// Fix bug ngôn ngữ: command gửi lên dùng template trung tính
/// thay vì hardcode tiếng Anh, tránh BE trả lời sai ngôn ngữ.
class ChatCardChooseProduct extends StatelessWidget {
  final ChatMessage message;

  const ChatCardChooseProduct({super.key, required this.message});

  static const Color _selectedBg = Color(0xFFEEEDFE);
  static const Color _selectedText = Color(0xFF3C3489);
  static const Color _selectedAccent = Color(0xFF534AB7);

  @override
  Widget build(BuildContext context) {
    final data = message.data;
    if (data == null || data['items'] == null) return const SizedBox.shrink();

    final List<dynamic> items = data['items'] as List<dynamic>;
    final controller = Get.find<ChatbotUiController>();

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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header text
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  height: 1.45,
                ),
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade100),

            // Product list
            ListView.separated(
              padding: const EdgeInsets.only(bottom: 8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100, indent: 60),
              itemBuilder: (context, index) {
                final item = items[index];
                final pkg = item['productPackage'] ?? item;

                // final displayName = pkg['displayName'] ??
                //     pkg['product']?['name'] ??
                //     TTexts.unknownProduct.tr;
                final displayName =
                    DisplayNameUtils.getFullPackageDisplayNameFromJson(pkg);

                final quantity =
                    (item['quantity'] ?? pkg['quantity'] ?? 0) as num;
                final unit = pkg['unit']?['name'] ?? '';

                final threshold = int.tryParse(
                        item['reorder_threshold']?.toString() ??
                            item['reorderThreshold']?.toString() ??
                            pkg['reorder_threshold']?.toString() ??
                            '10') ??
                    10;

                Color stockColor;
                String stockText;

                if (quantity == 0) {
                  stockColor = AppColors.stockOut;
                  stockText = TTexts.chatbotOutOfStock.tr;
                } else if (quantity <= threshold) {
                  stockColor = AppColors.primary;
                  stockText =
                      '${TTexts.chatbotLowStockPrefix.tr} ${quantity.toInt()} $unit'
                          .trim();
                } else {
                  stockColor = AppColors.stockIn;
                  stockText =
                      '${TTexts.chatbotLeftPrefix.tr} ${quantity.toInt()} $unit'
                          .trim();
                }

                final isResolved = message.isResolved;
                // Xác định item này có phải item đã được chọn không
                // (lưu index vào data khi user chọn)
                final selectedIndex = data['selectedIndex'] as int?;
                final isSelected = isResolved && selectedIndex == index;
                final isOther = isResolved && selectedIndex != index;

                return Opacity(
                  opacity: isOther ? 0.3 : 1.0,
                  child: IgnorePointer(
                    ignoring: isResolved,
                    child: InkWell(
                      onTap: () {
                        if (isResolved) return;

                        final originalIntent = data['originalIntent'];
                        final qty = data['quantity'] ?? 1;

                        // Template trung tính — dùng từ khóa
                        // coordinator nhận diện được ở cả VI lẫn EN
                        String command;
                        if (originalIntent == 'get_product_info') {
                          command =
                              '${TTexts.chatbotCmdCheckInfo.tr} "$displayName"';
                        } else if (originalIntent == 'create_import') {
                          command =
                              '${TTexts.chatbotCmdImport.tr} $qty "$displayName"';
                        } else if (originalIntent == 'create_export') {
                          command =
                              '${TTexts.chatbotCmdExport.tr} $qty "$displayName"';
                        } else {
                          command = displayName;
                        }

                        // Lưu index đã chọn vào data
                        (message.data
                            as Map<String, dynamic>)['selectedIndex'] = index;
                        message.isResolved = true;
                        controller.messages.refresh();

                        controller.textController.text = command;
                        controller.sendMessage();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        color: isSelected ? _selectedBg : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            // Icon circle
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _selectedAccent.withOpacity(0.15)
                                    : const Color(0xFFF4F5F7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected ? Iconsax.tick_circle : Iconsax.box,
                                size: 18,
                                color: isSelected
                                    ? _selectedAccent
                                    : AppColors.subText,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Name + stock
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? _selectedText
                                          : AppColors.primaryText,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isSelected
                                        ? TTexts.chatbotSelected.tr
                                        : stockText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? _selectedAccent
                                          : stockColor,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Trailing icon
                            Icon(
                              isSelected
                                  ? Iconsax.tick_circle
                                  : Iconsax.arrow_right_3,
                              size: isSelected ? 20 : 16,
                              color: isSelected
                                  ? _selectedAccent
                                  : Colors.grey.shade300,
                            ),
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
