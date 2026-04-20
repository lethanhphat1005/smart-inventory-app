import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enHome = {
  // Tooltip
  TTexts.homeRoleOwnerTooltip: 'Owner Access',
  TTexts.homeRoleManagerTooltip: 'Manager Access',
  TTexts.homeRoleStaffTooltip: 'Staff Access',

  // Header
  TTexts.goodMorning: 'Good morning',
  TTexts.goodAfternoon: 'Good afternoon',
  TTexts.goodEvening: 'Good evening',
  TTexts.homeDailyOverview: "Here's your daily overview",

  // Revenue Chart
  TTexts.homeTodaysRevenue: "Today's Revenue",
  TTexts.homeProfitLossWeek: "Profit/Loss (Week)",
  TTexts.homeVsYesterday: "vs yesterday",
  TTexts.homeThisWeek: "this week",
  TTexts.homeRevenueTitle: 'Revenue Analytics',
  TTexts.homeProfit: 'Profit',
  TTexts.homeLoss: 'Loss',

  // Inventory Overview
  TTexts.homeInventoryOverview: "Inventory Overview",
  TTexts.homeTotalItems: "Total Items",
  TTexts.homeStockIn: "Stock In",
  TTexts.homeStockOut: "Stock Out",
  TTexts.homeTodaysTransactions: "Today's Transactions",
  TTexts.homeTapToViewMoreHistory: "Tap to view more history",
  TTexts.homeInboundShipment: "Inbound Shipment",
  TTexts.homeOutboundDelivery: "Outbound Delivery",
  TTexts.homeStockAdjustment: "Stock Adjustment",

  // Quick Actions
  TTexts.homeQuickActions: "Quick Actions",
  TTexts.homeScanBarcode: "Scan Barcode",
  TTexts.homeAddProduct: "Add Product",
  TTexts.homeViewReports: "View Reports",
  TTexts.homeScanBarcodeSub: "Quickly identify\nitems",
  TTexts.homeAddProductSub: "Add new\ninventory",
  TTexts.homeViewReportsSub: "Analyze daily\nsales",
  TTexts.surplus: "Surplus",
  TTexts.shrinkage: "Shrinkage",
  TTexts.dailyStockHealth: "Daily Stock Health",
  TTexts.recentAdjustments: "Recent Adjustments",
  TTexts.systemAdjustment: "System Adjustment",
  TTexts.itemsText: "items",

  // Low Stock Alerts
  TTexts.homeLowStockAlerts: "Low Stock Alerts",
  TTexts.homeItems: "items",
  TTexts.homeOnlyLeft:
      "Only @quantity left", // Sử dụng @quantity để truyền tham số
  TTexts.homeTapToViewAll: "Tap to view all",
  TTexts.homeInStock: "In stock",
  TTexts.homeOutOfStock: "Ouf of stock",
  TTexts.overviewInfoTitle: "Overview Metrics Guide",
  TTexts.inboundDesc: "Total number of Inbound transactions created today.",
  TTexts.outboundDesc: "Total number of Outbound transactions created today.",
  TTexts.adjustmentDesc: "Number of unique items adjusted in the system today.",
  TTexts.totalInDesc:
      "Total QUANTITY of items added to inventory (Inbound + Positive Adjustments).",
  TTexts.totalOutDesc:
      "Total QUANTITY of items removed from inventory (Outbound + Negative Adjustments).",
  TTexts.adjust: "Adjust",
  TTexts.totalIn: "TOTAL IN",
  TTexts.totalOut: "TOTAL OUT",
  TTexts.noRecentAdjustments: "No adjustments today",
  TTexts.homeViewAdjustments: "Adjustments",
  TTexts.homeViewAdjustmentsSub: "Track stock\nhistory",
  TTexts.homeLowStock: "Low Stock",
  TTexts.homeLowStockSub: "Check inventory\nalerts",
  TTexts.lowStockTitle: "Low Stock Alerts",
  TTexts.noLowStock: "Stock is Healthy",
  TTexts.noLowStockDesc:
      "There are currently no items running low in stock. Great job!",
  TTexts.stockLeft: "Stock Left: ",

  // Adjustment History
  TTexts.adjustmentHistoryTitle: "Adjustment History",
  TTexts.searchAdjustmentHint: "Search by product name or note...",
  TTexts.selectDate: "Select Date",
  TTexts.clearFilter: "Clear Filter",
  TTexts.noAdjustmentsFound: "No adjustments found",
  TTexts.noAdjustmentsFoundDesc: "Try adjusting your search or date filter.",
  TTexts.filtered: "Filtered:",
  TTexts.today: "Today",
  TTexts.yesterday: "Yesterday",
  TTexts.note: "Note",
  TTexts.productName: "Product Name",

  // Low Stock
  TTexts.outOfStockSection: "Out of Stock",
  TTexts.lowStockSection: "Running Low",
};
