import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/features/auth/controllers/verify_otp_controller.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:get/get.dart';

class VerifyOTPBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<VerifyOtpController>(
      () => VerifyOtpController(authProvider: Get.find<AuthProvider>()),
    );
  }
}
