import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_blur_app_bar_widget.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';
import 'package:frontend/features/profile/widgets/edit_store/edit_store_card_widgets.dart';
import 'package:frontend/features/profile/widgets/edit_store/edit_store_header_widgets.dart';
import 'package:frontend/features/profile/widgets/edit_store/edit_store_list_widgets.dart';
import 'package:get/get.dart';

class EditStoreMobileView extends GetView<ProfileEditStoreController> {
  const EditStoreMobileView({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditStoreHeaderWidget(),
              SizedBox(height: AppSizes.p24),
              EditStoreCardWidgets(),
              SizedBox(height: AppSizes.p24),
              // AssignsRoleMembersView(),
              EditStoreListWidgets(),
            ],
          ),
        ),
      ),
    );
  }
}
