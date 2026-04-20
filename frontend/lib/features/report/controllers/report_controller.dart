import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/utils/day_formatter_utils.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/features/report/providers/report_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ReportController extends GetxController with TErrorHandler {
  final _box = GetStorage();
  late final ReportProvider _provider;

  final RxString activeTab = 'Today'.obs;
  final RxBool isLoading = true.obs;
  final RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;

  // Chỉ thêm 2 phần này để UI Filter hết báo lỗi
  final RxString activeFilterType = 'All'.obs;
  void changeFilterType(String type) => activeFilterType.value = type;

  @override
  void onInit() {
    super.onInit();
    _provider = ReportProvider();
    activeTab.value = _box.read('report_active_tab') ?? 'Today';

    // Giữ nguyên tên gốc của bạn
    fetchTransactions();
  }

  void changeTab(String tab) {
    if (activeTab.value == tab) return;
    activeTab.value = tab;
    _box.write('report_active_tab', tab);
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  // Trả lại nguyên tên fetchTransactions và thêm param để không bị lỗi ở View
  Future<void> fetchTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
    }

    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 2, 1);
      final endDate = DateTime(now.year, now.month + 2, 0);

      final startDateStr =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final endDateStr =
          "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      final data = await _provider.getTransactions(queryParams: {
        'limit': 100,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
        'startDate': startDateStr,
        'endDate': endDateStr,
      });

      allTransactions.assignAll(data);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  List<TransactionModel> getTransactionsForDay(DateTime day) {
    return allTransactions.where((tx) {
      if (tx.createdAt == null) return false;
      return isSameDay(tx.createdAt!.toLocal(), day);
    }).toList();
  }

  // Lọc thêm theo filter để View hiển thị đúng
  List<TransactionModel> get filteredTransactions {
    final targetDay =
        activeTab.value == 'Today' ? DateTime.now() : selectedDay.value;

    final dayTransactions = getTransactionsForDay(targetDay);

    if (activeFilterType.value == 'All') {
      return dayTransactions;
    }

    return dayTransactions
        .where((tx) =>
            tx.type.toLowerCase() == activeFilterType.value.toLowerCase())
        .toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get currentDateStr {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final targetDay = activeTab.value == 'Today' ? now : selectedDay.value;

    return '${months[targetDay.month - 1]} ${targetDay.day}, ${targetDay.year}';
  }

  String get currentDayStr {
    final now = DateTime.now();
    final targetDay = activeTab.value == 'Today' ? now : selectedDay.value;
    if (isSameDay(now, targetDay)) return 'Today';
    if (isSameDay(now.subtract(const Duration(days: 1)), targetDay)) {
      return 'Yesterday';
    }

    return DayFormatterUtils.formatDate(targetDay, format: 'EEEE');
  }
}
