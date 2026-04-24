import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/search/controllers/search_controller.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class SearchHistoryWidget extends GetView<TSearchController> {
  const SearchHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.recentSearches.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TTexts.recentSearches.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                TextButton(
                  onPressed: controller.clearRecentSearches,
                  child: Text(TTexts.clearAll.tr,
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 13)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 0,
              children: controller.recentSearches
                  .map((text) => GestureDetector(
                        onLongPress: () =>
                            controller.confirmRemoveRecentSearch(text),
                        child: ActionChip(
                          label:
                              Text(text, style: const TextStyle(fontSize: 13)),
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                              color: AppColors.softGrey.withOpacity(0.1)),
                          onPressed: () {
                            controller.textController.text = text;
                            controller.onSearchChanged(text);
                          },
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
    });
  }
}
