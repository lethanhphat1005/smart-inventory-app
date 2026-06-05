import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/language_model.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final languageController = TextEditingController();
  final currencyController = TextEditingController();
  final storage = GetStorage();

  final RxString currentUserRole = 'manager'.obs;
  final RxString currentCurrencySymbol = '\$'.obs;
  final RxString currentCurrencyCode = 'USD'.obs;

  List<LanguageModel> get supportedLanguages => [
        LanguageModel('vi', 'VN', TTexts.settingsVietnamese.tr, '🇻🇳'),
        LanguageModel('en', 'US', TTexts.settingsEnglish.tr, '🇺🇸'),
      ];

  // ĐÃ SỬA: Bổ sung thêm EUR, GBP, JPY, CNY, KRW
  List<Map<String, String>> get supportedCurrencies => [
        {'code': 'USD', 'symbol': '\$', 'name': TTexts.currencyUSD.tr},
        {'code': 'VND', 'symbol': 'đ', 'name': TTexts.currencyVND.tr},
        {'code': 'EUR', 'symbol': '€', 'name': TTexts.currencyEUR.tr},
        {'code': 'GBP', 'symbol': '£', 'name': TTexts.currencyGBP.tr},
        {'code': 'JPY', 'symbol': '¥', 'name': TTexts.currencyJPY.tr},
        {
          'code': 'CNY',
          'symbol': '¥',
          'name': TTexts.currencyCNY.tr
        }, // CNY và JPY đều dùng chung icon ¥
        {'code': 'KRW', 'symbol': '₩', 'name': TTexts.currencyKRW.tr},
      ];

  @override
  void onInit() {
    super.onInit();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    // 1. Load Language
    String? savedLang = storage.read('app_language');

    if (savedLang == 'vi') {
      languageController.text = TTexts.settingsVietnamese.tr;
    } else {
      languageController.text = TTexts.settingsEnglish.tr;
    }

    // 2. Load Currency (Mặc định là USD nếu chưa có)
    String savedCurrencyCode = storage.read('app_currency_code') ?? 'USD';
    String savedCurrencySymbol = storage.read('app_currency_symbol') ?? '\$';

    currentCurrencyCode.value = savedCurrencyCode;
    currentCurrencySymbol.value = savedCurrencySymbol;

    final currency = supportedCurrencies.firstWhere(
        (c) => c['code'] == savedCurrencyCode,
        orElse: () => supportedCurrencies[0]);
    currencyController.text = currency['name']!;
  }

  Future<void> changeLanguage(LanguageModel lang) async {
    try {
      // 1. Hiện loader để che đi quá trình UI bị giật khi đổi font
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loading.tr);

      // 2. Cập nhật text trên ô Input
      languageController.text = lang.name;

      // 3. Cập nhật Locale của GetX
      var locale = Locale(lang.code, lang.locale);
      await Get.updateLocale(locale);

      // 4. Đợi khoảng 300-500ms để Flutter engine nạp xong font BeVietnamPro vào cache
      // và tính toán lại layout xong xuôi.
      await Future.delayed(const Duration(milliseconds: 400));

      // 5. Lưu vào bộ nhớ
      storage.write('app_language', lang.code);

      // Cập nhật lại tên tiền tệ hiển thị trên Input ngay khi đổi ngôn ngữ
      final currency = supportedCurrencies.firstWhere(
          (c) => c['code'] == currentCurrencyCode.value,
          orElse: () => supportedCurrencies[0]);
      currencyController.text = currency['name']!;

      FullScreenLoaderUtils.stopLoading();
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      // Sử dụng TErrorHandler nếu bạn đã mixin nó vào
      debugPrint("Lỗi đổi ngôn ngữ: $e");
    }
  }

  Future<void> changeCurrency(Map<String, String> currency) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loading.tr);

      currencyController.text = currency['name']!;
      currentCurrencyCode.value = currency['code']!;
      currentCurrencySymbol.value = currency['symbol']!;

      storage.write('app_currency_code', currency['code']);
      storage.write('app_currency_symbol', currency['symbol']);

      await Future.delayed(const Duration(milliseconds: 300));
      FullScreenLoaderUtils.stopLoading();
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
    }
  }

  @override
  void onClose() {
    languageController.dispose();
    currencyController.dispose();
    super.onClose();
  }
}
