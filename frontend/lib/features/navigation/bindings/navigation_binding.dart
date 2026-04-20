import 'package:frontend/features/inventory/controllers/inventory_controller.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:frontend/features/report/controllers/report_controller.dart';
import 'package:frontend/features/report/controllers/report_export_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/features/navigation/controllers/navigation_controller.dart';
import 'package:frontend/features/home/controllers/home_controller.dart';
import 'package:frontend/features/profile/controllers/profile_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Controller của Nav thì put ngay để dùng
    Get.put(NavigationController());
    Get.put(NotificationController());

    // 2. Các Controller của Tab con thì dùng lazyPut.
    // Chúng sẽ chỉ được khởi tạo trên RAM khi View tương ứng gọi Get.find()
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => InventoryController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => ReportController(), fenix: true);

    // 3. Các Controller phụ của Tab.
    Get.put(ChatbotUiController(), permanent: true);
    Get.lazyPut(() => ReportExportController(), fenix: true);
  }
}
