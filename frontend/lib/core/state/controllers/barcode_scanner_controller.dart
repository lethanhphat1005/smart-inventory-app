import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/infrastructure/constants/audio_strings.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class BarcodeScannerController extends GetxController {
  // Pattern Singleton của GetX để dễ dàng gọi ở mọi nơi: BarcodeScannerController.instance...
  static BarcodeScannerController get instance => Get.find();

  // Khởi tạo bộ nhớ Local để lưu trạng thái cài đặt
  final _storage = GetStorage();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Cấu hình Camera quét liên tục để phục vụ tính năng chống nhiễu
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.all],
  );

  // ==========================================
  // QUẢN LÝ TRẠNG THÁI (STATE)
  // ==========================================
  final RxBool isPaused = false.obs;
  final RxnString scannedCode = RxnString(null);
  final RxBool isTorchOn = false.obs;
  late RxBool isBeepOn;

  // CÁC BIẾN CỦA HỆ THỐNG CHỐNG NHIỄU (DEBOUNCE)
  String? _lastScannedCode;
  int _consecutiveReads = 0;
  DateTime? _lastReadTime;

  static const int _requiredReads = 3;
  static const int _maxTimeBetweenReadsMs = 500;

  @override
  void onInit() {
    super.onInit();
    // Đọc trạng thái âm thanh từ máy (Mặc định bật là true nếu chưa từng cài đặt)
    isBeepOn = (_storage.read<bool>('is_barcode_beep_on') ?? true).obs;
  }

  @override
  void onClose() {
    // Đảm bảo khi controller bị huỷ, biến state cũng về false
    isTorchOn.value = false;
    cameraController.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }

  // ==========================================
  // CÁC HÀM TIỆN ÍCH (ĐÈN PIN & ÂM THANH)
  // ==========================================
  void toggleTorch() {
    cameraController.toggleTorch();
    isTorchOn.toggle();
  }

  void toggleBeep() {
    isBeepOn.toggle();
    // Lưu lựa chọn của người dùng vào máy vĩnh viễn
    _storage.write('is_barcode_beep_on', isBeepOn.value);

    // Phát âm thanh báo hiệu vừa bật thành công
    if (isBeepOn.value) playSuccessSound();
  }

  // Hàm phát âm thanh + Rung chuyên dụng
  Future<void> playSuccessSound() async {
    if (isBeepOn.value) {
      HapticFeedback.lightImpact();
      await _audioPlayer.play(AssetSource(TAudios.barcodeSounds.beep));
    }
  }

  Future<void> playErrorSound() async {
    if (isBeepOn.value) {
      HapticFeedback.heavyImpact();
      await _audioPlayer.play(AssetSource(TAudios.barcodeSounds.error));
    }
  }

  // ==========================================
  // QUÉT TỪ THƯ VIỆN ẢNH
  // ==========================================
  Future<void> scanFromGallery(Function(String code)? onScannedCallback) async {
    try {
      // Dừng camera ngay lập tức để không quét nhầm nền
      pauseScan();

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final capture = await cameraController.analyzeImage(image.path);

        // Nếu ảnh có chứa mã vạch
        if (capture != null && capture.barcodes.isNotEmpty) {
          final rawValue = capture.barcodes.first.rawValue;
          if (rawValue != null) {
            scannedCode.value = rawValue;
            playSuccessSound();
            if (onScannedCallback != null) onScannedCallback(rawValue);
            return;
          }
        }

        // Báo lỗi nếu ảnh không có mã
        TSnackbarsWidget.error(
          title: TTexts.barcodeScanGalleryFailedTitle.tr,
          message: TTexts.barcodeScanGalleryFailedDesc.tr,
        );
      }
    } catch (e) {
      debugPrint("Lỗi quét ảnh: $e");
    } finally {
      // Chỉ mở lại camera nếu chưa quét được mã nào
      if (scannedCode.value == null) {
        resumeScan();
      }
    }
  }

  // ==========================================
  // BẮT MÃ VẠCH VÀ CHỐNG NHIỄU
  // ==========================================
  void onDetect(
      BarcodeCapture capture, Function(String code)? onScannedCallback) {
    if (isPaused.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;

    if (rawValue != null && rawValue.isNotEmpty) {
      final now = DateTime.now();

      // 1. Reset nếu đổi mã quá nhanh hoặc bị ngắt quãng
      if (_lastScannedCode != rawValue ||
          (_lastReadTime != null &&
              now.difference(_lastReadTime!).inMilliseconds >
                  _maxTimeBetweenReadsMs)) {
        _lastScannedCode = rawValue;
        _consecutiveReads = 1;
        _lastReadTime = now;
        return;
      }

      // 2. Tăng bộ đếm nếu mã liên tục khớp
      _consecutiveReads++;
      _lastReadTime = now;

      // 3. ĐÃ CHỐT: Đọc thành công đủ số Frame
      if (_consecutiveReads >= _requiredReads) {
        isPaused.value = true;
        scannedCode.value = rawValue;

        // Dọn dẹp bộ nhớ chống nhiễu
        _lastScannedCode = null;
        _consecutiveReads = 0;
        _lastReadTime = null;

        // Báo hiệu thành công
        playSuccessSound();

        // Tự động tắt đèn pin (để tiết kiệm pin)
        if (isTorchOn.value) {
          toggleTorch();
        }

        // Bắn dữ liệu về cho UI gọi API
        if (onScannedCallback != null) {
          onScannedCallback(rawValue);
        }
      }
    }
  }

  // ==========================================
  // QUẢN LÝ VÒNG ĐỜI CAMERA
  // ==========================================
  void resumeScan() {
    isPaused.value = false;
    scannedCode.value = null;
    isTorchOn.value = false; // Camera mặc định luôn khởi động tắt đèn

    _lastScannedCode = null;
    _consecutiveReads = 0;
    _lastReadTime = null;
  }

  // Hàm chủ động tạm dừng quét (Ví dụ: khi đang call API kiểm tra mã)
  void pauseScan() {
    isPaused.value = true;
    isTorchOn.value = false; // Ngủ thì phải tắt đèn
  }
}
