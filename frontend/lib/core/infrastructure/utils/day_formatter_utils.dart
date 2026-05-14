import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DayFormatterUtils {
  // 1. DÀNH CHO API (GỬI LÊN BACKEND)
  static String formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 2. CHỈ HIỂN THỊ NGÀY (Tự động thích ứng Locale)
  static String formatDate(DateTime? date, {String? format}) {
    // Nếu locale chưa có hoặc date null, trả về giá trị mặc định như Phát yêu cầu
    if (date == null) return TTexts.na.tr;

    final isVi = Get.locale?.languageCode == 'vi';

    // ĐÃ SỬA: Tiếng Việt dùng gạch chéo cho ngắn (10/05/2026), Anh dùng chữ (10 May 2026)
    final defaultFormat = isVi ? 'dd/MM/yyyy' : 'dd MMM yyyy';

    try {
      return DateFormat(format ?? defaultFormat, Get.locale?.languageCode)
          .format(date.toLocal());
    } catch (_) {
      return TTexts.na.tr; // Fallback an toàn nhất
    }
  }

  // 3. HIỂN THỊ NGÀY VÀ GIỜ (Tự động thích ứng Locale)
  static String formatDateTime(DateTime? date, {String? format}) {
    if (date == null) return TTexts.na.tr;

    final isVi = Get.locale?.languageCode == 'vi';
    final defaultFormat = isVi ? 'dd/MM/yyyy, HH:mm' : 'dd MMM yyyy, HH:mm';

    try {
      return DateFormat(format ?? defaultFormat, Get.locale?.languageCode)
          .format(date.toLocal());
    } catch (_) {
      return TTexts.na.tr;
    }
  }

  // 4. CHỈ HIỂN THỊ GIỜ 24H
  static String formatTime(DateTime? date, {String format = 'HH:mm'}) {
    if (date == null) return TTexts.na.tr;
    return DateFormat(format).format(date.toLocal());
  }
}
