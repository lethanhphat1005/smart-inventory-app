import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> viHome = {
  // Tooltip
  TTexts.homeRoleOwnerTooltip: 'Quyền Chủ Sở Hữu',
  TTexts.homeRoleManagerTooltip: 'Quyền Quản Lý',
  TTexts.homeRoleStaffTooltip: 'Quyền Nhân Viên',

  // Header
  TTexts.goodMorning: 'Chào buổi sáng',
  TTexts.goodAfternoon: 'Chào buổi chiều',
  TTexts.goodEvening: 'Chào buổi tối',
  TTexts.homeDailyOverview: "Đây là tổng quan hằng ngày của bạn",

  // Revenue Chart
  TTexts.homeTodaysRevenue: "Doanh Thu Hôm Nay",
  TTexts.homeProfitLossWeek: "Lợi Nhuận/Thất Thoát (Tuần)",
  TTexts.homeVsYesterday: "so với hôm qua",
  TTexts.homeThisWeek: "tuần này",
  TTexts.homeRevenueTitle: 'Phân Tích Doanh Thu',
  TTexts.homeProfit: 'Lợi Nhuận',
  TTexts.homeLoss: 'Thất Thoát',

  // Inventory Overview
  TTexts.homeInventoryOverview: "Tổng Quan Kho Hàng",
  TTexts.homeTotalItems: "Tổng Sản Phẩm",
  TTexts.homeStockIn: "Nhập Kho",
  TTexts.homeStockOut: "Xuất Kho",
  TTexts.homeTodaysTransactions: "Giao Dịch Hôm Nay",
  TTexts.homeTapToViewMoreHistory: "Nhấn để xem thêm lịch sử",
  TTexts.homeInboundShipment: "Lô Hàng Nhập",
  TTexts.homeOutboundDelivery: "Giao Hàng Xuất",
  TTexts.homeStockAdjustment: "Điều Chỉnh Kho",

  // Quick Actions
  TTexts.homeQuickActions: "Thao Tác Nhanh",
  TTexts.homeScanBarcode: "Quét Mã Vạch",
  TTexts.homeAddProduct: "Thêm Sản Phẩm",
  TTexts.homeReorderThreshold: "Ngưỡng Đặt Hàng",
  TTexts.homeScanBarcodeSub: "Nhanh chóng xác định\nsản phẩm",
  TTexts.homeAddProductSub: "Thêm mới\nhàng tồn kho",
  TTexts.homeReorderThresholdSub: "Hướng dẫn\nđặt hàng",
  TTexts.surplus: "Dư Thừa",
  TTexts.shrinkage: "Thiếu Hụt",
  TTexts.dailyStockHealth: "Tình Trạng Kho Hàng Hằng Ngày",
  TTexts.recentAdjustments: "Điều Chỉnh Gần Đây",
  TTexts.systemAdjustment: "Điều Chỉnh Hệ Thống",
  TTexts.itemsText: "sản phẩm",

  // Low Stock Alerts
  TTexts.homeLowStockAlerts: "Cảnh Báo Tồn Kho Thấp",
  TTexts.homeItems: "sản phẩm",
  TTexts.homeOnlyLeft:
      "Chỉ còn @quantity", // Sử dụng @quantity để truyền tham số
  TTexts.homeTapToViewAll: "Nhấn để xem tất cả",
  TTexts.homeInStock: "Còn hàng",
  TTexts.homeOutOfStock: "Hết hàng",
  TTexts.overviewInfoTitle: "Hướng Dẫn Chỉ Số Tổng Quan",
  TTexts.inboundDesc: "Tổng số giao dịch nhập kho được tạo hôm nay.",
  TTexts.outboundDesc: "Tổng số giao dịch xuất kho được tạo hôm nay.",
  TTexts.adjustmentDesc:
      "Số lượng sản phẩm duy nhất được điều chỉnh trong hệ thống hôm nay.",
  TTexts.totalInDesc:
      "TỔNG SỐ LƯỢNG sản phẩm được thêm vào kho (Nhập kho + Điều chỉnh dương).",
  TTexts.totalOutDesc:
      "TỔNG SỐ LƯỢNG sản phẩm được lấy ra khỏi kho (Xuất kho + Điều chỉnh âm).",
  TTexts.adjust: "Điều Chỉnh",
  TTexts.totalIn: "TỔNG NHẬP",
  TTexts.totalOut: "TỔNG XUẤT",
  TTexts.noRecentAdjustments: "Không có điều chỉnh hôm nay",
  TTexts.homeViewAdjustments: "Điều Chỉnh",
  TTexts.homeViewAdjustmentsSub: "Theo dõi lịch sử\nkho hàng",
  TTexts.homeLowStock: "Tồn Kho Thấp",
  TTexts.homeLowStockSub: "Kiểm tra cảnh báo\nkho hàng",
  TTexts.lowStockTitle: "Cảnh Báo Tồn Kho Thấp",
  TTexts.noLowStock: "Kho Hàng Ổn Định",
  TTexts.noLowStockDesc:
      "Hiện tại không có sản phẩm nào sắp hết hàng. Làm tốt lắm!",
  TTexts.stockLeft: "Tồn Kho Còn Lại: ",

  // Adjustment History
  TTexts.adjustmentHistoryTitle: "Lịch Sử Điều Chỉnh",
  TTexts.searchAdjustmentHint: "Tìm theo tên sản phẩm hoặc ghi chú...",
  TTexts.selectDate: "Chọn Ngày",
  TTexts.clearFilter: "Xóa Bộ Lọc",
  TTexts.noAdjustmentsFound: "Không tìm thấy điều chỉnh",
  TTexts.noAdjustmentsFoundDesc:
      "Hãy thử thay đổi từ khóa tìm kiếm hoặc bộ lọc ngày.",
  TTexts.filtered: "Đã lọc:",
  TTexts.today: "Hôm nay",
  TTexts.yesterday: "Hôm qua",
  TTexts.tomorrow: 'Ngày mai',
  TTexts.note: "Ghi Chú",
  TTexts.productName: "Tên Sản Phẩm",

  // Low Stock
  TTexts.outOfStockSection: "Hết Hàng",
  TTexts.lowStockSection: "Sắp Hết",
};
