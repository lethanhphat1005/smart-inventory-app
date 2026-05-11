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
      {
        "icon": Iconsax.warning_2,
        "iconColor": const Color(0xFFA32D2D),
        "bgColor": const Color(0xFFFCEBEB),
        "title": "Hàng sắp hết",
        "sub": "Gửi ngay",
        "text": TTexts.chatbotPromptLowStock.tr,
        "autoSend": true,
      },
      {
        "icon": Iconsax.box_search,
        "iconColor": const Color(0xFF185FA5),
        "bgColor": const Color(0xFFE6F1FB),
        "title": "Tìm sản phẩm",
        "sub": "Nhập tên SP",
        "text": TTexts.chatbotPromptCheckInfo.tr,
        "autoSend": false,
      },
      {
        "icon": Iconsax.import_1,
        "iconColor": const Color(0xFF3B6D11),
        "bgColor": const Color(0xFFEAF3DE),
        "title": "Tạo phiếu nhập",
        "sub": "Nhập tên + SL",
        "text": TTexts.chatbotPromptImport.tr,
        "autoSend": false,
      },
      {
        "icon": Iconsax.export_1,
        "iconColor": const Color(0xFF854F0B),
        "bgColor": const Color(0xFFFAEEDA),
        "title": "Tạo phiếu xuất",
        "sub": "Nhập tên + SL",
        "text": TTexts.chatbotPromptExport.tr,
        "autoSend": false,
      },
    ];

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: prompts.length,
                itemBuilder: (context, index) {
                  final prompt = prompts[index];
                  return InkWell(
                    onTap: () => onAction(
                        prompt['text'] as String, prompt['autoSend'] as bool),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: prompt['bgColor'] as Color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(prompt['icon'] as IconData,
                                size: 16, color: prompt['iconColor'] as Color),
                          ),
                          const Spacer(),
                          Text(
                            prompt['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prompt['sub'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.subText.withOpacity(0.8),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
