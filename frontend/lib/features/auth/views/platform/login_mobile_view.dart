import 'package:flutter/material.dart';
import 'package:frontend/features/auth/layouts/auth_standard_layout.dart';
import 'package:frontend/features/auth/widgets/login/login_form_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/auth/controllers/login_controller.dart';

class LoginMobileView extends GetView<LoginController> {
  const LoginMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStandardLayout(
      title: TTexts.loginWelcomeTitle.tr,
      subtitle: TTexts.loginWelcomeSubtitle.tr,
      showBackButton: false,
      child: const LoginFormWidget(),
    );
  }
}
