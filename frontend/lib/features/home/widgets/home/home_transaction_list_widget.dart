import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'home_transaction_item_widget.dart';

class HomeTransactionListWidget extends GetView<HomeController> {
  const HomeTransactionListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.homeTodaysTransactions.tr,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final todayList = controller.recentTransactions;

          if (todayList.isEmpty) {
            return TEmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: TTexts.emptyTransactionTitle.tr,
              subtitle: TTexts.emptyTransactionSubtitle.tr,
            );
          }

          final recentList = todayList.take(3).toList();

          return Column(
            children: recentList.map((t) {
              final type = t.type.toLowerCase();
              final time = t.createdAt ?? DateTime.now();

              IconData icon;
              Color color;
              String title;
              bool isPositive;
              String displayAmount = '\$${t.totalPrice.toStringAsFixed(2)}';

              if (type == 'export') {
                icon = Icons.upload_rounded;
                color = AppColors.stockOut;
                title = TTexts.homeOutboundDelivery.tr;
                isPositive = true;
                displayAmount = "+$displayAmount";
              } else if (type == 'import') {
                icon = Icons.download_rounded;
                color = AppColors.stockIn;
                title = TTexts.homeInboundShipment.tr;
                isPositive = false;
                displayAmount = "-$displayAmount";
              } else {
                icon = Icons.sync_alt_rounded;
                color = AppColors.primary;
                title = TTexts.homeStockAdjustment.tr;

                isPositive = t.totalPrice >= 0;
                displayAmount = "${t.totalPrice > 0 ? '+' : ''}$displayAmount";
              }

              return HomeTransactionItemWidget(
                icon: icon,
                iconColor: color,
                title: title,
                time: time,
                amount: displayAmount,
                isPositive: isPositive,
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
