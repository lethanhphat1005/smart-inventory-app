import 'package:frontend/core/infrastructure/localization/langs/vi_vn.dart';
import 'package:get/get.dart';
import 'langs/en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'vi_VN': viVN,
      };
}
