import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:get/get.dart';

class ReportTransactionDetailInfoCardWidget extends StatelessWidget {
  final TransactionModel tx;

  const ReportTransactionDetailInfoCardWidget({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final userService = Get.find<UserService>();
    final storeService = Get.find<StoreService>();

    final String userName =
        userService.currentUser.value?.fullName ?? TTexts.unknownUser.tr;

    const String? realAvatarUrl = null;

    final String displayRole =
        storeService.currentRole.value.capitalizeFirst ?? TTexts.staff.tr;
    final String storeName = storeService.currentStoreName.value.isNotEmpty
        ? storeService.currentStoreName.value
        : TTexts.mainHQStore.tr;

    Color typeColor = AppColors.primaryText;
    final String typeLower = tx.type.toLowerCase();
    String displayType = _capitalize(tx.type);

    if (typeLower == 'import') {
      typeColor = AppColors.stockIn;
      displayType = TTexts.inbound.tr;
    } else if (typeLower == 'export') {
      typeColor = AppColors.stockOut;
      displayType = TTexts.outbound.tr;
    } else if (typeLower == 'adjustment') {
      typeColor = AppColors.primary;
      displayType = TTexts.stockAdjustment.tr;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: AppColors.softGrey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildAvatar(realAvatarUrl),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText)),
                      Text(displayRole,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.subText)),
                    ],
                  )
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayType,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: typeColor),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          _buildInfoRow(
              TTexts.transactionId.tr, tx.transactionId ?? TTexts.na.tr,
              isBold: true),
          const SizedBox(height: 12),
          _buildInfoRow(TTexts.dateAndTime.tr,
              DayFormatterUtils.formatDateTime(tx.createdAt)),
          const SizedBox(height: 12),
          _buildInfoRow(TTexts.cashier.tr, userName),
          const SizedBox(height: 12),
          _buildInfoRow(TTexts.role.tr, displayRole),
          const SizedBox(height: 12),
          _buildInfoRow(TTexts.store.tr, storeName),
          const SizedBox(height: 12),
          _buildInfoRow(
            TTexts.note.tr,
            (tx.note == null || tx.note!.isEmpty) ? TTexts.na.tr : tx.note!,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.softGrey.withOpacity(0.1),
            child: const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))),
          ),
          errorWidget: (context, url, error) => _buildDefaultAvatar(),
        ),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: AppColors.primary, size: 22),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  Widget _buildInfoRow(String label, String value,
      {Color valueColor = AppColors.primaryText, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 100,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.subText))),
        Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                    color: valueColor))),
      ],
    );
  }
}
