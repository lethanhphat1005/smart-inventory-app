import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> viReorderSuggestion = {
  // Tiêu đề & Trạng thái Loading
  TTexts.reorderReportTitle: 'Báo Cáo Nhập Hàng',
  TTexts.aiAnalyzingStock: 'AI đang phân tích dữ liệu kho hàng...',

  // Trạng thái Trống (Empty State)
  TTexts.optimalStockTitle: 'Tình Trạng Kho Tối Ưu',
  TTexts.optimalStockDesc:
      'Tuyệt vời! Hiện tại không có sản phẩm nào ở mức nguy hiểm hoặc cần nhập thêm.',

  // Nhãn trên Thẻ Card
  TTexts.productLabel: 'SẢN PHẨM',
  TTexts.currentStockLabel: 'Tồn Kho Hiện Tại',
  TTexts.alertThresholdLabel: 'Ngưỡng Cảnh Báo',
  TTexts.suggestedImportLabel: 'Đề Xuất Nhập',
};
