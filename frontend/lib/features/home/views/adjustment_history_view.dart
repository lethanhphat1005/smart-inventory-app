import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/home/views/platform/adjustment_history_mobile_view.dart';

class AdjustmentHistoryView extends StatelessWidget {
  const AdjustmentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: AdjustmentHistoryMobileView()),
    );
  }
}
