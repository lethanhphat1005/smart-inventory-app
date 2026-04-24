import 'package:flutter/material.dart';
import 'package:frontend/features/profile/controllers/profile_change_password_controller.dart';
import 'package:frontend/features/profile/widgets/change_password/change_password_profile_button_widgets.dart';
import 'package:frontend/features/profile/widgets/change_password/change_password_profile_header_widgets.dart';
import 'package:frontend/features/profile/widgets/change_password/change_password_text_field_widgets.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_nav_spacer_widget.dart';

class ChangePasswordMobileView
    extends GetView<ProfileChangePasswordController> {
  const ChangePasswordMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ChangePasswordHeaderWidget(),
            SizedBox(height: AppSizes.p32),
            ChangePasswordFormWidget(),
            SizedBox(height: AppSizes.p32),
            ChangePasswordButtonWidget(),
            SizedBox(height: AppSizes.p40),
            TBottomNavSpacerWidget(),
          ],
        ),
      ),
    );
  }
}
