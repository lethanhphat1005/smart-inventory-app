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

      // 6. Tắt loader - Lúc này UI đã ổn định hoàn toàn với font mới
      FullScreenLoaderUtils.stopLoading();
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      // Sử dụng TErrorHandler nếu bạn đã mixin nó vào
      debugPrint("Lỗi đổi ngôn ngữ: $e");
    }
  }

  @override
  void onClose() {
    languageController.dispose();
    currencyController.dispose();
    super.onClose();
  }
}
