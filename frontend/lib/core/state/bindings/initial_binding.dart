import 'package:frontend/core/state/controllers/barcode_action_controller.dart';
import 'package:frontend/core/state/controllers/barcode_scanner_controller.dart';
import 'package:frontend/core/state/controllers/network_controller.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiClient(), permanent: true);

    //Xóa sau khi chạy backend thật
    Get.put(ProfileController(), permanent: true);
    // Get.put(ProfileAssignsRoleController(), permanent: true);

    Get.put(BarcodeScannerController(), permanent: true);
    Get.put(BarcodeActionController(), permanent: true);
    
    Get.put(NetworkController(), permanent: true);
  }
}
