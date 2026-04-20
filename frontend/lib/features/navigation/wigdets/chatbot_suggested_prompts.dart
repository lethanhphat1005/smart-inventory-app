import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatbotSuggestedPrompts extends StatelessWidget {
  final Function(String text, bool autoSend) onAction;

  const ChatbotSuggestedPrompts({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final prompts = [
      {
        "icon": Iconsax.warning_2,
        "color": Colors.orange,
        "text": "Sản phẩm nào sắp hết hàng?",
        "autoSend": true, // Gửi luôn vì không cần tham số
      },
      {
        "icon": Iconsax.box_search,
        "color": Colors.blue,
        "text": "Kiểm tra thông tin: ", // Bỏ hardcode Monopoly
        "autoSend": false, // Điền vào ô text và đợi
      },
      {
        "icon": Iconsax.import_1,
        "color": Colors.green,
        "text": "Nhập kho: ", // Cung cấp cú pháp
        "autoSend": false,
      },
    ];
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.magic_star,
                    color: Colors.blue, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                "Bạn cần trợ giúp gì?",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                "Chọn một gợi ý bên dưới hoặc gõ yêu cầu của bạn.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
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
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(prompt['icon'] as IconData,
                              size: 18, color: prompt['color'] as Color),
                          const SizedBox(width: 8),
                          Text(
                            prompt['text'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
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
