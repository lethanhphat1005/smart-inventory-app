import 'package:frontend/core/state/services/store_service.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  final RxInt selectedIndex = 0.obs;

  final StoreService _storeService = Get.find<StoreService>();

  bool get isRestricted =>
      _storeService.currentRole.value.toLowerCase() == 'staff';

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe sự kiện đổi Quyền (Role): Nếu từ Staff được nâng lên Owner, auto thả về tab Home
    ever(_storeService.currentRole, (_) {
      if (!isRestricted && selectedIndex.value == 1) {
        selectedIndex.value = 0;
      }
    });
  }

  void changeIndex(int index) {
    // Nếu là nhân viên (restricted) mà cố gắng bấm vào Home(0) hoặc Report(3) -> Chặn và đẩy về Inventory(1)
    if (isRestricted && (index == 0 || index == 3)) {
      selectedIndex.value = 1;
    } else {
      selectedIndex.value = index;
    }
  }

  void enforceRoleRestrictions() {
    if (isRestricted &&
        (selectedIndex.value == 0 || selectedIndex.value == 3)) {
      changeIndex(1);
    }
  }
}
