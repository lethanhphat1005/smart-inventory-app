import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_custom_header_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:frontend/core/state/controllers/barcode_scanner_controller.dart';
import 'package:frontend/core/ui/widgets/t_square_icon_button_widget.dart';

class TBarcodeScannerLayout extends StatefulWidget {
  final String title;
  final Function(String code)? onScanned;
  final Widget Function(String code, VoidCallback resumeScan)?
      bottomCardBuilder;
  final Widget? bottomBar;

  const TBarcodeScannerLayout({
    super.key,
    this.title = '',
    this.onScanned,
    this.bottomCardBuilder,
    this.bottomBar,
  });

  @override
  State<TBarcodeScannerLayout> createState() => _TBarcodeScannerLayoutState();
}

class _TBarcodeScannerLayoutState extends State<TBarcodeScannerLayout>
    with SingleTickerProviderStateMixin {
  final BarcodeScannerController scannerController =
      Get.find<BarcodeScannerController>();
  late AnimationController _animationController;

  bool _showHint = true;
  Timer? _hintTimer;

  double _currentZoom = 0.0;

  @override
  void initState() {
    super.initState();
    scannerController.resumeScan();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _hintTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _showManualEntryDialog() {
    setState(() => _showHint = false);

    final TextEditingController manualController = TextEditingController();

    Get.dialog(
      // [Phần UI Popup nhập tay]
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
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.keyboard_alt_outlined,
                        size: 32, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    TTexts.manualBarcodeEntryTitle.tr,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                        fontFamily: AppFonts.mainFont),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    TTexts.manualBarcodeEntryDesc.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subText,
                        fontFamily: AppFonts.mainFont,
                        height: 1.3),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: AppColors.primary,
                        selectionHandleColor: AppColors.primary,
                        selectionColor: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: TextField(
                      controller: manualController,
                      cursorColor: AppColors.primary,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: TTexts.enterBarcodeHint.tr,
                        hintStyle: const TextStyle(
                            letterSpacing: 0,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.softGrey),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          Get.back();
                          if (widget.onScanned != null) {
                            widget.onScanned!(val.trim());
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radius12)),
                      ),
                      onPressed: () {
                        final val = manualController.text.trim();
                        if (val.isNotEmpty) {
                          Get.back();
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
    ).then((_) => scannerController.resumeScan());
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
          // CAMERA VÀ CHỨC NĂNG ZOOM
          GestureDetector(
            onScaleUpdate: (details) {
              double newZoom = _currentZoom + (details.scale - 1.0) * 0.05;
              newZoom = newZoom.clamp(0.0, 1.0);
              scannerController.cameraController.setZoomScale(newZoom);
              _currentZoom = newZoom;
            },
            child: MobileScanner(
              controller: scannerController.cameraController,
              onDetect: (capture) {
                if (_showHint) setState(() => _showHint = false);
                scannerController.onDetect(capture, widget.onScanned);
              },
            ),
          ),

          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                scanAreaWidth: scanAreaWidth,
                scanAreaHeight: scanAreaHeight,
                borderRadius: borderRadius,
              ),
            ),
          ),

          Obx(() {
            if (scannerController.isProcessingImage.value) {
              return Container(
                color: Colors.black, // Phủ đen toàn bộ khu vực camera
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        TTexts.analyzingImageLoader.tr,
                        style: TextStyle(
                          fontFamily: AppFonts.mainFont,
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: TCustomHeaderWidget(
              title: widget.title,
              isDark: true,
              // Đẩy 4 nút vào trailingWidget
              trailingWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => TSquareIconButtonWidget(
                        icon: scannerController.isTorchOn.value
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        isActive: scannerController.isTorchOn.value,
                        onTap: () => scannerController.toggleTorch(),
                      )),
                  const SizedBox(width: 8),
                  Obx(() => TSquareIconButtonWidget(
                        icon: scannerController.isBeepOn.value
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        isActive: scannerController.isBeepOn.value,
                        onTap: () => scannerController.toggleBeep(),
                      )),
                  const SizedBox(width: 8),
                  TSquareIconButtonWidget(
                    icon: Icons.image_outlined,
                    isActive: false,
                    onTap: () =>
                        scannerController.scanFromGallery(widget.onScanned),
                  ),
                  const SizedBox(width: 8),
                  TSquareIconButtonWidget(
                    icon: Icons.keyboard_alt_outlined,
                    isActive: false,
                    onTap: () {
                      scannerController.pauseScan();
                      _showManualEntryDialog();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Laser và Bottom card
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
                    bottom: widget.bottomBar != null ? 100 : 40,
                    left: 20,
                    right: 20,
                    child: widget.bottomCardBuilder!(
                        code, scannerController.resumeScan),
                  ),
              ],
            );
          }),

          // HINT TEXT
          Positioned(
            top: scanAreaTop + scanAreaHeight + 32,
            left: 20,
            right: 20,
            child: Obx(() {
              final isPaused = scannerController.isPaused.value;

              return AnimatedOpacity(
                opacity: (_showHint && !isPaused) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  TTexts.barcodeScanHint.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }),
          ),

          if (widget.bottomBar != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: widget.bottomBar!,
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
