import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import 'package:frontend/features/auth/controllers/verify_otp_controller.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/core/ui/widgets/t_image_widget.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';

class VerifyOtpMobileView extends GetView<VerifyOtpController> {
  const VerifyOtpMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Thu nhỏ kích thước ô để nhét vừa 8 số trên màn hình điện thoại
    final defaultPinTheme = PinTheme(
      width: 40, // Đã giảm từ 56 xuống 40
      height: 45, // Đã giảm từ 56 xuống 45
      textStyle: const TextStyle(
        fontSize: 18, // Giảm font size một chút
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius:
            BorderRadius.circular(8), // Bo góc nhẹ hơn cho phù hợp ô nhỏ
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 2),
      borderRadius: BorderRadius.circular(8),
    );

    // Bọc SafeArea và SingleChildScrollView để chống tràn bàn phím và đẩy layout xuống
    return SafeArea(
      child: SingleChildScrollView(
        // Thêm Padding để giao diện không bị dính sát vào mép viền
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề trang
              const Center(
                child: Text(
                  'Xác thực mã OTP',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18, // Tăng nhẹ size tiêu đề
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.p32),

              // Hình ảnh minh họa
              Center(
                child: TImageWidget(
                  image: TImages.authImages.forgotPasswordContent1,
                  height:
                      180, // Thu nhỏ ảnh lại một chút để nhường chỗ cho form
                ),
              ),

              const SizedBox(height: AppSizes.p32),

              // Thông báo gửi đến email nào
              Center(
                child: Text(
                  'Mã xác thực đã được gửi đến địa chỉ email:\n${controller.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondPrimary,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.p32),

              // Ô Nhập OTP (Pinput)
              Center(
                child: Pinput(
                  controller: controller.otpController,
                  length: 8, // SỬA THÀNH 8 SỐ Ở ĐÂY
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: (pin) => controller.verifyOtp(),
                ),
              ),

              const SizedBox(height: AppSizes.p32),

              // Khu vực đếm ngược & Gửi lại mã
              Center(
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chưa nhận được mã? ',
                        style: TextStyle(
                            color: AppColors.secondPrimary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: controller.canResend.value
                            ? controller.resendOtp
                            : null,
                        child: Text(
                          controller.canResend.value
                              ? 'Gửi lại ngay'
                              : 'Gửi lại sau (${controller.countdown.value}s)',
                          style: TextStyle(
                            color: controller.canResend.value
                                ? AppColors.primary
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.p32),

              // Nút Xác nhận
              Obx(() => TPrimaryButtonWidget(
                    text: controller.isLoading.value
                        ? 'Đang xác thực...'
                        : 'Xác nhận',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.verifyOtp,
                  )),

              const SizedBox(height: AppSizes.p16),

              // Nút Quay lại
              TPrimaryButtonWidget(
                text: 'Quay lại',
                isOutlined: true,
                textColor: AppColors.primaryText,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
