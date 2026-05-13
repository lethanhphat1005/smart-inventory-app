import 'package:get/get.dart';

class NumberFormatterUtils {
  NumberFormatterUtils._();

  /// Hàm rút gọn số lượng lớn thành định dạng thân thiện (VD: 1.2M, 5k, 1.5Tr)
  /// [value]: Số cần rút gọn
  /// [isCurrency]: Bật/tắt ký hiệu tiền tệ (Mặc định thêm dấu $ ở trước)
  static String formatCompactNumber(double value, {bool isCurrency = false}) {
    // 1. Nhận diện ngôn ngữ để chọn Hậu tố (Suffix) phù hợp
    final langCode = Get.locale?.languageCode ?? 'en';

    String suffixM = 'M'; // Mặc định là tiếng Anh (Million)
    String suffixK = 'k'; // k dùng chung là ngàn

    if (langCode == 'vi') {
      suffixM = 'Tr'; // Tiếng Việt dùng Triệu
    }
    // Thêm các ngôn ngữ khác ở đây sau này nếu cần (VD: Pháp, Tây Ban Nha...)
    // else if (langCode == 'fr') { suffixM = 'M'; }

    // 2. Xử lý phần định dạng số
    double absVal = value.abs();
    String sign = value < 0 ? '-' : '';
    String prefix =
        isCurrency ? '\$' : ''; // Có thể mở rộng để đổi $ thành đ nếu cần

    String formattedValue;
    if (absVal >= 1000000) {
      formattedValue =
          '${(absVal / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}$suffixM';
    } else if (absVal >= 1000) {
      formattedValue =
          '${(absVal / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}$suffixK';
    } else {
      formattedValue = absVal.toInt().toString();
    }

    // Kết quả trả ra luôn có dạng: Dấu âm (nếu có) + Ký hiệu tiền (nếu có) + Số rút gọn
    return '$sign$prefix$formattedValue';
  }
}
