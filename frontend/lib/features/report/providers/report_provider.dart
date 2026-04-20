import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';

class ReportProvider {
  final _apiClient = ApiClient();

  Future<List<TransactionModel>> getTransactions(
      {Map<String, dynamic>? queryParams}) async {
    // Gọi API lấy danh sách transaction
    final response = await _apiClient.get(
      '/api/transactions',
      queryParameters: queryParams ??
          {'limit': 100, 'sortBy': 'createdAt', 'sortOrder': 'desc'},
    );

    // Bóc tách dữ liệu từ cấu trúc phân trang cuả backend
    final responseData = response.data['data'];
    List<dynamic> listData = [];

    if (responseData != null) {
      if (responseData is Map && responseData.containsKey('items')) {
        listData = responseData['items'];
      } else if (responseData is List) {
        listData = responseData;
      }
    } else if (response.data is List) {
      listData = response.data;
    }

    return listData.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<TransactionModel> getTransactionById(String transactionId) async {
    final response = await _apiClient.get('/api/transactions/$transactionId');
    final data = response.data['data'] ?? response.data;
    return TransactionModel.fromJson(data);
  }
}
