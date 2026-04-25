import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_custom_header_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:frontend/core/state/controllers/barcode_scanner_controller.dart';

class TBarcodeScannerLayout extends StatefulWidget {
  final String title;
  final Function(String code)? onScanned;
  final Widget Function(String code, VoidCallback resumeScan)?
      bottomCardBuilder;

  const TBarcodeScannerLayout({
    super.key,
    this.title = 'Bar Code Scan',
    this.onScanned,
    this.bottomCardBuilder,
  });

  @override
  State<TBarcodeScannerLayout> createState() => _TBarcodeScannerLayoutState();
}

class _TBarcodeScannerLayoutState extends State<TBarcodeScannerLayout>
    with SingleTickerProviderStateMixin {
  final BarcodeScannerController scannerController =
      Get.find<BarcodeScannerController>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    scannerController.resumeScan();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // === UI HIỂN THỊ POPUP NHẬP MÃ THỦ CÔNG (ĐÃ LÀM THANH THOÁT HƠN) ===
  void _showManualEntryDialog() {
    final TextEditingController manualController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius16)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.p20, AppSizes.p32, AppSizes.p20, AppSizes.p24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(
                        AppSizes.p12), // Giảm padding để icon bớt to
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.keyboard_alt_outlined,
                        size: 32, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // Tiêu đề
                  Text(
                    TTexts.manualBarcodeEntryTitle.tr,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                        fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 6),

                  // Mô tả
                  Text(
                    TTexts.manualBarcodeEntryDesc.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subText,
                        fontFamily: 'Poppins',
                        height: 1.3),
                  ),
                  const SizedBox(height: AppSizes.p24),

                  // Ô Nhập Text (Mỏng và phẳng hơn)
                  TextField(
                    controller: manualController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true, // Ép mỏng Textfield
                      hintText: TTexts.enterBarcodeHint.tr,
                      hintStyle: const TextStyle(
                          letterSpacing: 0,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.softGrey),
                      filled: true,
                      fillColor: AppColors.surface, // Nền xám nhạt thay vì viền
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius12),
                        borderSide: BorderSide.none, // Bỏ viền mặc định
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius12),
                        borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.2), // Viền focus mảnh
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        Get.back(); // Đóng dialog
                        if (widget.onScanned != null) {
                          widget.onScanned!(val.trim());
                        }
                      }
                    },
                  ),
                  const SizedBox(height: AppSizes.p24),

                  // Nút Xác nhận
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0, // Bỏ bóng để nút phẳng và hiện đại
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14), // Giảm độ dày nút
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius12)),
                      ),
                      onPressed: () {
                        final val = manualController.text.trim();
                        if (val.isNotEmpty) {
                          Get.back(); // Đóng dialog
                          if (widget.onScanned != null) widget.onScanned!(val);
                        }
                      },
                      child: Text(
                        TTexts.confirm.tr,
                        style: const TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Nút Tắt (X) ở góc trên
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.close,
                    color: AppColors.softGrey, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Khi đóng Dialog, mở lại camera
      scannerController.resumeScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaWidth = size.width * 0.75;
    final scanAreaHeight = size.height * 0.50;
    final scanAreaTop = (size.height - scanAreaHeight) / 2;
    const double borderRadius = 40.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera View
          MobileScanner(
            controller: scannerController.cameraController,
            onDetect: (capture) =>
                scannerController.onDetect(capture, widget.onScanned),
          ),

          // 2. Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                scanAreaWidth: scanAreaWidth,
                scanAreaHeight: scanAreaHeight,
                borderRadius: borderRadius,
              ),
            ),
          ),

          // 3. Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: TCustomHeaderWidget(
              title: widget.title,
              isDark: true,
            ),
          ),

          // 4. Laser & Bottom Card
          Obx(() {
            final isPaused = scannerController.isPaused.value;
            final code = scannerController.scannedCode.value;

            return Stack(
              children: [
                if (!isPaused)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final dy = scanAreaTop +
                          (scanAreaHeight * _animationController.value);
                      return Positioned(
                        top: dy,
                        left: (size.width - scanAreaWidth) / 2 + 5,
                        child: Container(
                          width: scanAreaWidth - 10,
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 1),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                if (isPaused &&
                    code != null &&
                    widget.bottomCardBuilder != null)
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: widget.bottomCardBuilder!(
                        code, scannerController.resumeScan),
                  ),
              ],
            );
          }),

          // 5. NÚT NHẬP MÃ THỦ CÔNG
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.keyboard_alt_outlined,
                    color: Colors.white, size: 24),
                tooltip: TTexts.manualBarcodeEntryTitle.tr,
                onPressed: () {
                  // Dừng camera trước khi mở bàn phím để tránh giật lag
                  scannerController.pauseScan();
                  _showManualEntryDialog();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === CLASS VẼ LỚP PHỦ VÀ 4 GÓC CONG KHÍT ===
class ScannerOverlayPainter extends CustomPainter {
  final double scanAreaWidth;
  final double scanAreaHeight;
  final double borderRadius;

  ScannerOverlayPainter({
    required this.scanAreaWidth,
    required this.scanAreaHeight,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final left = (size.width - scanAreaWidth) / 2;
    final top = (size.height - scanAreaHeight) / 2;
    final rect = Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.6);
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(backgroundPath, backgroundPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerSize = 40.0;

    canvas.drawPath(
        Path()
          ..moveTo(left, top + cornerSize)
          ..lineTo(left, top + borderRadius)
          ..arcTo(Rect.fromLTWH(left, top, borderRadius * 2, borderRadius * 2),
              3.14, 1.57, false)
          ..lineTo(left + cornerSize, top),
        borderPaint);

    canvas.drawPath(
        Path()
          ..moveTo(left + scanAreaWidth - cornerSize, top)
          ..lineTo(left + scanAreaWidth - borderRadius, top)
          ..arcTo(
              Rect.fromLTWH(left + scanAreaWidth - borderRadius * 2, top,
                  borderRadius * 2, borderRadius * 2),
              -1.57,
              1.57,
              false)
          ..lineTo(left + scanAreaWidth, top + cornerSize),
        borderPaint);

    canvas.drawPath(
        Path()
          ..moveTo(left, top + scanAreaHeight - cornerSize)
          ..lineTo(left, top + scanAreaHeight - borderRadius)
          ..arcTo(
              Rect.fromLTWH(left, top + scanAreaHeight - borderRadius * 2,
                  borderRadius * 2, borderRadius * 2),
              1.57,
              1.57,
              false)
          ..lineTo(left + cornerSize, top + scanAreaHeight),
        borderPaint);

    canvas.drawPath(
        Path()
          ..moveTo(left + scanAreaWidth - cornerSize, top + scanAreaHeight)
          ..lineTo(left + scanAreaWidth - borderRadius, top + scanAreaHeight)
          ..arcTo(
              Rect.fromLTWH(
                  left + scanAreaWidth - borderRadius * 2,
                  top + scanAreaHeight - borderRadius * 2,
                  borderRadius * 2,
                  borderRadius * 2),
              0.785 * 0,
              1.57,
              false)
          ..lineTo(left + scanAreaWidth, top + scanAreaHeight - cornerSize),
        borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
