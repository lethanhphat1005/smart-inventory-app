// lib/core/widgets/t_barcode_scanner_layout.dart
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaWidth = size.width * 0.75;
    final scanAreaHeight = size.height * 0.50;
    final scanAreaTop = (size.height - scanAreaHeight) / 2;
    const double borderRadius = 40.0; // Độ cong của khung

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera View
          MobileScanner(
            controller: scannerController.cameraController,
            onDetect: (capture) =>
                scannerController.onDetect(capture, widget.onScanned),
          ),

          // 2. Overlay & 4 góc cong (Vẽ chuẩn xác)
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                scanAreaWidth: scanAreaWidth,
                scanAreaHeight: scanAreaHeight,
                borderRadius: borderRadius,
              ),
            ),
          ),

          // 3. FIX HEADER: Dùng Positioned để đè lên trên cùng
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Cách mép trên chuẩn
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.keyboard, color: Colors.white),
              onPressed: () {
                // Dừng camera để tránh loạn
                scannerController.pauseScan();
                Get.defaultDialog(
                  title: "Test Emulator",
                  content: TextField(
                    decoration:
                        const InputDecoration(hintText: "Nhập mã barcode..."),
                    onSubmitted: (val) {
                      Get.back();
                      if (widget.onScanned != null) widget.onScanned!(val);
                    },
                  ),
                );
              },
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

    // 1. Vẽ lớp nền tối mờ
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.6);
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(backgroundPath, backgroundPaint);

    // 2. Vẽ 4 góc trắng (Sử dụng Arc để bo theo khung)
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerSize = 40.0; // Độ dài của đoạn kẻ ở góc

    // --- Góc Top Left ---
    canvas.drawPath(
        Path()
          ..moveTo(left, top + cornerSize)
          ..lineTo(left, top + borderRadius)
          ..arcTo(Rect.fromLTWH(left, top, borderRadius * 2, borderRadius * 2),
              3.14, 1.57, false)
          ..lineTo(left + cornerSize, top),
        borderPaint);

    // --- Góc Top Right ---
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

    // --- Góc Bottom Left ---
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

    // --- Góc Bottom Right ---
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
