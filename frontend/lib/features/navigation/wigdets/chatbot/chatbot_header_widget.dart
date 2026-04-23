import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatbotHeaderWidget extends StatelessWidget {
  const ChatbotHeaderWidget({super.key});

  // --- HELPER LÀM ICON GRADIENT ---
  Widget _buildGradientIcon(IconData icon, double size) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [
            Color(0xFFB374B0),
            Color(0xFFF08D9B),
            Color(0xFFF8A875),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatbotUiController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      color: AppColors.background,
      child: Row(
        children: [
          // AVATAR BỌC VÒNG GRADIENT
          Container(
            padding: const EdgeInsets.all(2.5), // Độ dày của viền gradient
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB374B0),
                  Color(0xFFF08D9B),
                  Color(0xFFF8A875),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(TImages.appLogos.appLogoGradient,
                  width: 26, height: 26),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Storix",
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Online",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // NÚT RESET CHAT 
          IconButton(
            icon: _buildGradientIcon(Iconsax.refresh, 22),
            onPressed: () => controller.resetChat(), 
          ),
          // NÚT ĐÓNG 
          IconButton(
            icon: _buildGradientIcon(Icons.close_rounded, 24),
            onPressed: () {
              FocusScope.of(context).unfocus();
              controller.closeChat();
            },
          )
        ],
      ),
    );
  }
}
