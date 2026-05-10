import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/profile/models/language_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final languageController = TextEditingController();
  final currencyController = TextEditingController();
  final storage = GetStorage();

  // Dùng getter (=>) để mỗi khi GetX rebuild app (khi đổi ngôn ngữ),
  // nó sẽ tự động lấy bản dịch .tr mới nhất.
  List<LanguageModel> get supportedLanguages => [
        LanguageModel('vi', 'VN', TTexts.settingsVietnamese.tr, '🇻🇳'),
        LanguageModel('en', 'US', TTexts.settingsEnglish.tr, '🇺🇸'),
      ];

  // Nếu chưa cấu hình TTexts cho tiền tệ, tạm thời mình để hardcode VND/USD
  final List<String> supportedCurrencies = ['VND', 'USD'];

  @override
  void onInit() {
    super.onInit();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    // Lấy ngôn ngữ từ Local Storage, mặc định nếu không có là 'en'
    String? savedLang = storage.read('app_language');

    if (savedLang == 'vi') {
      languageController.text = TTexts.settingsVietnamese.tr;
    } else {
      languageController.text = TTexts.settingsEnglish.tr;
    }

    // Load tiền tệ hiện tại
    currencyController.text = storage.read('app_currency') ?? 'VND';
  }

  void changeLanguage(LanguageModel lang) {
    // Cập nhật text trên ô Input
    languageController.text = lang.name;

    // Cập nhật Locale của GetX
    var locale = Locale(lang.code, lang.locale);
    Get.updateLocale(locale);

    // Lưu vào bộ nhớ
    storage.write('app_language', lang.code);
  }

  void changeCurrency(String currencyName) {
    currencyController.text = currencyName;
    storage.write('app_currency', currencyName);
  }

  @override
  void onClose() {
    languageController.dispose();
    currencyController.dispose();
    super.onClose();
  }
}
