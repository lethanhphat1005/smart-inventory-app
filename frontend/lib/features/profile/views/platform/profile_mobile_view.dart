import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';
import 'package:frontend/features/profile/widgets/profile/profile_btn_logout_widgets.dart';
import 'package:frontend/features/profile/widgets/profile/profile_card_widgets.dart';
import 'package:frontend/features/profile/widgets/profile/profile_header_widgets.dart';
import 'package:frontend/features/profile/widgets/profile/profile_menu_section_widgets.dart';
import 'package:frontend/features/profile/widgets/profile/profile_user_detail_widgets.dart';
import 'package:get/get.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class ProfileMobileView extends GetView<ProfileController> {
  const ProfileMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeaderWidget(),
              ProfileInfoWidget(),
              SizedBox(height: AppSizes.p24),
              ProfileStoreCardWidget(),
              SizedBox(height: AppSizes.p20),
              ProfileMenuWidget(),
              SizedBox(height: AppSizes.p32),
              ProfileLogoutButtonWidget(),
              SizedBox(height: 40),
              TBottomNavSpacerWidget()
            ],
          ),
        ),
      ),
    );
  }
}
