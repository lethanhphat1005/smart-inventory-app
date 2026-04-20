import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DayFormatterUtils {
  // 1. DÀNH CHO API (GỬI LÊN BACKEND)
  static String formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 2. CHỈ HIỂN THỊ NGÀY (VD: 17 Apr 2026)
  static String formatDate(DateTime? date, {String format = 'dd MMM yyyy'}) {
    if (date == null) return TTexts.na.tr;
    return DateFormat(format).format(date.toLocal());
  }

  // 3. HIỂN THỊ NGÀY VÀ GIỜ 24H (VD: 17 Apr 2026, 17:29)
  static String formatDateTime(DateTime? date,
      {String format = 'dd MMM yyyy, HH:mm'}) {
    if (date == null) return TTexts.na.tr;
    return DateFormat(format).format(date.toLocal());
  }

  // 4. CHỈ HIỂN THỊ GIỜ 24H (VD: 17:29)
  static String formatTime(DateTime? date, {String format = 'HH:mm'}) {
    if (date == null) return TTexts.na.tr;
    return DateFormat(format).format(date.toLocal());
  }
}
