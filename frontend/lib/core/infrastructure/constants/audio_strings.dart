class TAudios {
  // Private constructor để ngăn khởi tạo
  TAudios._();

  // Barcode Scanner Sounds
  static const barcodeSounds = BarcodeSounds();
}

class BarcodeSounds {
  const BarcodeSounds();

  // LƯU Ý: Không có chữ 'assets/' ở đầu vì AssetSource đã tự động thêm vào
  final String beep = 'sounds/beep.mp3';
  final String error = 'sounds/error.mp3';
}