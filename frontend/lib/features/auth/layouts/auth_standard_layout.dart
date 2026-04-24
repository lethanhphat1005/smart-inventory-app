import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Thêm thư viện quản lý System UI
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

// Đảm bảo đường dẫn này trỏ đúng vào thư mục shared của bạn
import 'package:frontend/features/auth/widgets/shared/auth_header_widget.dart';

/// Layout dùng chung cho Login, Register, Forgot Password
class AuthStandardLayout extends StatelessWidget {
  const AuthStandardLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBackButton = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Sử dụng AnnotatedRegion để ghi đè màu Status Bar riêng cho màn hình này
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors
            .transparent, // Đảm bảo nền status bar trong suốt để lộ ảnh nền
        statusBarIconBrightness:
            Brightness.light, // Icon (Pin, Wifi) màu trắng cho Android
        statusBarBrightness: Brightness.dark, // Chữ màu trắng cho iOS
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Nửa trên: Header động (Ảnh nền tràn viền lên sát mép trên)
              AuthHeaderWidget(
                title: title,
                subtitle: subtitle,
                showBackButton: showBackButton,
              ),

              // 2. Nửa dưới: Khung chứa Form với góc bo tròn lẹm lên ảnh nền
              Container(
                transform: Matrix4.translationValues(
                  0.0,
                  -20.0,
                  0.0,
                ), // Kéo UI lẹm lên 20px
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radius16),
                    topRight: Radius.circular(AppSizes.radius16),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  AppSizes.p24,
                  AppSizes.p24,
                  AppSizes.p24,
                  AppSizes.p24 + bottomPadding, // Đẩy Form lên an toàn
                ),
                child: child, // Form truyền vào sẽ nằm ở đây
              ),
            ],
          ),
        ),
      ),
    );
  }
}
