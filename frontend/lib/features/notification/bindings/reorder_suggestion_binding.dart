
import 'package:frontend/features/notification/controller/reorder_suggestion_controller.dart';
import 'package:get/get.dart';

class ReorderSuggestionBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<ReorderSuggestionController>(
      () => ReorderSuggestionController(),
    );
  }
}
