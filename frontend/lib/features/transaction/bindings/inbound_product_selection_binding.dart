import 'package:frontend/features/transaction/controllers/inbound_product_selection_controller.dart';
import 'package:get/get.dart';

class InboundProductSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InboundProductSelectionController());
  }
}
