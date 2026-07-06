import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/constants/doc_strings.dart';

class LegalDocumentController extends GetxController {
  final storage = GetStorage();

  RxString content = ''.obs;
  RxBool isLoading = true.obs;

  late bool isTerms;
  late String title;

  @override
  void onInit() {
    super.onInit();
    // Lấy argument xem user đang muốn đọc Terms (true) hay Privacy (false)
    isTerms = Get.arguments?['isTerms'] ?? true;
    title = isTerms ? TTexts.termsTitle.tr : TTexts.privacyTitle.tr;
    _loadDocument();
  }

  void _loadDocument() {
    isLoading.value = true;

    // Lấy ngôn ngữ hiện tại của máy
    String langCode = storage.read('app_language') ?? 'vi';
    if (isTerms) {
      content.value = langCode == 'en'
          ? DocStrings.termsOfServiceEn
          : DocStrings.termsOfServiceVi;
    } else {
      content.value = langCode == 'en'
          ? DocStrings.privacyPolicyEn
          : DocStrings.privacyPolicyVi;
    }

    isLoading.value = false;
  }
}
