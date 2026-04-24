import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/views/inventory_view.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/navigation/wigdets/navigation/naviagtion_draggable_chatbot_fab_widget.dart';
import 'package:frontend/features/navigation/wigdets/navigation/navigation_custom_bottom_navigation_widget.dart';
import 'package:frontend/features/profile/views/profile_view.dart';
import 'package:frontend/features/report/views/report_view.dart';
import 'package:frontend/features/home/views/home_view.dart';
import 'package:frontend/features/navigation/controllers/navigation_controller.dart';
import 'package:get/get.dart';

class NavigationMobileView extends GetView<NavigationController> {
  const NavigationMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final chatbotUiController = Get.find<ChatbotUiController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. MÀN HÌNH BÊN TRONG (BODY)
          Obx(() {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.enforceRoleRestrictions();
            });

            int index = controller.selectedIndex.value;
            Widget currentScreen;
            switch (index) {
              case 0:
                currentScreen = const HomeView();
                break;
              case 1:
                currentScreen = const InventoryView();
                break;
              case 2:
                currentScreen = const Center(child: Text('Transaction / Scan'));
                break;
              case 3:
                currentScreen = const ReportView();
                break;
              case 4:
                currentScreen = const ProfileView();
                break;
              default:
                currentScreen = const SizedBox.shrink();
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey<int>(index),
                child: currentScreen,
              ),
            );
          }),

          // 2. THANH ĐIỀU HƯỚNG BÊN DƯỚI
          const NavigationCustomBottomNavigationWidget(),

          Obx(() {
            if (!chatbotUiController.isChatOpen.value) {
              return const SizedBox.shrink();
            }
            return Positioned.fill(
              child: GestureDetector(
                onTap: chatbotUiController.closeChat,
                child: Container(color: Colors.transparent),
              ),
            );
          }),

          // 3. NÚT CHATBOT KÉO THẢ VÀ KHUNG CHAT
          const NavigationDraggableChatbotFabWidget(),
        ],
      ),
    );
  }
}
