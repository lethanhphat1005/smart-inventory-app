import 'package:frontend/core/infrastructure/models/reorder_suggestion_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/features/notification/providers/reorder_suggestion_provider.dart';
import 'package:get/get.dart';

class ReorderSuggestionController extends GetxController with TErrorHandler {
  final ReorderSuggestionProvider _provider = ReorderSuggestionProvider();
  final storeService = Get.find<StoreService>();

  final RxBool isLoading = true.obs;
  final RxList<ReorderSuggestionModel> suggestions =
      <ReorderSuggestionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    try {
      isLoading.value = true;
      final String currentStoreId = storeService.currentStoreId.value;
      if (currentStoreId.isEmpty) return;

      final response = await _provider.getReorderSuggestions();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data['data'] ?? [];
        suggestions.value =
            data.map((json) => ReorderSuggestionModel.fromJson(json)).toList();
      }
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void dismissSuggestion(String productId) {
    suggestions.removeWhere((item) => item.productId == productId);
  }
}
