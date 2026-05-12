import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/transaction/views/platform/inbound_product_selection_mobile_view.dart';

class InboundProductSelectionView extends StatelessWidget {
  const InboundProductSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: InboundProductSelectionMobileView()),
    );
  }
}
