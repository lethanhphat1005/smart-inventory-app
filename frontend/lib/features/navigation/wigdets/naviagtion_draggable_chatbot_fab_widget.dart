import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/layout/chatbot_window_layout.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class NavigationDraggableChatbotFabWidget extends StatefulWidget {
  const NavigationDraggableChatbotFabWidget({super.key});

  @override
  State<NavigationDraggableChatbotFabWidget> createState() =>
      _NavigationDraggableChatbotFabWidgetState();
}

class _NavigationDraggableChatbotFabWidgetState
    extends State<NavigationDraggableChatbotFabWidget>
    with SingleTickerProviderStateMixin {
  final ChatbotUiController _uiController = Get.put(ChatbotUiController());

  Worker? _chatOpenWorker;

  Offset _currentPosition = const Offset(20, 100);
  Offset _savedPosition = const Offset(20, 100);
  bool _isInitialized = false;

  bool _isDragging = false;
  final double _fabSize = 85.0;

  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _chatOpenWorker = ever(_uiController.isChatOpen, (bool isOpen) {
      if (!mounted) return;
      if (isOpen) {
        _savedPosition = _currentPosition;
        setState(() {
          final size = MediaQuery.of(context).size;
          _currentPosition = Offset(size.width - _fabSize - 20, 50);
        });
      } else {
        setState(() {
          _currentPosition = _savedPosition;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final size = MediaQuery.of(context).size;
      _currentPosition = Offset(size.width - _fabSize - 16, size.height - 250);
      _savedPosition = _currentPosition;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _chatOpenWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final chatHeight = size.height - 140.0;

    return Obx(() {
      final isOpen = _uiController.isChatOpen.value;

      return Stack(
        children: [
          if (isOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  _uiController.closeChat();
                },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isOpen ? 1.0 : 0.0,
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutQuart,
            top: isOpen ? 140.0 : size.height,
            bottom: isOpen ? 0 : -chatHeight,
            left: 0,
            right: 0,
            child: ChatbotWindowLayout(),
          ),
          AnimatedPositioned(
            duration:
                _isDragging ? Duration.zero : const Duration(milliseconds: 350),
            curve: Curves.easeInOutBack,
            left: _currentPosition.dx,
            top: _currentPosition.dy,
            child: GestureDetector(
              onPanStart: (details) {
                if (!isOpen) setState(() => _isDragging = true);
              },
              onPanUpdate: (details) {
                if (!isOpen) {
                  setState(() {
                    _currentPosition += details.delta;
                    double x =
                        _currentPosition.dx.clamp(0.0, size.width - _fabSize);
                    double y =
                        _currentPosition.dy.clamp(0.0, size.height - _fabSize);
                    _currentPosition = Offset(x, y);
                  });
                }
              },
              onPanEnd: (details) {
                if (!isOpen) setState(() => _isDragging = false);
              },
              onTap: _uiController.toggleChat,
              child: AnimatedBuilder(
                animation: _breathAnimation,
                builder: (context, child) {
                  return Container(
                    width: _fabSize,
                    height: _fabSize,
                    color: Colors.transparent,
                    child: Transform.scale(
                      scale: _breathAnimation.value,
                      child: Lottie.asset(
                        TImages.coreImages.chatbotai,
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
