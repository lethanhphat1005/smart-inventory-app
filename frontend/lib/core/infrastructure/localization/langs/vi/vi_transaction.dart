import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> viTransaction = {
  TTexts.createNewTransaction: "Tạo Giao Dịch Mới",
  TTexts.manageInventory: "Quản Lý Kho",
  TTexts.manageInventoryDesc:
      "Ghi nhận hàng nhập, hàng xuất hoặc điều chỉnh tồn kho hiện tại.",
  TTexts.inbound: "Nhập Kho",
  TTexts.outbound: "Xuất Kho",
  TTexts.stockAdjustment: "Điều Chỉnh Kho",
  TTexts.exit: "Thoát",
  TTexts.searchingProduct: "Đang tìm sản phẩm...",
  TTexts.unconfirmedBarcodeTitle: "Mã Vạch Chưa Xác Nhận",
  TTexts.unconfirmedBarcodeMessage:
      "Đã tìm thấy sản phẩm nhưng chưa được ánh xạ đúng. Vui lòng xác minh bên ngoài.",
  TTexts.barcodeNotFoundMessage: "Mã vạch không tồn tại trong hệ thống!",
  TTexts.errorProcessingBarcode: "Lỗi xử lý mã vạch",
  TTexts.tReason: "Lý Do",
  TTexts.updatePriceAndImport: "Cập Nhật & Nhập Kho",
  TTexts.importOnly: "Chỉ Nhập Kho",
  TTexts.confirmImportDesc:
      "Bạn có chắc muốn hoàn tất giao dịch nhập kho này không?",
  TTexts.sellingPriceChangeDetectedDesc:
      "Một số sản phẩm có giá bán khác với danh mục chính. Bạn có muốn cập nhật giá mặc định cho các giao dịch sau không?",
  TTexts.updatePriceAndExport: "Cập Nhật & Xuất Kho",
  TTexts.exportOnly: "Chỉ Xuất Kho",
  TTexts.confirmExportDesc:
      "Bạn có chắc muốn hoàn tất giao dịch xuất kho này không?",
  TTexts.significantChangeDetected: "Phát Hiện Thay Đổi Lớn",
  TTexts.highQtyFluctuationDesc:
      "Các sản phẩm sau có biến động số lượng lớn (>= 10 đơn vị):",
  TTexts.priceFluctuationDesc: "Các sản phẩm sau có thay đổi về giá.",
  TTexts.andMore: "và nhiều hơn nữa...",
  TTexts.removeProductTitle: "Xóa Sản Phẩm",
  TTexts.removeProductDesc:
      "Bạn có chắc chắn muốn xóa sản phẩm này khỏi giao dịch không?",
  TTexts.maxQuantityReached: "Đã đạt giới hạn số lượng tối đa",
  TTexts.maxStockReached: "Đã đạt giới hạn tồn kho hiện tại",
  TTexts.quickAddProducts: "Thêm nhanh sản phẩm",
  TTexts.quickAddProductsSubtitle:
      "Chọn hàng loạt sản phẩm từ danh mục có sẵn để tiết kiệm thời gian.",
  TTexts.selectProductsTitle: "Chọn Nhanh Sản Phẩm",
  TTexts.searchProductNameHint: "Tìm kiếm theo tên sản phẩm...",
  TTexts.allItems: "Tất cả",
  TTexts.discardSelectionTitle: "Hủy bỏ lựa chọn?",
  TTexts.discardSelectionDesc:
      "Bạn đã chọn một số sản phẩm. Nếu thoát bây giờ, các sản phẩm này sẽ không được thêm vào giỏ hàng. Thoát?",
  TTexts.selectedItems: "Hàng hóa đã chọn",
  TTexts.confirmSelection: "Xác Nhận",
  TTexts.searchStandardHint: "Nhập tên sản phẩm để tìm kiếm...",
  TTexts.labelItemsCount: "món",
  TTexts.errorInvalidPackageId:
      "Không tìm thấy mã lô hàng (Package ID) hợp lệ.",
  TTexts.productBarcodes: "Mã vạch sản phẩm",
  TTexts.noBarcodesFound: "Sản phẩm này hiện chưa có mã vạch nào.",
  TTexts.absoluteMaxQuantity: "Số lượng tối đa là 999,999",
  TTexts.overflowLimitTitle: "Vượt quá giới hạn",
  TTexts.overflowLimitDesc:
      "Một số sản phẩm khi cộng dồn với giỏ hàng sẽ vượt mức tối đa 999,999. Bạn muốn xử lý thế nào?",
  TTexts.capAtMaxBtn: "Cộng đến mức tối đa",
  TTexts.addValidOnlyBtn: "Chỉ thêm sản phẩm hợp lệ",
  TTexts.reviewAgainBtn: "Quay lại kiểm tra",
  TTexts.recentActivities: "Hoạt động gần đây",
  TTexts.priorityList: "Ưu tiên (Hết/Sắp hết)",
  TTexts.addAllPriority: "Thêm tất cả ưu tiên",
  TTexts.scanBarcodeShortcut: "Quét mã vạch",
  TTexts.allProducts: "Tất cả sản phẩm",
  TTexts.stableInventoryMsg: "Kho đang ổn định, không có món cần ưu tiên!",
  TTexts.addedPrioritySuccessMsg: "Đã thêm các món cạn kho vào giỏ",
  TTexts.allPriorityInCartMsg: "Các món ưu tiên đều đã có trong giỏ",
  TTexts.selectedText: "Đã chọn",
  TTexts.checkingInventory: "Đang kiểm tra kho...",
  TTexts.options: "Tùy chọn",
  TTexts.confirmAddPriorityTitle: "Xác nhận thêm ưu tiên",
  TTexts.confirmAddPriorityDesc: "Hệ thống sẽ tự động tính toán và thêm các sản phẩm đang dưới ngưỡng an toàn vào giỏ hàng. Bạn có chắc chắn muốn thực hiện?",
  TTexts.allPrioritySatisfied: "Tất cả sản phẩm ưu tiên đã có trong giỏ hàng hoặc đạt mức an toàn.",

  // -- Inbound
  TTexts.inboundTransaction: "Giao Dịch Nhập Kho",
  TTexts.emptyInboundCartTitle: "Chưa có sản phẩm nào",
  TTexts.emptyInboundCartSub:
      "Quét mã vạch hoặc nhấn thanh tìm kiếm để thêm sản phẩm vào giao dịch này.",
  TTexts.completeImport: "Hoàn Tất Nhập Kho",
  TTexts.totalFunds: "Tổng tiền",
  TTexts.searchProductToAdd: "Tìm sản phẩm để thêm...",
  TTexts.emptyTransactionTitle: "Chưa có sản phẩm nào",
  TTexts.emptyTransactionSubtitle:
      "Quét mã vạch hoặc nhấn thanh tìm kiếm để thêm sản phẩm vào giao dịch này.",
  TTexts.transactionCompletedTitle: "Hoàn Tất Giao Dịch!",
  TTexts.transactionCompletedSubtitle:
      "Giao dịch của bạn đã được xử lý và lưu thành công.",
  TTexts.backToHome: "Quay Về Trang Chủ",
  TTexts.scanProductBarcode: "Quét Mã Vạch Sản Phẩm",
  TTexts.confirmImportTitle: "Xác Nhận Nhập Kho",
  TTexts.confirmImportDescription:
      "Bạn có chắc muốn hoàn tất giao dịch nhập kho này không? Hành động này sẽ thêm hàng vào kho.",
  TTexts.proceedImport: "Xác Nhận & Nhập Kho",

  // -- Outbound
  TTexts.outboundTransactionTitle: 'Giao Dịch Xuất Kho',
  TTexts.searchDot: 'Tìm kiếm ...',
  TTexts.completeExport: 'Hoàn Tất Xuất Kho',
  TTexts.stocksLabel: 'Tồn kho:',
  TTexts.outOfStockAlert: 'Không đủ tồn kho!',
  TTexts.outOfStockTitle: "Hết Hàng!",
  TTexts.outOfStockDesc:
      "Một số sản phẩm trong giỏ hàng không còn đủ số lượng do thay đổi tồn kho gần đây. Chúng đã được cập nhật hoặc xóa khỏi giỏ.",
  TTexts.actualStock: "Tồn kho thực tế",
  TTexts.autoRemovedFromCart: "Tự động xóa khỏi giỏ hàng",
  TTexts.updatedListLabel: "Danh sách đã cập nhật:",
  TTexts.clearStock: "Xóa Tồn Kho",
  TTexts.clearAllStock: "Xóa Toàn Bộ Tồn Kho",
  TTexts.productHasRemainingStock:
      "Sản phẩm này vẫn còn tồn kho trong các gói hàng. Bạn cần xóa tồn kho trước khi xóa sản phẩm.",
  TTexts.autoGeneratedClearanceNote:
      "Giao dịch tự động tạo để xóa tồn kho trước khi xóa sản phẩm.",
  TTexts.outboundOverflowLimitDesc:
      "Một số sản phẩm khi cộng dồn sẽ vượt quá TỒN KHO HIỆN TẠI. Bạn muốn xử lý thế nào?",
  TTexts.currentCart: "Giỏ hàng hiện tại",
  TTexts.clearCartConfirmDesc:
      "Bạn có chắc chắn muốn xóa toàn bộ sản phẩm trong giỏ hàng hiện tại không?",
  TTexts.errorInvalidController:
      "Không tìm thấy Controller hợp lệ (Inbound/Outbound)",

  // --- Transaction Item Add ---
  TTexts.loadingAddingToCart: "Đang thêm vào giao dịch...",
  TTexts.productNameUnknown: "Sản Phẩm Không Xác Định",
  TTexts.labelNoBarcode: "N/A",
  TTexts.labelStock: "Tồn Kho",
  TTexts.labelImportPrice: "Giá Nhập",
  TTexts.labelQuantity: "Số Lượng",
  TTexts.labelTicket: "Phiếu",
  TTexts.errorNoPackageId: "Không tìm thấy hoặc ID gói không hợp lệ",
  TTexts.item: "Sản phẩm",
  TTexts.subtotal: "Tạm tính",
  TTexts.removeItem: "Xóa Sản Phẩm",
  TTexts.confirmRemoveItemTransaction:
      "Bạn có chắc muốn xóa sản phẩm này khỏi giao dịch không?",
  TTexts.remove: "Xóa",
  TTexts.creatingImportTicket: "Đang tạo phiếu nhập...",
  TTexts.manualImport: "Nhập Kho Thủ Công",
  TTexts.importTicketCreated: "Đã tạo phiếu nhập thành công!",
  TTexts.errorCreatingImportTicket: "Tạo phiếu nhập thất bại.",
  TTexts.uncategorized: "Chưa Phân Loại",
  TTexts.noBrand: "Không Có Thương Hiệu",
  TTexts.inactive: "Không Hoạt Động",
  TTexts.product: "Sản Phẩm",
  TTexts.recentlyAddedSuggested: "Mới Thêm / Đề Xuất",
  TTexts.checkoutDetails: 'Chi Tiết Thanh Toán',
  TTexts.transactionReason: 'Lý Do Giao Dịch',
  TTexts.selectReason: 'Chọn lý do',
  TTexts.transactionNote: 'Ghi Chú (Tùy chọn)',
  TTexts.noteHint: 'Nhập thêm chi tiết...',
  TTexts.priceChangeDetected: 'Phát Hiện Thay Đổi Giá',
  TTexts.priceChangeMessage:
      'Bạn đã thay đổi giá của một số sản phẩm trong giao dịch này. Bạn có muốn cập nhật vĩnh viễn giá mặc định trong danh mục không?',
  TTexts.updatePricesAndCreate: 'Cập Nhật Giá & Hoàn Tất',
  TTexts.justCreateTransaction: 'Không, Chỉ Hoàn Tất Giao Dịch',
  TTexts.transactionSuccessTitle: 'Giao dịch thành công!!!',
  TTexts.transactionSuccessSub:
      'Giao dịch của bạn đã hoàn tất.\nVui lòng kiểm tra tồn kho!',
  TTexts.transactionNumber: 'Mã Giao Dịch',
  TTexts.transactionDate: 'Ngày Giao Dịch',
  TTexts.transactionType: 'Loại Giao Dịch',
  TTexts.totalItemsTransaction: 'Tổng Sản Phẩm',
  TTexts.checkDetails: 'Xem Chi Tiết',
  TTexts.transactionDetails: 'Chi Tiết Giao Dịch',
  TTexts.selectExportType: "Chọn Loại Xuất:",
  TTexts.quantityGreaterThanZero: "Số lượng phải lớn hơn 0.",
  TTexts.unitPriceLabel: "Đơn Giá",
  TTexts.deleteSearchTitle: "Xóa Lịch Sử Tìm Kiếm",
  TTexts.deleteSearchMessage:
      "Bạn có chắc muốn xóa từ khóa tìm kiếm này không?",
};
