import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/auth/views/platform/legal_document_mobile_view.dart';

class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: LegalDocumentMobileView()),
    );
  }
}
