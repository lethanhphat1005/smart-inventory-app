import 'package:flutter/material.dart';
import 'package:frontend/features/profile/controllers/profile_edit_profile_controller.dart';
import 'package:frontend/features/profile/widgets/edit_profile/edit_profile_btn_confirm_widgets.dart';
import 'package:frontend/features/profile/widgets/edit_profile/edit_profile_form_field_widgets.dart';
import 'package:frontend/features/profile/widgets/edit_profile/edit_profile_header_widgets.dart';
import 'package:get/get.dart';

import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class EditProfileMobileView extends GetView<ProfileEditController> {
  const EditProfileMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              EditProfileHeaderWidget(),
              EditProfileFormWidget(),
              SizedBox(height: AppSizes.p32),
              EditProfileSaveButtonWidget(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
