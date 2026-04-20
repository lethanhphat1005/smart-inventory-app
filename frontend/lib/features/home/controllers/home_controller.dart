import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/features/home/model/home_adjustment_model.dart';
import 'package:frontend/features/home/providers/home_provider.dart';
import 'package:frontend/features/home/widgets/shared/home_adjustment_details_bottom_sheet.dart';
import 'package:frontend/features/notification/controller/notification_controller.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/inventory_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:frontend/core/infrastructure/models/user_profile_model.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class HomeController extends GetxController with TErrorHandler {
  final HomeProvider _provider = HomeProvider();

  final RxBool isLoading = true.obs;

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<InventoryModel> lowStockItems = <InventoryModel>[].obs;
  final RxInt totalStockQuantity = 0.obs;

  final RxInt itemsLostToday = 0.obs;
  final RxInt itemsFoundToday = 0.obs;
  final RxList<HomeAdjustmentModel> todayAdjustments =
      <HomeAdjustmentModel>[].obs;

  var userProfile = Rxn<UserProfileModel>();
  final UserProfileProvider userProfileProvider = UserProfileProvider();
  final notificationController = Get.find<NotificationController>();
  RxInt unreadCount = 0.obs;

  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return TTexts.goodMorning.tr;
    if (hour < 17) return TTexts.goodAfternoon.tr;
    return TTexts.goodEvening.tr;
  }

  @override
  void onInit() {
    super.onInit();
    loadAllHomeData();
    getMyProfile();

    ever(notificationController.unreadCount, (int count) {
      unreadCount.value = count;
    });
    unreadCount.value = notificationController.unreadCount.value;
  }

  Future<void> getMyProfile() async {
    try {
      final profile = await userProfileProvider.fetchMyProfile();
      userProfile.value = profile;
    } catch (e) {
      debugPrint("Lỗi Profile: $e");
    }
  }

  Future<void> loadAllHomeData() async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        _provider.getTransactions(),
        _provider.getLowStockInventories(),
        _provider.getAllInventories(),
        _provider.getTodayAuditLogs(),
      ]);

      transactions.assignAll(results[0] as List<TransactionModel>);
      lowStockItems.assignAll(results[1] as List<InventoryModel>);

      final allInventories = results[2] as List<InventoryModel>;
      totalStockQuantity.value =
          allInventories.fold<int>(0, (sum, item) => sum + item.quantity);

      final Map<String, String> nameLookup = {};
      for (var inv in allInventories) {
        if (inv.productPackage != null) {
          nameLookup[inv.productPackageId] = inv.productPackage!.displayName;
          nameLookup[inv.inventoryId] = inv.productPackage!.displayName;
        }
      }

      final logs = results[3] as List<Map<String, dynamic>>;
      int lost = 0;
      int found = 0;
      final List<HomeAdjustmentModel> parsedAdjustments = [];

      for (var log in logs) {
        final entityType = log['entityType']?.toString().toLowerCase() ??
            log['entity_type']?.toString().toLowerCase();

        // 1. Chỉ lọc bỏ log của Transaction (vì nó ko chứa item details)
        if (entityType == 'transaction') continue;

        dynamic oldRaw = log['oldValue'] ?? log['old_value'];
        dynamic newRaw = log['newValue'] ?? log['new_value'];

        Map<String, dynamic> oldVal = {};
        Map<String, dynamic> newVal = {};

        if (oldRaw is String) {
          try {
            oldVal = jsonDecode(oldRaw);
          } catch (_) {}
        } else if (oldRaw is Map) {
          oldVal = Map<String, dynamic>.from(oldRaw);
        }

        if (newRaw is String) {
          try {
            newVal = jsonDecode(newRaw);
          } catch (_) {}
        } else if (newRaw is Map) {
          newVal = Map<String, dynamic>.from(newRaw);
        }

        // ==============================================================
        // ĐÃ FIX: KHÔNG DÙNG CONTINUE NỮA. TẤT CẢ LOG ĐỀU PHẢI ĐƯỢC HIỂN THỊ.
        // CHỈ GẮN CỜ isManual = false ĐỂ KHÔNG BỊ ĐẾM VÀO CỤC "ADJUST"
        // ==============================================================
        bool isManual = true;

        if (newVal.containsKey('transactionId') &&
            newVal['transactionId'] != null) {
          isManual = false;
        }

        final adjType =
            newVal['adjustmentType']?.toString().toLowerCase() ?? '';
        if (adjType == 'export' || adjType == 'import') {
          isManual = false;
        }

        final noteStr = log['note']?.toString().toLowerCase() ?? '';
        if (noteStr.contains('export') ||
            noteStr.contains('import') ||
            noteStr.contains('transaction')) {
          isManual = false;
        }

        int oldQty = int.tryParse(oldVal['quantity']?.toString() ?? '0') ?? 0;
        int newQty = int.tryParse(newVal['quantity']?.toString() ?? '0') ?? 0;
        int diff = newQty - oldQty;

        if (diff < 0) lost += diff.abs();
        if (diff > 0) found += diff;

        String pName = '';
        final String? pkgId = newVal['productPackageId']?.toString();
        final String? entityId =
            log['entity_id']?.toString() ?? log['entityId']?.toString();

        if (pkgId != null && nameLookup.containsKey(pkgId)) {
          pName = nameLookup[pkgId]!;
        } else if (entityId != null && nameLookup.containsKey(entityId)) {
          pName = nameLookup[entityId]!;
        } else {
          pName = log['note']?.toString().trim() ?? '';
          if (pName.isEmpty || pName == 'null') {
            pName = TTexts.systemAdjustment.tr;
          }
        }

        final dateStr = log['performedAt'] ??
            log['performed_at'] ??
            DateTime.now().toIso8601String();
        final date = DateTime.parse(dateStr).toLocal();
        final id = log['id']?.toString() ??
            log['event_id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();
        final note = log['note']?.toString() ?? '';

        // Add MỌI log vào danh sách hiển thị
        parsedAdjustments.add(HomeAdjustmentModel(
          id: id,
          productName: pName,
          oldQuantity: oldQty,
          newQuantity: newQty,
          difference: diff,
          time: date,
          note: note,
          isManual: isManual,
        ));
      }

      itemsLostToday.value = lost;
      itemsFoundToday.value = found;
      todayAdjustments.assignAll(parsedAdjustments);
    } catch (e) {
      debugPrint("Lỗi load Home Data: $e");
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ====================================
  // CÁC HÀM DOANH THU & BIỂU ĐỒ
  // ====================================
  Map<String, double> _calculateAxisLimits(List<double> values) {
    if (values.isEmpty) return {'min': -1.0, 'max': 4.0, 'interval': 1.25};
    double minVal = values.reduce(min);
    double maxVal = values.reduce(max);
    if (minVal > 0) minVal = 0;
    if (maxVal < 0) maxVal = 0;
    double amplitude = (maxVal - minVal).abs();
    if (amplitude == 0) amplitude = 1.0;
    double padding = amplitude * 0.1;
    double finalMin = (minVal - padding).floorToDouble();
    double tempMax = (maxVal + padding).ceilToDouble();
    double range = tempMax - finalMin;
    double interval = (range / 4).ceilToDouble();
    double finalMax = finalMin + (interval * 4);
    return {'min': finalMin, 'max': finalMax, 'interval': interval};
  }

  List<FlSpot> get lineChartSpots {
    final today = DateTime.now();

    Map<int, double> buckets = {};
    for (int i = 0; i <= 24; i += 2) {
      buckets[i] = 0.0;
    }

    for (var t in transactions) {
      if (t.createdAt == null) continue;
      final d = t.createdAt!.toLocal();
      if (d.year == today.year &&
          d.month == today.month &&
          d.day == today.day) {
        final amt = t.totalPrice / 1000;
        final bucketHour = (d.hour ~/ 2) * 2;
        buckets[bucketHour] = (buckets[bucketHour] ?? 0) + amt;
      }
    }

    final currentBucket = (today.hour ~/ 2) * 2;
    List<FlSpot> spots = [];
    for (int i = 0; i <= currentBucket; i += 2) {
      spots.add(FlSpot(i.toDouble(), buckets[i]!));
    }

    if (spots.isEmpty) {
      spots.add(const FlSpot(0.0, 0.0));
      spots.add(const FlSpot(2.0, 0.0));
    } else if (spots.length == 1) {
      spots.insert(0, const FlSpot(0.0, 0.0));
    }

    return spots;
  }

  Map<String, double> get lineLimits =>
      _calculateAxisLimits(lineChartSpots.map((s) => s.y).toList());

  List<double> get weeklyBarData {
    Map<int, double> daily = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    final now = DateTime.now();
    final startOfThisWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    for (var t in transactions) {
      if (t.createdAt == null) continue;
      final d = t.createdAt!.toLocal();

      if (d.isAfter(startOfThisWeek.subtract(const Duration(seconds: 1))) &&
          d.isBefore(startOfThisWeek.add(const Duration(days: 7)))) {
        daily[d.weekday] = (daily[d.weekday] ?? 0) + (t.totalPrice / 1000);
      }
    }
    return daily.values.toList();
  }

  Map<String, double> get barLimits => _calculateAxisLimits(weeklyBarData);
  double get todayRevenue => _sumRevenueByDate(DateTime.now());
  double get yesterdayRevenue =>
      _sumRevenueByDate(DateTime.now().subtract(const Duration(days: 1)));
  double get todayChangePercent =>
      _calculateChange(todayRevenue, yesterdayRevenue);
  double get thisWeekRevenue => _sumRevenueByWeek(0);
  double get lastWeekRevenue => _sumRevenueByWeek(1);
  double get weekChangePercent =>
      _calculateChange(thisWeekRevenue, lastWeekRevenue);

  double _calculateChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  double _sumRevenueByDate(DateTime date) {
    return transactions.where((t) {
      if (t.createdAt == null) return false;
      final d = t.createdAt!.toLocal();
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).fold(0.0, (sum, t) => sum + t.totalPrice);
  }

  double _sumRevenueByWeek(int weeksAgo) {
    final now = DateTime.now();
    final start =
        now.subtract(Duration(days: now.weekday - 1 + (weeksAgo * 7)));
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
    return transactions.where((t) {
      if (t.createdAt == null) return false;
      return t.createdAt!
              .toLocal()
              .isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.createdAt!.toLocal().isBefore(end);
    }).fold(0.0, (sum, t) => sum + t.totalPrice);
  }

  // ====================================
  // LOGIC ĐẾM HOẠT ĐỘNG
  // ====================================
  List<TransactionModel> get todayTransactions {
    final now = DateTime.now();
    var filteredList = transactions.where((t) {
      if (t.createdAt == null) return false;
      final d = t.createdAt!.toLocal();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
    filteredList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return filteredList;
  }

  List<TransactionModel> get recentTransactions {
    var sortedList = List<TransactionModel>.from(transactions);
    sortedList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return sortedList.take(5).toList();
  }

  int get inboundTransactionsCount {
    return todayTransactions
        .where((t) => t.type.toLowerCase() == 'import')
        .length;
  }

  int get outboundTransactionsCount {
    return todayTransactions
        .where((t) => t.type.toLowerCase() == 'export')
        .length;
  }

  int get adjustedItemsCount {
    // Đã dùng biến isManual để chỉ đếm các thay đổi làm thủ công bằng tay!
    return todayAdjustments.where((adj) => adj.isManual).length;
  }

  int get totalItemsInToday {
    return itemsFoundToday.value;
  }

  int get totalItemsOutToday {
    return itemsLostToday.value;
  }

  void goToAdjustmentHistory() {
    Get.toNamed(AppRoutes.adjustmentHistory);
  }

  void openOverviewInfo() {
    TBottomSheetWidget.show(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.softGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radius16),
            ),
            child: const Center(
              child: Text("ℹ️",
                  style: TextStyle(fontSize: 36)), // Đã trả lại Emoji
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          Text(
            TTexts.overviewInfoTitle.tr,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
                fontFamily: 'Poppins'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildInfoRow(TTexts.homeStockIn.tr, TTexts.inboundDesc.tr),
          const SizedBox(height: 16),
          _buildInfoRow(TTexts.homeStockOut.tr, TTexts.outboundDesc.tr),
          const SizedBox(height: 16),
          _buildInfoRow(TTexts.adjust.tr, TTexts.adjustmentDesc.tr),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          _buildInfoRow(TTexts.totalIn.tr, TTexts.totalInDesc.tr,
              isHighlight: true),
          const SizedBox(height: 16),
          _buildInfoRow(TTexts.totalOut.tr, TTexts.totalOutDesc.tr,
              isHighlight: true),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.softGrey.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(TTexts.goBack.tr,
                  style: const TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void openDetails(HomeAdjustmentModel model) {
    TBottomSheetWidget.show(
      child: HomeAdjustmentDetailsBottomSheet(
        icon: "📝",
        productName: model.productName,
        date: model.time,
        oldQty: model.oldQuantity,
        newQty: model.newQuantity,
        difference: model.difference,
        note: model.note,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color:
                      isHighlight ? AppColors.primaryText : AppColors.subText,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 13,
                color: isHighlight ? AppColors.primaryText : AppColors.subText,
                height: 1.4,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal),
          ),
        ),
      ],
    );
  }
}
