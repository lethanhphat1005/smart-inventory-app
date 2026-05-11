import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatbotSuggestedPrompts extends StatelessWidget {
  final Function(String text, bool autoSend) onAction;

  const ChatbotSuggestedPrompts({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final prompts = [
      {
        "icon": Iconsax.warning_2,
        "text": TTexts.chatbotPromptLowStock.tr,
        "autoSend": true,
      },
      {
        "icon": Iconsax.box_search,
        "text": TTexts.chatbotPromptCheckInfo.tr,
        "autoSend": false,
      },
      {
        "icon": Iconsax.import_1,
        "text": TTexts.chatbotPromptImport.tr,
        "autoSend": false,
      },
      {
        "icon": Iconsax.export_1,
        "text": TTexts.chatbotPromptExport.tr,
        "autoSend": false,
      },
    ];

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      Colors.pinkAccent.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.magic_star,
                    color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                TTexts.chatbotSuggestionTitle.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                  fontFamily: AppFonts.mainFont,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                TTexts.chatbotSuggestionSub.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subText.withOpacity(0.8),
                    fontFamily: AppFonts.mainFont),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: prompts.map((prompt) {
                  return InkWell(
                    onTap: () => onAction(
                        prompt['text'] as String, prompt['autoSend'] as bool),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(prompt['icon'] as IconData,
                              size: 16, color: AppColors.subText),
                          const SizedBox(width: 8),
                          Text(
                            prompt['text'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryText,
                              fontFamily: AppFonts.mainFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
