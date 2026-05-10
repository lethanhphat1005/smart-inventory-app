import 'package:get/get.dart';

class AppFonts {
  static String get mainFont {
    if (Get.locale?.languageCode == 'vi') {
      return 'BeVietnamPro';
    }
    return 'Poppins';
  }
}
