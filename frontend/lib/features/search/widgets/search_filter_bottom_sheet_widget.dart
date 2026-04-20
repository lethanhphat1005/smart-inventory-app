import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class SearchFilterBottomSheetWidget extends StatefulWidget {
  const SearchFilterBottomSheetWidget({super.key});

  @override
  State<SearchFilterBottomSheetWidget> createState() =>
      _SearchFilterBottomSheetWidgetState();
}

class _SearchFilterBottomSheetWidgetState
    extends State<SearchFilterBottomSheetWidget> {
  final TSearchController controller = Get.find();

  late String selectedType;
  DateTimeRange? selectedDateRange;
  late String selectedUserId;
  late String selectedUserName;

  @override
  void initState() {
    super.initState();
    selectedType = controller.filterType.value;
    selectedDateRange = controller.filterDateRange.value;
    selectedUserId = controller.filterUserId.value;
    selectedUserName = controller.filterUserName.value;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAuthUserId =
        Get.find<UserService>().currentUser.value?.userId ?? 'USER-Admin';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CHỌN LOẠI (TYPE) ---
        Text(TTexts.transactionType.tr,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChoiceChip(TTexts.filterAll),
            _buildChoiceChip(TTexts.filterInbound),
            _buildChoiceChip(TTexts.filterOutbound),
          ].map((widget) => widget('type')).toList(),
        ),
        const SizedBox(height: 20),

        // --- NGÀY THÁNG ---
        Text(TTexts.dateRange.tr,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDateRange,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.softGrey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1_copy,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDateRange == null
                        ? TTexts.selectDateRange.tr
                        : '${DateFormat('dd/MM').format(selectedDateRange!.start)} - ${DateFormat('dd/MM').format(selectedDateRange!.end)}',
                    style: TextStyle(
                        color: selectedDateRange == null
                            ? AppColors.subText
                            : AppColors.primaryText,
                        fontSize: 14),
                  ),
                ),
                if (selectedDateRange != null)
                  GestureDetector(
                    onTap: () => setState(() => selectedDateRange = null),
                    child: const Icon(Icons.close,
                        size: 18, color: AppColors.softGrey),
                  )
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // --- DANH SÁCH NHÂN VIÊN TỪ API ---
        Text(TTexts.createdByUser.tr,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText)),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          // Bọc Obx để tự vẽ lại khi API trả về danh sách User
          child: Obx(() {
            if (controller.availableUsers.isEmpty) {
              return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2));
            }

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.availableUsers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final user = controller.availableUsers[index];
                final isSelected = selectedUserId == user.id;
                final isMe = user.id == currentAuthUserId;
                final displayName = isMe ? TTexts.me.tr : user.name;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedUserId = '';
                        selectedUserName = '';
                      } else {
                        selectedUserId = user.id;
                        selectedUserName = displayName;
                      }
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user.avatarUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                                color: AppColors.softGrey.withOpacity(0.2),
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))),
                            errorWidget: (context, url, error) => Container(
                                color: AppColors.softGrey.withOpacity(0.2),
                                child: const Icon(Iconsax.user_copy,
                                    size: 24, color: AppColors.subText)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 60,
                        child: Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primaryText,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 32),

        // --- BUTTONS ---
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedType = TTexts.filterAll;
                    selectedDateRange = null;
                    selectedUserId = '';
                    selectedUserName = '';
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.softGrey.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(TTexts.resetFilters.tr,
                    style: const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                // ĐÃ XÓA: selectedStatus
                onPressed: () => controller.applyFilters(selectedType,
                    selectedDateRange, selectedUserId, selectedUserName),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(TTexts.applyFilters.tr,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget Function(String) _buildChoiceChip(String textKey) {
    return (String category) {
      final isSelected = selectedType == textKey;
      return ChoiceChip(
        label: Text(textKey.tr,
            style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.primaryText)),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        showCheckmark: false,
        side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.softGrey.withOpacity(0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              selectedType = textKey;
            });
          }
        },
      );
    };
  }
}
