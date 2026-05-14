import 'package:get/get.dart';
import 'package:frontend/features/inventory/controllers/inventory_controller.dart';

// Class ảo để chứa ID độc nhất tránh trùng Key khi tên Category giống nhau
class CustomizeItem {
  final String id;
  final String name;

  CustomizeItem({required this.id, required this.name});
}

class CustomizeCatalogController extends GetxController {
  final InventoryController _inventoryController =
      Get.find<InventoryController>();

  // Danh sách đang thao tác trên màn hình Customize
  final RxList<CustomizeItem> currentOrder = <CustomizeItem>[].obs;

  // Biến lưu trữ vị trí Item đang được bấm chọn để đổi chỗ
  final RxnInt selectedSwapIndex = RxnInt(null);

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo danh sách với ID độc nhất (Tên + Số thứ tự ban đầu)
    int i = 0;
    final initialList = _inventoryController.categoryStats.map((c) {
      final item = CustomizeItem(id: '${c.name}_$i', name: c.name);
      i++;
      return item;
    }).toList();

    currentOrder.assignAll(initialList);
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final tempList = currentOrder.toList();
    final item = tempList.removeAt(oldIndex);
    tempList.insert(newIndex, item);

    currentOrder.assignAll(tempList);
  }

  // Logic hoán đổi vị trí trên toàn bộ danh sách
  void handleItemTap(int index) {
    if (selectedSwapIndex.value == null) {
      // Chọn cái thứ nhất
      selectedSwapIndex.value = index;
    } else {
      // Chọn cái thứ hai
      int firstIndex = selectedSwapIndex.value!;
      int secondIndex = index;

      if (firstIndex != secondIndex) {
        // Thực hiện hoán đổi vị trí trong list tạm
        final tempList = currentOrder.toList();
        final tempItem = tempList[firstIndex];
        tempList[firstIndex] = tempList[secondIndex];
        tempList[secondIndex] = tempItem;

        // Cập nhật lại toàn bộ list để UI nhận diện thay đổi
        currentOrder.assignAll(tempList);
      }
      // Reset trạng thái sau khi thực hiện xong
      selectedSwapIndex.value = null;
    }
  }

  void saveOrder() {
    // Bóc tách lấy lại danh sách String (name) để không làm hỏng logic gốc
    final resultNames = currentOrder.map((e) => e.name).toList();
    _inventoryController.saveCustomOrder(resultNames);
    Get.back();
  }
}
