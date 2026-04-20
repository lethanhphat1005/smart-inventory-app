import 'package:frontend/features/home/controllers/low_stock_controller.dart';
import 'package:get/get.dart';

class LowStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LowStockController>(() => LowStockController());
  }
}
