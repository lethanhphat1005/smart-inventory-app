import 'package:get/get.dart';
import 'package:frontend/features/auth/controllers/legal_document_controller.dart';

class LegalDocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LegalDocumentController>(() => LegalDocumentController());
  }
}