import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/infrastructure/utils/number_formatter_utils.dart';

class CurrencyFormatterUtils {
  CurrencyFormatterUtils._();

  // Danh sách các ký hiệu thường đứng trước con số (VD: $100, ¥100)
  static const List<String> _prefixSymbols = ['\$', '€', '£', '¥', '₩'];

  // Danh sách các mã tiền tệ KHÔNG dùng phần thập phân lẻ (VD: VNĐ không dùng .00)
  static const List<String> _noDecimalCurrencies = ['VND', 'JPY', 'KRW'];

  /// Format tiền tệ dạng rút gọn (VD biểu đồ: $1.2M, 500đ)
  static String formatCompact(double value) {
    final symbol = GetStorage().read('app_currency_symbol') ?? '\$';

    // Gọi NumberUtils để lấy con số đã rút gọn (VD: "-1.2M")
    String compactNumber = NumberFormatterUtils.formatCompactNumber(value);

    // Xử lý vị trí đặt ký hiệu tiền tệ
    if (_prefixSymbols.contains(symbol)) {
      if (compactNumber.startsWith('-')) {
        return '-$symbol${compactNumber.substring(1)}';
      }
      return '$symbol$compactNumber';
    } else {
      return '$compactNumber$symbol';
    }
  }

  /// Format tiền tệ đầy đủ có dấu phẩy (VD hóa đơn: $1,250,000.00 hoặc 1,250,000đ)
  static String formatFull(double value) {
    final symbol = GetStorage().read('app_currency_symbol') ?? '\$';
    final code = GetStorage().read('app_currency_code') ?? 'USD';

    String sign = value < 0 ? '-' : '';

    // Kiểm tra xem đồng tiền này có dùng số thập phân không
    bool hasDecimal = !_noDecimalCurrencies.contains(code);

    // Dùng intl để format phân cách hàng ngàn/hàng triệu (VD: 1,000,000)
    final formatter = NumberFormat(hasDecimal ? '#,##0.00' : '#,##0', 'en_US');
    String formattedNum = formatter.format(value.abs());

    if (_prefixSymbols.contains(symbol)) {
      return '$sign$symbol$formattedNum';
    } else {
      // Các đồng tiền như đ đứng sau
      return '$sign$formattedNum$symbol';
    }
  }
}
