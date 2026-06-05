import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/features/profile/controllers/settings_controller.dart';

class CurrencyFormatterUtils {
  /// Dùng để hiển thị số đầy đủ (VD: Trang chi tiết, Header doanh thu)
  /// Ví dụ: $1,234.56 hoặc 1.234.567 đ
  static String formatFull(double amount) {
    final config = _getCurrencyConfig();

    final formatter = NumberFormat.currency(
      locale: config.locale,
      symbol: config.symbol,
      decimalDigits: config.decimals,
      customPattern:
          config.pattern, // Pattern quyết định vị trí symbol và dấu phẩy
    );

    return formatter.format(amount);
  }

  /// Dùng để hiển thị số rút gọn trên các trục của Biểu đồ
  /// Ví dụ: $1.2K hoặc 1.2M đ
  static String formatCompact(double amount) {
    final config = _getCurrencyConfig();

    final formatter = NumberFormat.compactCurrency(
      locale: config.locale,
      symbol: config.symbol,
      // Khi rút gọn K, M, T thì cho phép giữ 1 số thập phân (VD: 1.5K)
      decimalDigits: config.decimals > 0 ? 1 : 0,
    );

    String result = formatter.format(amount);

    // Mẹo nhỏ: Xử lý thêm khoảng trắng cho đẹp nếu pattern yêu cầu khoảng trắng trước ký hiệu
    if (config.pattern.endsWith(' \u00A4')) {
      // Tách số và ký hiệu ra một khoảng trắng (VD: 1.5Mđ -> 1.5M đ)
      result = result.replaceFirst(config.symbol, ' ${config.symbol}');
    }

    return result.trim();
  }

  /// Hàm nội bộ cấu hình quy tắc tiền tệ động dựa vào Settings
  static _CurrencyConfig _getCurrencyConfig() {
    String code = 'USD';
    String symbol = '\$';

    // 1. TÍNH NĂNG REACTIVE: Lấy giá trị từ SettingsController
    // Nhờ việc gọi `.value` ở đây, bất kỳ widget nào dùng Obx gọi hàm format này
    // đều sẽ tự động render lại khi tiền tệ bị thay đổi!
    if (Get.isRegistered<SettingsController>()) {
      final settings = Get.find<SettingsController>();
      code = settings.currentCurrencyCode.value;
      symbol = settings.currentCurrencySymbol.value;
    } else {
      // 2. FALLBACK: Đọc từ Storage nếu app vừa mở lên Controller chưa kịp khởi tạo
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
