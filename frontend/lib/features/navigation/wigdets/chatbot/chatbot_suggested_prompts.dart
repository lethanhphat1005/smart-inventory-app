import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatbotSuggestedPrompts extends StatelessWidget {
  final Function(String text, bool autoSend) onAction;

  const ChatbotSuggestedPrompts({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final prompts = [
      _PromptItem(
        icon: Iconsax.warning_2,
        iconBg: const Color(0xFFFCEBEB),
        iconColor: const Color(0xFFA32D2D),
        label: TTexts.chatbotPromptLowStock.tr,
        sub: TTexts.chatbotPromptLowStockSub.tr,
        autoSend: true,
      ),
      _PromptItem(
        icon: Iconsax.box_search,
        iconBg: const Color(0xFFE6F1FB),
        iconColor: const Color(0xFF185FA5),
        label: TTexts.chatbotPromptCheckInfo.tr,
        sub: TTexts.chatbotPromptCheckInfoSub.tr,
        autoSend: false,
      ),
      _PromptItem(
        icon: Iconsax.import_1,
        iconBg: const Color(0xFFEAF3DE),
        iconColor: const Color(0xFF3B6D11),
        label: TTexts.chatbotPromptImport.tr,
        sub: TTexts.chatbotPromptImportSub.tr,
        autoSend: false,
      ),
      _PromptItem(
        icon: Iconsax.export_1,
        iconBg: const Color(0xFFFAEEDA),
        iconColor: const Color(0xFF854F0B),
        label: TTexts.chatbotPromptExport.tr,
        sub: TTexts.chatbotPromptExportSub.tr,
        autoSend: false,
      ),
      _PromptItem(
        icon: Iconsax.clock,
        iconBg: const Color(0xFFEBEBFC),
        iconColor: const Color(0xFF4A4A9C),
        label: TTexts.chatbotPromptAuditLog.tr,
        sub: TTexts.chatbotPromptAuditLogSub.tr,
        autoSend: false, // Dựa theo thay đổi bạn muốn ở bước trước
      ),
      _PromptItem(
        icon: Iconsax.info_circle,
        iconBg: const Color(0xFFEBF7FC),
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

              // Grid 2×2 -> 2x3
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio:
                    1.4, // Đã điều chỉnh lại tỉ lệ để vừa chứa sub-text
                children: prompts.map((p) => _buildPromptCard(p)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptCard(_PromptItem p) {
    return InkWell(
      onTap: () => onAction(p.label, p.autoSend),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: p.iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(p.icon, size: 18, color: p.iconColor),
            ),
            const Spacer(),
            Text(
              p.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              p.sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.subText.withOpacity(0.75),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String sub;
  final bool autoSend;

  const _PromptItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.sub,
    required this.autoSend,
  });
}
