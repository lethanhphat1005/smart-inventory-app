import 'package:flutter/material.dart';
import 'package:frontend/features/notification/widgets/notification_filter_tab_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_app_bar_widget.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/widgets/t_refresh_indicator_widget.dart';
import 'package:frontend/core/ui/widgets/t_animation_loader_widget.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:frontend/features/notification/widgets/notification_card_widget.dart';

class NotificationMobileScreen extends StatelessWidget {
  const NotificationMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TAppBarWidget(
        title: TTexts.notificationTitle.tr,
        showBackArrow: true,
        centerTitle: true,
        actions: [
          Obx(
            () => controller.unreadCount.value > 0
                ? IconButton(
                    icon: const Icon(Iconsax.task_square_copy,
                        color: AppColors.primary),
                    onPressed: () => controller.markAllAsRead(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(children: [
        // ==========================================
        // THANH FILTER TABS
        // ==========================================
        NotificationFilterTabWidget(controller: controller),

        // ==========================================
        // DANH SÁCH THÔNG BÁO (Bọc trong Expanded)
        // ==========================================
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.notifications.isEmpty) {
              return TAnimationLoaderWidget(
                  text: TTexts.loadingNotifications.tr);
            }

            if (controller.notifications.isEmpty) {
              return TEmptyStateWidget(
                icon: Iconsax.notification_bing_copy,
                title: TTexts.emptyNotificationTitle.tr,
                subtitle: TTexts.emptyNotificationSub.tr,
                actionButton: SizedBox(
                  width: 150,
                  child: TPrimaryButtonWidget(
                    text: TTexts.reload.tr,
                    onPressed: () => controller.fetchNotifications(),
                  ),
                ),
              );
            }

            return TRefreshIndicatorWidget(
              onRefresh: controller.fetchNotifications,
              child: ListView.builder(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p16, vertical: AppSizes.p16),
                itemCount: controller.notifications.length +
                    (controller.isLoadMore.value ? 1 : 0) +
                    1,
                itemBuilder: (context, index) {
                  if (index < controller.notifications.length) {
                    final item = controller.notifications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.p12),
                      child: Dismissible(
                        key: Key(item.notificationId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.p24),
                          decoration: BoxDecoration(
                            color: AppColors.stockOut,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius16),
                          ),
                          child: const Icon(Iconsax.trash_copy,
                              color: AppColors.white, size: 28),
                        ),
                        onDismissed: (direction) {
                          controller.deleteNotificationWithUndo(item, index);
                        },
                        child: NotificationCardWidget(
                          notification: item,
                          timeAgo: controller.formatTimeAgo(item.createdAt),
                          onLongPress: () =>
                              controller.markAsRead(item.notificationId),
                          onTap: () => controller.handleNotificationClick(item),
                        ),
                      ),
                    );
                  } else if (controller.isLoadMore.value &&
                      index == controller.notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.p24),
                      child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: AppColors.primary),
                      ),
                    );
                  } else {
                    return const TBottomNavSpacerWidget();
                  }
                },
              ),
            );
          }),
        ),
      ]),
    );
  }
}
