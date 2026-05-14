import 'package:frontend/features/inventory/controllers/hidden_category_controller.dart';
import 'package:get/get.dart';

class HiddenCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HiddenCategoryController());
  }
}
