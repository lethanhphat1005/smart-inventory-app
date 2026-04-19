import 'package:frontend/core/infrastructure/network/app_client.dart';

class ReorderSuggestionProvider {
  final ApiClient _apiClient = ApiClient();

  Future<dynamic> getReorderSuggestions() async {
    return await _apiClient.get('/api/smart-decisions/reorder-suggestions');
  }
}