import 'package:flutter/foundation.dart';
import 'package:frontend/core/infrastructure/constants/app_constants.dart';
import 'package:frontend/core/infrastructure/network/app_client.dart';
import 'package:frontend/core/state/services/notification_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider {
  final ApiClient apiClient;

  AuthProvider({required this.apiClient});

  final supabase = Supabase.instance.client;

  final String _serverClientId = AppConstants.serverClientId;

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _serverClientId,
      );

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Không tìm thấy ID Token từ Google.';
      }

      return await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } catch (e) {
      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('canceled') ||
          errorStr.contains('sign_in_canceled')) {
        debugPrint('Người dùng chủ động đóng popup chọn tài khoản Google.');
        return null;
      }

      debugPrint('Lỗi Google Sign-In thực sự: $e');
      rethrow;
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    debugPrint(
        'Đang đăng ký với email: $email và mật khẩu: ${'*' * password.length}');
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo:
          'https://smart-inventory-e3laf8xu9-suos-projects-4722ffd7.vercel.app/welcome',
    );
  }

  Future<void> sendVerificationEmail(String email) async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: 'https://smart-inventory-web-fawn.vercel.app/welcome',
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendResetPasswordEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<AuthResponse> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    debugPrint('Đang gửi OTP lên Supabase - Email: [$email] - Mã OTP: [$otp]');
    return await supabase.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.recovery,
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> logout() async {
    await NotificationService.removeTokenFromBackend();

    await Future.wait(
        [supabase.auth.signOut(), GoogleSignIn.instance.signOut()]);
  }
}
