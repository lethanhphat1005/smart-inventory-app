import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatbotSuggestedPrompts extends StatelessWidget {
  final Function(String text, bool autoSend) onAction;

  const ChatbotSuggestedPrompts({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatbotUiController>();

    final prompts = [
      _PromptItem(
        icon: Iconsax.warning_2,
        iconColor: const Color(0xFFA32D2D),
        label: TTexts.chatbotPromptLowStock.tr,
        sub: TTexts.chatbotPromptLowStockSub.tr, // Phục hồi biến sub
        autoSend: true,
      ),
      _PromptItem(
        icon: Iconsax.box_search,
        iconColor: const Color(0xFF185FA5),
        label: TTexts.chatbotPromptCheckInfo.tr,
        sub: TTexts.chatbotPromptCheckInfoSub.tr,
        autoSend: false,
      ),
      _PromptItem(
        icon: Iconsax.import_1,
        iconColor: const Color(0xFF3B6D11),
        label: TTexts.chatbotPromptImport.tr,
        sub: TTexts.chatbotPromptImportSub.tr,
        autoSend: false,
      ),
      _PromptItem(
        icon: Iconsax.export_1,
        iconColor: const Color(0xFF854F0B),
        label: TTexts.chatbotPromptExport.tr,
        sub: TTexts.chatbotPromptExportSub.tr,
        autoSend: false,
      ),
      if (controller.canViewAuditLog)
        _PromptItem(
          icon: Iconsax.clock,
          iconColor: const Color(0xFF4A4A9C),
          label: TTexts.chatbotPromptAuditLog.tr,
          sub: TTexts.chatbotPromptAuditLogSub.tr,
          autoSend: true,
        ),
      _PromptItem(
        icon: Iconsax.info_circle,
        iconColor: const Color(0xFF2D82A3),
        label: TTexts.chatbotPromptHelp.tr,
        sub: TTexts.chatbotPromptHelpSub.tr,
        autoSend: true,
      ),
    ];

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar icon
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.magic_star,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                TTexts.chatbotSuggestionTitle.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                TTexts.chatbotSuggestionSub.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.subText.withOpacity(0.8),
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Dùng Wrap để linh hoạt xếp các nút
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 12,
                children: prompts.map((p) => _buildPromptChip(p)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptChip(_PromptItem p) {
    return Tooltip(
      message: p.sub, // Text hiển thị khi Tooltip nổi lên
      triggerMode: TooltipTriggerMode
          .longPress, // Quan trọng cho Mobile: Nhấn giữ để hiện
      decoration: BoxDecoration(
        color: AppColors.primaryText.withOpacity(0.9), // Nền tối
        borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFamily: 'Poppins',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      showDuration: const Duration(seconds: 3), // Hiện 3s rồi tự tắt
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onAction(p.label, p.autoSend),
          borderRadius: BorderRadius.circular(30),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(p.icon, size: 16, color: p.iconColor),
                const SizedBox(width: 8),
                Text(
                  p.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sub; // Khôi phục lại biến mô tả
  final bool autoSend;

  const _PromptItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sub,
    required this.autoSend,
  });
}
