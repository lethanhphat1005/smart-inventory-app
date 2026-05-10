 import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> viWorkspace = {
  // -- Workspace Selection
  TTexts.workspaceSelectionTitle: "Chọn Không Gian Làm Việc",
  TTexts.workspaceSelectionSubtitle:
      "Chọn môi trường mà bạn muốn làm việc hôm nay.",
  TTexts.joinAWorkspace: "Nhấn",
  TTexts.createYourWorkspace: "Tạo Cửa Hàng Mới",
  TTexts.requestAccess: "Yêu Cầu Truy Cập",
  TTexts.requestAccessDesc: "Nhập mã cửa hàng để tham gia nhóm hiện có.",
  TTexts.needHelp: "Cần Hỗ Trợ?",
  TTexts.whatIsWorkspace: "Workspace là gì?",
  TTexts.workspaceDescription:
      "Workspace (hoặc Cửa hàng) là môi trường dùng chung nơi bạn và đội ngũ quản lý kho hàng, theo dõi lô hàng và xem báo cáo.\n\n• Để tham gia workspace hiện có, bạn cần mã cửa hàng gồm 6 ký tự do Quản lý cung cấp.\n• Nếu bạn là chủ doanh nghiệp, bạn có thể tạo workspace mới để bắt đầu quản lý kho của riêng mình.",
  TTexts.understood: "Đã Hiểu",
  TTexts.storeSelectionSuccessTitle: "Đã Chọn Cửa Hàng",
  TTexts.storeSelectionSuccessMessage: "Đã tham gia thành công",
  TTexts.activeStoreBadge: "Hiện Tại",

  // -- Create Workspace
  TTexts.createStoreTitle: "Tạo Cửa Hàng Mới",
  TTexts.createStoreSubtitle:
      "Thiết lập cửa hàng để bắt đầu quản lý kho và thành viên.",
  TTexts.storeNameLabel: "Tên Workspace *",
  TTexts.storeNameHint: "ví dụ: Chi nhánh HQ, Kho Chính",
  TTexts.storeAddressLabel: "Địa Chỉ (Tùy chọn)",
  TTexts.storeAddressHint: "Nhập địa chỉ thực tế",
  TTexts.storeNameEmptyError: "Tên workspace không được để trống.",
  TTexts.confirmCreateStoreTitle: "Xác Nhận Tạo",
  TTexts.confirmCreateStoreMessage: "Bạn có chắc muốn tạo workspace mới tên là",
  TTexts.workspaceCreatedTitle: "Đã Tạo Workspace!",
  TTexts.workspaceCreatedDesc: "đã sẵn sàng hoạt động.",
  TTexts.youAreManager: "Quản Lý Cửa Hàng",
  TTexts.addMembers: "Thêm Thành Viên",
  TTexts.goToDashboard: "Đi Tới Bảng Điều Khiển",
  TTexts.searchAddressHint: "Tìm kiếm địa chỉ...",
  TTexts.useCurrentLocation: "Vị Trí Hiện Tại",
  TTexts.locationStr: "Vị Trí",
  TTexts.creatingYourWorkspace: "Đang tạo...",
  TTexts.creatingWorkspace: "Đang tạo workspace của bạn...",
  TTexts.backToWorkspaces: "Quay Lại Workspace",
  TTexts.gpsOffTitle: "GPS Đã Tắt",
  TTexts.gpsOffMessage: "Vui lòng bật dịch vụ vị trí trong cài đặt hệ thống.",
  TTexts.locationErrorMessage:
      "Không thể lấy vị trí. Vui lòng thử lại hoặc nhập thủ công.",
  TTexts.warningEmptyName: "Vui lòng nhập tên workspace.",
  TTexts.warningStoreExists:
      "Workspace với tên hoặc địa chỉ này đã tồn tại. Vui lòng thử tên khác.",

  // -- Invite Code & Join Store
  TTexts.inviteCodeTitle: "Mã Mời Của Bạn",
  TTexts.inviteCodeSubtitle:
      "Chia sẻ mã này với nhân viên để họ tham gia cửa hàng.",
  TTexts.inviteCodeCopiedTitle: "Đã Sao Chép!",
  TTexts.inviteCodeCopiedMessage: "Mã mời đã được sao chép vào bộ nhớ tạm.",

  TTexts.joinWorkspaceTitle: "Tham Gia Workspace",
  TTexts.joinWorkspaceSubtitle:
      "Nhập mã mời do Quản lý cung cấp để kết nối vào hệ thống.",
  TTexts.enterInviteCodeLabel: "Mã Mời",
  TTexts.enterInviteCodeHint: "ví dụ: ABCD-EFGH",
  TTexts.joinBtn: "Tham Gia Ngay",
  TTexts.joiningBtn: "Đang tham gia...",
  TTexts.checkingInviteCode: "Đang kiểm tra mã mời...",

  TTexts.joinMissingCodeTitle: "Thiếu Thông Tin",
  TTexts.joinMissingCodeMessage: "Vui lòng nhập mã mời hợp lệ gồm 6 ký tự.",
  TTexts.joinInvalidCodeTitle: "Mã Không Hợp Lệ",
  TTexts.joinInvalidCodeMessage: "Mã mời không chính xác hoặc đã hết hạn.",
  TTexts.joinAlreadyMemberTitle: "Đã Là Thành Viên",
  TTexts.joinAlreadyMemberMessage: "Bạn đã là thành viên của workspace này.",
  TTexts.joinSuccessTitle: "Tham Gia Thành Công!",
  TTexts.joinSuccessMessage: "Chào mừng đến với workspace.",

  // -- Add Members Screen
  TTexts.addMembersTitle: "Quản Lý Thành Viên",
  TTexts.addMembersSubtitle:
      "Xem và quản lý thành viên cùng vai trò của họ trong workspace này.",
  TTexts.membersCount: "Thành Viên",
  TTexts.roleManager: "Quản Lý",
  TTexts.roleOwner: 'Chủ Sở Hữu',
  TTexts.roleStaff: "Nhân Viên",
  TTexts.youBadge: "Bạn",

  TTexts.generateInviteCodeBtn: "Tạo Mã Mời",
  TTexts.generateCodeDialogTitle: "Tạo Mã Mới?",
  TTexts.generateCodeDialogMessage:
      "Bạn có chắc muốn tạo mã mời mới không? Mọi mã chưa sử dụng trước đó sẽ bị vô hiệu hóa.",
  TTexts.confirmGenerate: "Tạo",
  TTexts.generatingCode: "Đang tạo mã bảo mật...",
  TTexts.generatedAt: "Được tạo: ",
  TTexts.expiresAt: "Hết hạn sau: 24 giờ",
  TTexts.activeInviteCodeTitle: "Mã Mời Đang Hoạt Động",
  TTexts.emptyMemberTitle: "Chưa Có Thành Viên",
  TTexts.emptyMemberSubtitle:
      "Tạo mã mời và chia sẻ với đội ngũ của bạn để bắt đầu cộng tác.",
  TTexts.confirmChangeRoleTitle: "Thay Đổi Vai Trò?",
  TTexts.confirmChangeRoleMessage: "Bạn có chắc muốn thay đổi vai trò cho",
  TTexts.updatingRole: "Đang cập nhật vai trò...",
  TTexts.roleUpdatedSuccess: "Đã cập nhật vai trò thành công.",
  TTexts.inviteCodeGeneratedSuccess: "Đã tạo mã mời mới thành công!",
  TTexts.plsGenerateNewCode: "Vui lòng tạo mã mới!",
  TTexts.copyTooltip: "Sao chép",
  TTexts.shareTooltip: "Chia sẻ",
  TTexts.generateNewCodeTooltip: "Tạo mã mới",
};
