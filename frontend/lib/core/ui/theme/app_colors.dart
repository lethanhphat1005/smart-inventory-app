import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Màu chủ đạo
  static const Color primary = Color(0xFFFF8A00);
  static const Color secondPrimary = Color(0xFFFFB057);
  static const Color white = Color(0xFFFFFFFF);
  static const Color softGrey = Color(0xFF6C757D);
  static const Color divider = Color(0xFFDEDEDE);

  // Nền và Thẻ
  static const Color surface = Color(0xFFF8F9FA); // Xám nhạt
  static const Color background = Color(0xFFFFFFFF); // Trắng

  // Màu chữ
  static const Color primaryText = Color(0xFF1A1C23);
  static const Color subText = Color(0xFF6C757D);
  static const Color whiteText = Color(0xFFFFFFFF);

  // ==========================================
  // Màu Trạng thái & Gradient Dự án
  // ==========================================
  static const Color gradientOrangeStart = Color(0xFFFF8A00); // 0%
  static const Color gradientOrangeEnd = Color(0xFFFFB057); // 100%

  static const Color lightOrange =
      Color(0xFFFFE7D1); // Cam siêu nhạt (Background)
  static const Color lightOrangeGradientEnd =
      Color(0xFFFFD3A8); // Cam nhạt hơn (Gradient End)
  static const Color lightGreyBorder =
      Color.fromARGB(255, 159, 159, 159); // Xám nhạt (Border)

  static const Color gradientBlackStart = Color(0xFF000000); // 0%
  static const Color gradientBlackEnd = Color(0xFF666666); // 100%

  // Trạng thái (Nhập/Xuất, Lời/Lỗ)
  static const Color stockIn = Color(0xFF48CA93); // Xanh lá
  static const Color stockOut = Color(0xFFCA5048); // Đỏ

  // ==========================================
  // Màu Highlight Action (Dành cho các nút đặc biệt nổi bật)
  // ==========================================
  static const Color highlightAction =
      Color(0xFF3B82F6); // Xanh dương đậm (Primary Blue)
  static const Color highlightActionBg =
      Color(0xFFEFF6FF); // Xanh dương siêu nhạt (Background)
  static const Color highlightActionBorder = Color(0xFFBFDBFE);

  // ==========================================
  // Màu Toast & Snackbar (Pastel Background & Gradient Icons)
  // ==========================================

  // Nền Pastel của Snackbar (Giữ nguyên độ thanh lịch)
  static const Color toastSuccessBg = Color(0xFFECFDF5);
  static const Color toastInfoBg = Color(0xFFEFF6FF);
  static const Color toastWarningBg = Color(0xFFFFFBEB);
  static const Color toastErrorBg = Color(0xFFFEF2F2);

  // --- GRADIENT STOPS DÀNH CHO ICON BOX ---

  // Success (4EA3E0 -> 48BACA)
  static const Color toastSuccessGradientStart = Color(0xFF48CA93);
  static const Color toastSuccessGradientEnd = Color(0xFF48BACA);

  // Info (4DCAFF -> 4EA3E0)
  static const Color toastInfoGradientStart = Color(0xFF4DCAFF);
  static const Color toastInfoGradientEnd = Color(0xFF4EA3E0);

  // Warning (FFC46B -> FFA318)
  static const Color toastWarningGradientStart = Color(0xFFFFC46B);
  static const Color toastWarningGradientEnd = Color(0xFFFFA318);

  // Error (E88B76 -> CA5048)
  static const Color toastErrorGradientStart = Color(0xFFE88B76);
  static const Color toastErrorGradientEnd = Color(0xFFCA5048);

  static const Color alertBg = Color(0xFFFEF2F2); // Nền đỏ siêu nhạt
  static const Color alertText = Color(0xFFE02424); // Đỏ gắt mạnh mẽ
}
