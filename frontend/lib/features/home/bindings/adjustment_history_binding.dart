import 'package:frontend/features/home/controllers/adjustment_history_controller.dart';
import 'package:get/get.dart';

class AdjustmentHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdjustmentHistoryController>(
      () => AdjustmentHistoryController(),
    );
  }
}
