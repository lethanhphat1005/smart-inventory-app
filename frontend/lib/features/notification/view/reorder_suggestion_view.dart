import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/notification/view/platform/reorder_suggestion_mobile_screen.dart';

class ReorderSuggestionView extends StatelessWidget {
  const ReorderSuggestionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: ReorderSuggestionMobileScreen()),
    );
  }
}
