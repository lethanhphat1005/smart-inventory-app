import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/core/state/services/store_service.dart';

class CurrencyFormatterUtils {
  /// Dùng để hiển thị số đầy đủ (VD: Trang chi tiết, Header doanh thu)
  /// Ví dụ: $1,234.56 hoặc 1.234.567 đ
  static String formatFull(double amount) {
    final config = _getCurrencyConfig();
    int finalDecimals = config.decimals;
    if (amount % 1 != 0 && amount != 0 && config.decimals > 0) {
      finalDecimals = 2; // Giữ 2 số thập phân nếu số tiền bị lẻ
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

  /// Hàm nội bộ cấu hình quy tắc tiền tệ động dựa trên 20 loại tiền từ hệ thống
  static _CurrencyConfig _getCurrencyConfig() {
    String code = 'VND'; // Mặc định nếu không tìm thấy

    // 1. Lấy mã Tiền tệ trực tiếp từ StoreService (của Cửa hàng hiện tại)
    if (Get.isRegistered<StoreService>()) {
      final storeService = Get.find<StoreService>();
      final serviceCode = storeService.currentCurrencyCode.value;
      if (serviceCode.isNotEmpty) {
        code = serviceCode;
      }
    } else {
      // 2. Đọc từ Storage nếu app vừa mở lên Service chưa kịp khởi tạo
      final storage = GetStorage();
      final storedCode = storage.read('STORE_CURRENCY_CODE');
      if (storedCode != null && storedCode.toString().isNotEmpty) {
        code = storedCode;
      }
    }

    // 3. THIẾT LẬP QUY TẮC & KÝ HIỆU RIÊNG CHO 20 LOẠI TIỀN TỆ
    String symbol;
    int decimals;
    String locale;
    String pattern;

    switch (code) {
      case 'VND':
        symbol = '₫';
        decimals = 0;
        locale = 'vi_VN';
        pattern = '#,##0 \u00A4'; // Ký hiệu đứng sau, có cách
        break;
      case 'EUR':
        symbol = '€';
        decimals = 2;
        locale = 'de_DE';
        pattern = '#,##0.00 \u00A4';
        break;
      case 'JPY':
        symbol = '¥';
        decimals = 0;
        locale = 'ja_JP';
        pattern = '\u00A4#,##0'; // Ký hiệu đứng trước
        break;
      case 'GBP':
        symbol = '£';
        decimals = 2;
        locale = 'en_GB';
        pattern = '\u00A4#,##0.00';
        break;
      case 'AUD':
        symbol = 'A\$';
        decimals = 2;
        locale = 'en_AU';
        pattern = '\u00A4#,##0.00';
        break;
      case 'CAD':
        symbol = 'C\$';
        decimals = 2;
        locale = 'en_CA';
        pattern = '\u00A4#,##0.00';
        break;
      case 'CHF':
        symbol = 'CHF';
        decimals = 2;
        locale = 'de_CH';
        pattern = '#,##0.00 \u00A4'; // Ký hiệu đứng sau
        break;
      case 'CNY':
        symbol = '¥';
        decimals = 2;
        locale = 'zh_CN';
        pattern = '\u00A4#,##0.00';
        break;
      case 'HKD':
        symbol = 'HK\$';
        decimals = 2;
        locale = 'en_HK';
        pattern = '\u00A4#,##0.00';
        break;
      case 'NZD':
        symbol = 'NZ\$';
        decimals = 2;
        locale = 'en_NZ';
        pattern = '\u00A4#,##0.00';
        break;
      case 'KRW':
        symbol = '₩';
        decimals = 0;
        locale = 'ko_KR';
        pattern = '\u00A4#,##0';
        break;
      case 'SGD':
        symbol = 'S\$';
        decimals = 2;
        locale = 'en_SG';
        pattern = '\u00A4#,##0.00';
        break;
      case 'INR':
        symbol = '₹';
        decimals = 2;
        locale = 'en_IN';
        pattern = '\u00A4#,##0.00';
        break;
      case 'RUB':
        symbol = '₽';
        decimals = 2;
        locale = 'ru_RU';
        pattern = '#,##0.00 \u00A4'; // Đứng sau
        break;
      case 'ZAR':
        symbol = 'R';
        decimals = 2;
        locale = 'en_ZA';
        pattern = '\u00A4 #,##0.00'; // Đứng trước, có cách
        break;
      case 'BRL':
        symbol = 'R\$';
        decimals = 2;
        locale = 'pt_BR';
        pattern = '\u00A4 #,##0.00'; // Đứng trước, có cách
        break;
      case 'TWD':
        symbol = 'NT\$';
        decimals = 0; // Thường không dùng thập phân
        locale = 'zh_TW';
        pattern = '\u00A4#,##0';
        break;
      case 'THB':
        symbol = '฿';
        decimals = 2;
        locale = 'th_TH';
        pattern = '\u00A4#,##0.00';
        break;
      case 'MYR':
        symbol = 'RM';
        decimals = 2;
        locale = 'ms_MY';
        pattern = '\u00A4#,##0.00';
        break;
      case 'USD':
      default:
        symbol = '\$';
        decimals = 2;
        locale = 'en_US';
        pattern = '\u00A4#,##0.00';
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
