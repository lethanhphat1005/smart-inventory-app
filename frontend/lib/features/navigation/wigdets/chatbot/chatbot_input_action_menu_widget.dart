import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatbotInputActionMenuWidget extends StatefulWidget {
  const ChatbotInputActionMenuWidget({super.key});

  @override
  State<ChatbotInputActionMenuWidget> createState() =>
      _ChatbotInputActionMenuWidgetState();
}

class _ChatbotInputActionMenuWidgetState
    extends State<ChatbotInputActionMenuWidget>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _animationController;
  late Animation<double> _menuAnimation;
  late Animation<double> _iconRotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _menuAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.375).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _closeMenu() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _handleAction(String template, bool autoSend) {
    _closeMenu();
    final controller = Get.find<ChatbotUiController>();
    if (autoSend) {
      controller.textController.text = template;
      controller.sendMessage();
    } else {
      // Tối ưu UX: Thêm sẵn dấu cách để user gõ tiếp tên SP/Số lượng ngay
      controller.textController.text = '$template ';
      controller.textController.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.textController.text.length));
      controller.focusNode.requestFocus();
    }
  }

  Widget _buildGradientIcon(IconData icon, double size) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Color(0xFFB374B0), Color(0xFFF08D9B), Color(0xFFF8A875)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeMenu,
            behavior: HitTestBehavior.translucent,
            child: FadeTransition(
              opacity: _menuAnimation,
              child: Container(color: Colors.black.withOpacity(0.02)),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            followerAnchor: Alignment.bottomLeft,
            targetAnchor: Alignment.topLeft,
            offset: const Offset(0, -12),
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _menuAnimation,
                child: ScaleTransition(
                  scale: _menuAnimation,
                  alignment: Alignment.bottomLeft,
                  child: IntrinsicWidth(child: _buildGlassmorphismCard()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismCard() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(AppSizes.radius20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cập nhật đủ 6 tính năng đồng bộ với Quick Actions
                  _buildMenuItem(
                      text: TTexts.chatbotQuickActionLowStock.tr,
                      onTap: () =>
                          _handleAction(TTexts.chatbotPromptLowStock.tr, true)),
                  _buildMenuItem(
                      text: TTexts.chatbotQuickActionInfo.tr,
                      onTap: () => _handleAction(
                          TTexts.chatbotPromptCheckInfo.tr, false)),
                  _buildMenuItem(
                      text: TTexts.chatbotQuickActionImport.tr,
                      onTap: () =>
                          _handleAction(TTexts.chatbotPromptImport.tr, false)),
                  _buildMenuItem(
                      text: TTexts.chatbotQuickActionExport.tr,
                      onTap: () =>
                          _handleAction(TTexts.chatbotPromptExport.tr, false)),

                  if (Get.find<ChatbotUiController>().canViewAuditLog)
                    _buildMenuItem(
                        text: TTexts.chatbotQuickActionHistory.tr,
                        onTap: () => _handleAction(
                            TTexts.chatbotPromptAuditLog.tr, false)),
                  _buildMenuItem(
                      text: TTexts.chatbotQuickActionHelp.tr,
                      onTap: () =>
                          _handleAction(TTexts.chatbotPromptHelp.tr, true)),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFFB374B0),
                    Color(0xFFF08D9B),
                    Color(0xFFF8A875)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radius20),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFFF08D9B).withOpacity(0.15),
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radius16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Text(text,
            style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.mainFont)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          height: 48,
          width: 48,
          margin: const EdgeInsets.only(bottom: 2),
          decoration: const BoxDecoration(
              color: Colors.transparent, shape: BoxShape.circle),
          child: RotationTransition(
            turns: _iconRotationAnimation,
            child: _buildGradientIcon(Iconsax.add, 28),
          ),
        ),
      ),
    );
  }
}
