import 'package:frontend/features/onboarding/controllers/language_select_controller.dart';
import 'package:get/get.dart';

class LanguageSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageSelectController>(() => LanguageSelectController());
  }
}
