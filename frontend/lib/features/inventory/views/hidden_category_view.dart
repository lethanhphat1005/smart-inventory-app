import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/inventory/views/platform/hidden_category_mobile_view.dart';

class HiddenCategoryView extends StatelessWidget {
  const HiddenCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: HiddenCategoryMobileView()),
    );
  }
}
