import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerController extends GetxController {
  // Pattern Singleton của GetX để dễ dàng gọi ở mọi nơi: BarcodeScannerController.instance...
  static BarcodeScannerController get instance => Get.find();

  // Khởi tạo máy quét
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.all],
  );

  // Trạng thái Rx để UI tự động cập nhật
  final RxBool isPaused = false.obs;
  final RxnString scannedCode = RxnString(null);
  final RxBool isTorchOn = false.obs;

  String? _lastScannedCode;
  int _consecutiveReads = 0;
  DateTime? _lastReadTime;

  static const int _requiredReads = 3;
  static const int _maxTimeBetweenReadsMs = 500;

  @override
  void onClose() {
    // ĐÃ THÊM: Đảm bảo khi controller bị huỷ, biến state cũng về false
    isTorchOn.value = false;
    cameraController.dispose();
    super.onClose();
  }

  void toggleTorch() {
    cameraController.toggleTorch();
    isTorchOn.toggle();
  }

  void onDetect(
      BarcodeCapture capture, Function(String code)? onScannedCallback) {
    if (isPaused.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;

    if (rawValue != null && rawValue.isNotEmpty) {
      final now = DateTime.now();

      if (_lastScannedCode != rawValue ||
          (_lastReadTime != null &&
              now.difference(_lastReadTime!).inMilliseconds >
                  _maxTimeBetweenReadsMs)) {
        _lastScannedCode = rawValue;
        _consecutiveReads = 1;
        _lastReadTime = now;
        return;
      }

      _consecutiveReads++;
      _lastReadTime = now;

      if (_consecutiveReads >= _requiredReads) {
        isPaused.value = true;
        scannedCode.value = rawValue;

        _lastScannedCode = null;
        _consecutiveReads = 0;
        _lastReadTime = null;

        // Reset đèn về false khi quét xong (vì camera sắp bị pause)
        isTorchOn.value = false;

        // Gọi callback trả về cho UI nếu có
        if (onScannedCallback != null) {
          onScannedCallback(rawValue);
        }
      }
    }
  }

  // Hàm để UI hoặc các service khác gọi khi muốn tiếp tục quét mã mới
  void resumeScan() {
    isPaused.value = false;
    scannedCode.value = null;
    isTorchOn.value = false;

    _lastScannedCode = null;
    _consecutiveReads = 0;
    _lastReadTime = null;
  }

  // Hàm chủ động tạm dừng quét (Ví dụ: khi đang call API kiểm tra mã)
  void pauseScan() {
    isPaused.value = true;
    // Khi pause cũng nên coi như đèn đã tắt
    isTorchOn.value = false;
  }
}
