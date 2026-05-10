import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/language_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/routes/app_routes.dart';

class LanguageSelectController extends GetxController with TErrorHandler {
  final storage = GetStorage();
  RxInt selectedIndex = 0.obs;

  List<LanguageModel> get supportedLanguages => [
        LanguageModel(
          'en',
          'US',
          TTexts.settingsEnglish.tr,
          '🇺🇸',
          subName: TTexts.settingsEnglishSub.tr,
        ),
        LanguageModel(
          'vi',
          'VN',
          TTexts.settingsVietnamese.tr,
          '🇻🇳',
          subName: TTexts.settingsVietnameseSub.tr,
        ),
      ];

  void selectLanguage(int index) {
    selectedIndex.value = index;
  }

  void continueToNextScreen() {
    try {
      final selectedLang = supportedLanguages[selectedIndex.value];

      // 1. Lưu ngôn ngữ
      storage.write('app_language', selectedLang.code);

      // 2. Đánh dấu đã chọn ngôn ngữ lần đầu
      storage.write('IS_LANGUAGE_SELECTED', true);

      // 3. Cập nhật Locale ngay lập tức
      var locale = Locale(selectedLang.code, selectedLang.locale);
      Get.updateLocale(locale);

      // 4. Đi đến Onboarding
      Get.offAllNamed(AppRoutes.onboarding);
    } catch (e) {
      // Sử dụng mixin xử lý lỗi của bạn
      handleError(e);
    }
  }
}
