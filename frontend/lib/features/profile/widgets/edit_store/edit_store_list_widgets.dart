import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_empty_state_widget.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';
import 'package:frontend/features/profile/widgets/edit_store/t_form_item_skeleton_widget.dart';
import 'package:frontend/features/profile/widgets/edit_store/edit_store_item_widgets.dart';
import 'package:frontend/features/profile/widgets/edit_store/t_user_info_bottom_sheet_widgets.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class EditStoreListWidgets extends StatelessWidget {
  const EditStoreListWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileEditStoreController>();

    return Obx(() {
      // Chưa load xong lần đầu -> show skeleton
      if (!controller.hasLoadedMembers.value) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.p4,
                vertical: AppSizes.p8,
              ),
              child: Text(
                "Members",
                style: TextStyle(
                  fontSize: AppSizes.p16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            TStoreItemSkeleton(),
            TStoreItemSkeleton(),
            TStoreItemSkeleton(),
          ],
        );
      }

      // Đã load xong mà không có member thật
      if (controller.filteredMembers.isEmpty) {
        return TEmptyStateWidget(
          icon: Icons.people_outline_rounded,
          title: TTexts.profileNoMembers.tr,
          subtitle: TTexts.profileNoMembersSubtitle.tr,
        );
      }

      // Có data thật
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p4,
              vertical: AppSizes.p8,
            ),
            child: Text(
              "Members (${controller.memberCount.value})",
              style: const TextStyle(
                fontSize: AppSizes.p16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredMembers.length,
            itemBuilder: (context, index) {
              final member = controller.filteredMembers[index];

              return StoreItemWidget(
                name: member.name,
                role: member.role,
                image: '',
                onTap: () {
                  TUserInfoBottomSheetWidgets.show(member);
                },
              );
            },
          ),
        ],
      );
    });
  }
}
