import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/features/profile/controllers/settings_controller.dart';

class CurrencyFormatterUtils {
  /// Dùng để hiển thị số đầy đủ (VD: Trang chi tiết, Header doanh thu)
  /// Ví dụ: $1,234.56 hoặc 1.234.567 đ
  static String formatFull(double amount) {
    final config = _getCurrencyConfig();
    int finalDecimals = config.decimals;
    if (amount % 1 != 0 && amount != 0) {
      finalDecimals = 2;
    }

    final formatter = NumberFormat.currency(
      locale: config.locale,
      symbol: config.symbol,
      decimalDigits: finalDecimals,
      customPattern: config.pattern,
    );

    return formatter.format(amount);
  }

  /// Ví dụ: $40K, 40K đ, 40K €
  static String formatCompact(double amount) {
    final config = _getCurrencyConfig();

    // 1. Ép dùng chuẩn 'en_US' để LUÔN LUÔN rút gọn thành K, M, B (Bất chấp mọi loại tiền)
    final formatter = NumberFormat.compact(locale: 'en_US');
    formatter.maximumFractionDigits = 1;
    String compactNumber = formatter.format(amount);

    // 2. Tự động ghép ký hiệu tiền tệ vào đúng vị trí dựa theo Pattern
    if (config.pattern.startsWith('\u00A4')) {
      // Ký hiệu đứng TRƯỚC (VD: $40K, ¥40K)
      bool hasSpace = config.pattern.startsWith('\u00A4 ');
      return '${config.symbol}${hasSpace ? ' ' : ''}$compactNumber';
    } else {
      // Ký hiệu đứng SAU (VD: 40K đ, 40K €)
      bool hasSpace = config.pattern.endsWith(' \u00A4');
      return '$compactNumber${hasSpace ? ' ' : ''}${config.symbol}';
    }
  }

  /// Hàm nội bộ cấu hình quy tắc tiền tệ động dựa vào Settings
  static _CurrencyConfig _getCurrencyConfig() {
    String code = 'USD';
    String symbol = '\$';

    // 1. Lấy giá trị từ SettingsController
    // Nhờ việc gọi `.value` ở đây, bất kỳ widget nào dùng Obx gọi hàm format này
    // đều sẽ tự động render lại khi tiền tệ bị thay đổi!
    if (Get.isRegistered<SettingsController>()) {
      final settings = Get.find<SettingsController>();
      code = settings.currentCurrencyCode.value;
      symbol = settings.currentCurrencySymbol.value;
    } else {
      // 2. Đọc từ Storage nếu app vừa mở lên Controller chưa kịp khởi tạo
      final storage = GetStorage();
      code = storage.read('app_currency_code') ?? 'USD';
      symbol = storage.read('app_currency_symbol') ?? '\$';
    }

    // 3. THIẾT LẬP QUY TẮC RIÊNG CHO TỪNG QUỐC GIA
    int decimals = 2;
    String locale = 'en_US';
    String pattern =
        '\u00A4#,##0.00'; // \u00A4 là biểu tượng tiền tệ (Symbol đứng trước)

    switch (code) {
      case 'VND':
        decimals = 0; // VNĐ không có số thập phân
        locale = 'vi_VN';
        pattern = '#,##0 \u00A4'; // Symbol đứng sau, có khoảng trắng
        break;
      case 'EUR':
        decimals = 2;
        locale = 'de_DE'; // Dùng chuẩn Đức/Pháp cho chuẩn dấu phẩy châu Âu
        pattern = '#,##0.00 \u00A4'; // Symbol đứng sau, có khoảng trắng
        break;
      case 'JPY':
      case 'KRW':
        decimals = 0; // Yên và Won thường không dùng thập phân
        locale = 'en_US';
        pattern = '\u00A4#,##0'; // Symbol đứng trước
        break;
      case 'CNY':
        decimals = 2;
        locale = 'zh_CN';
        pattern = '\u00A4#,##0.00'; // Symbol đứng trước
        break;
      case 'GBP':
        decimals = 2;
        locale = 'en_GB';
        pattern = '\u00A4#,##0.00'; // Symbol đứng trước
        break;
    }

    return _CurrencyConfig(code, symbol, decimals, locale, pattern);
  }
}

/// Class cấu hình nội bộ
class _CurrencyConfig {
  final String code;
  final String symbol;
  final int decimals;
  final String locale;
  final String pattern;

  _CurrencyConfig(
      this.code, this.symbol, this.decimals, this.locale, this.pattern);
}
