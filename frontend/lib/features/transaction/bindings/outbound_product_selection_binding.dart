import 'package:frontend/features/transaction/controllers/outbound_product_selection_controller.dart';
import 'package:get/get.dart';

class OutboundProductSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutboundProductSelectionController());
  }
}
