import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enReorderSuggestion = {
  // Tiêu đề & Trạng thái Loading
  TTexts.reorderReportTitle: 'Restock Report',
  TTexts.aiAnalyzingStock: 'AI is analyzing inventory data...',

  // Trạng thái Trống (Empty State)
  TTexts.optimalStockTitle: 'Optimal Inventory Status',
  TTexts.optimalStockDesc:
      'Great! No products are at critical levels or require restocking right now.',

  // Nhãn trên Thẻ Card
  TTexts.productLabel: 'PRODUCT',
  TTexts.currentStockLabel: 'Current Stock',
  TTexts.alertThresholdLabel: 'Alert Threshold',
  TTexts.suggestedImportLabel: 'Suggested Import',
};
