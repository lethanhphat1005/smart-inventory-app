import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:frontend/features/profile/controllers/profile_assigns_role_controller.dart';
import 'package:frontend/features/profile/widgets/assigns_role/assigns_role_header_widgets.dart';
import 'package:frontend/features/profile/widgets/assigns_role/assigns_role_list_widgets.dart';
import 'package:frontend/features/profile/widgets/assigns_role/assigns_role_search_widgets.dart';
import 'package:frontend/features/profile/widgets/assigns_role/assigns_role_tab_widgets.dart';
import 'package:get/get.dart';

class AssignsRoleMobileView extends StatelessWidget {
  const AssignsRoleMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileAssignsRoleController());

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: const TBlurAppBarWidget(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +
                kToolbarHeight +
                AppSizes.p16,
            left: AppSizes.p24,
            right: AppSizes.p24,
            bottom: AppSizes.p48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AssignsRoleHeaderWidget(),
              const SizedBox(height: AppSizes.p24),

              AssignsRoleSearchWidget(
                hintText: TTexts.assignsRoleSearchHint.tr,
                onChanged: (value) => controller.onSearchChanged(value),
                onTap: () {},
              ),

              const SizedBox(height: AppSizes.p20),

              const AssignsRoleTabWidget(),
              const SizedBox(height: AppSizes.p20),

              // HIỂN THỊ SỐ LƯỢNG
              Obx(() => Row(
                    children: [
                      Text("${controller.totalCount} ",
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: AppSizes.p18,
                              fontWeight: FontWeight.bold)),
                      Text(TTexts.resultsFound.tr,
                          style: const TextStyle(
                              color: AppColors.subText,
                              fontSize: AppSizes.p14)),
                    ],
                  )),

              const SizedBox(height: AppSizes.p12),

              const AssignsRoleListWidget(),

              const SizedBox(height: AppSizes.p40),
            ],
          ),
        ),
      ),
    );
  }
}
