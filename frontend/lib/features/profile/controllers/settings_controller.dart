import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/language_model.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/profile/providers/store_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final languageController = TextEditingController();
  final storage = GetStorage();

  final StoreService _storeService = Get.find<StoreService>();
  final StoreProvider _storeProvider = StoreProvider();

  RxString get currentUserRole => _storeService.currentRole;

  final RxList<dynamic> supportedCurrencies = <dynamic>[].obs;
  final RxBool isLoadingCurrencies = true.obs;
  final Rx<dynamic> selectedCurrency = Rx<dynamic>(null);

  List<LanguageModel> get supportedLanguages => [
        LanguageModel('vi', 'VN', TTexts.settingsVietnamese.tr, '🇻🇳'),
        LanguageModel('en', 'US', TTexts.settingsEnglish.tr, '🇺🇸'),
      ];

  @override
  void onInit() {
    super.onInit();
    _loadLanguageSettings();
    _fetchCurrenciesFromServer();

    ever(_storeService.currentCurrencyCode, (newCode) {
      if (supportedCurrencies.isNotEmpty) {
        selectedCurrency.value = supportedCurrencies.firstWhere(
          (c) => c['code'] == newCode,
          orElse: () => supportedCurrencies.first,
        );
      }
    });
  }

  void _loadLanguageSettings() {
    String? savedLang = storage.read('app_language');

    if (savedLang == 'vi') {
      languageController.text = TTexts.settingsVietnamese.tr;
    } else {
      languageController.text = TTexts.settingsEnglish.tr;
    }
  }

  Future<void> _fetchCurrenciesFromServer() async {
    try {
      isLoadingCurrencies.value = true;
      final data = await _storeProvider.getCurrencies();
      supportedCurrencies.assignAll(data);

      final currentCode = _storeService.currentCurrencyCode.value;
      if (supportedCurrencies.isNotEmpty) {
        selectedCurrency.value = supportedCurrencies.firstWhere(
          (c) => c['code'] == currentCode,
          orElse: () => supportedCurrencies.first,
        );
      }
    } catch (e) {
      debugPrint("Error fetching currency: $e");
    } finally {
      isLoadingCurrencies.value = false;
    }
  }

  Future<void> changeLanguage(LanguageModel lang) async {
    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loading.tr);
      languageController.text = lang.name;
      var locale = Locale(lang.code, lang.locale);
      await Get.updateLocale(locale);
      await Future.delayed(const Duration(milliseconds: 400));
      storage.write('app_language', lang.code);
      FullScreenLoaderUtils.stopLoading();
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      debugPrint("Error changing language: $e");
    }
  }

  Future<void> changeCurrency(dynamic currency) async {
    if (selectedCurrency.value?['code'] == currency['code']) return;

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      await _storeProvider.updateStore({'currencyCode': currency['code']});
      await _storeService.updateStoreInfo(currencyCode: currency['code']);
      selectedCurrency.value = currency;

      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.currencyUpdateSuccess.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorServerTitle.tr,
          message: TTexts.currencyUpdateFailed.tr);
    }
  }

  @override
  void onClose() {
    languageController.dispose();
    super.onClose();
  }
}
