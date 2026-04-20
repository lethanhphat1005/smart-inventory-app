import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/home/views/platform/low_stock_mobile_view.dart';

class LowStockView extends StatelessWidget {
  const LowStockView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: LowStockMobileView()),
    );
  }
}
