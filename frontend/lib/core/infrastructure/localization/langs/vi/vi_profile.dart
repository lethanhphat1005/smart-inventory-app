import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> viProfile = {
  //--Profile
  TTexts.profileTitle: 'Hồ Sơ',

  //--User
  TTexts.profileNameUser: '',
  TTexts.profileEmailUser: '',
  TTexts.profilePhoneNumber: '',
  TTexts.profileNameStore: '',
  TTexts.profileNoAddress: 'Không có địa chỉ',
  TTexts.profileMembers: 'thành viên',
  TTexts.profileListMembers: 'Thành Viên',
  TTexts.profileNoPhoneNumber: 'Không có số điện thoại',
  TTexts.profileNoEmail: 'Không có email',
  TTexts.profileStoreName: 'Tên cửa hàng',

  //Bottom Sheet
  TTexts.profilePhoneNumberBottomSheet: 'Số điện thoại',
  TTexts.profileEmailBottomSheet: 'Email',
  TTexts.profileAddressBottomSheet: 'Địa chỉ',

  //--Section
  TTexts.profileAccount: "Tài Khoản",
  TTexts.profileManagement: "Quản Lý",

  //--Actions
  TTexts.profileChangePassword: 'Đổi mật khẩu',
  TTexts.profileMyAccount: 'Hồ sơ của tôi',
  TTexts.profileUserManagement: 'Quản lý người dùng',

  //--Btn
  TTexts.profileBtnSwitchStore: "Chuyển cửa hàng",
  TTexts.profileBtnLogout: "Đăng xuất",

  //--Dialog
  TTexts.profileDialogTitleLogout: 'Xác Nhận Đăng Xuất',
  TTexts.profileDialogDescriptionLogout:
      'Bạn có chắc muốn đăng xuất khỏi tài khoản không?',
  TTexts.profileDialogBtnLogout: 'Có',

  //-------------------------------------------------------------
  //Edit profile
  TTexts.editTitle: 'Chỉnh Sửa Hồ Sơ',
  TTexts.editLoading: 'Đang tải',
  TTexts.editEmail: 'Email',
  TTexts.editName: 'Họ Và Tên*',
  TTexts.editHintName: 'Nhập họ và tên',
  TTexts.editHintEmail: 'Nhập email',
  TTexts.editUpdate: 'Cập Nhật',
  TTexts.editPhoneNumberEmpty: 'Vui lòng nhập số điện thoại của bạn.',
  TTexts.editPhoneNumberInvalid: 'Vui lòng nhập số điện thoại hợp lệ.',
  TTexts.editPhoneNumber: 'Số Điện Thoại',
  TTexts.editPhoneNumberHint: 'Nhập số điện thoại',
  TTexts.editErrorEmptyFieldsTitle: 'Lỗi Nhập Liệu',
  TTexts.confirmUpdate: 'Xác Nhận Cập Nhật',
  TTexts.confirmUpdateDescription:
      'Bạn có chắc muốn cập nhật hồ sơ của mình không?',

  //Change Password
  TTexts.changePasswordTitle: 'Đổi Mật Khẩu',
  TTexts.changePasswordOldPassword: 'Mật Khẩu Cũ',
  TTexts.changePasswordNewPassword: 'Mật Khẩu Mới',
  TTexts.changePasswordConfirm: 'Xác Nhận',
  TTexts.changePasswordBtnConfirm: "Xác Nhận",
  TTexts.changePasswordHintOldPassword: 'Nhập mật khẩu cũ',
  TTexts.changePasswordHintNewPassword: 'Nhập mật khẩu mới',
  TTexts.changePasswordHintConfirmPassword: 'Nhập xác nhận mật khẩu',
  TTexts.passwordNotMatch: 'Mật khẩu mới và xác nhận mật khẩu không khớp.',
  TTexts.passwordSameAsOld:
      'Mật khẩu mới không được trùng với mật khẩu hiện tại.',
  TTexts.passwordChangedSuccess:
      'Mật khẩu của bạn đã được cập nhật thành công.',
  TTexts.oldPasswordIncorrect: 'Mật khẩu hiện tại bạn nhập không chính xác.',
  TTexts.authSessionExpired:
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
  TTexts.systemError: 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.',
  TTexts.authError: 'Xác thực thất bại',
  TTexts.changePasswordDialogDescription:
      'Bạn có chắc muốn đổi mật khẩu không?',
  TTexts.fillAllFields: 'Vui lòng nhập đầy đủ thông tin',

  //Edit Store
  TTexts.editStoreTitle: 'Cửa Hàng Của Tôi',
  TTexts.editStoreSubtitle: 'Quản lý và chỉnh sửa cửa hàng của bạn',
  TTexts.editStoreNameLabel: 'Tên Cửa Hàng',
  TTexts.editStoreNameHint: 'Nhập tên cửa hàng',
  TTexts.editStoreAddressLabel: 'Địa Chỉ *',
  TTexts.editStoreAddressHint: 'Nhập địa chỉ cửa hàng',
  TTexts.editStoreAmountMember: 'Thành Viên',
  TTexts.editStoreBtnEdit: 'Chỉnh Sửa',
  TTexts.profileUpdateStoreSuccess: 'Cập nhật cửa hàng thành công',
  TTexts.profileUpdateSuccess: 'Cập nhật hồ sơ thành công',
  TTexts.loadingTitle: 'Đang tải',
  TTexts.editStoreCurrentStore: 'Cửa Hàng Hiện Tại',
  TTexts.profileNoStoreSelected: 'Chưa chọn cửa hàng',
  TTexts.profileUpdateErrorTitle: 'Cập Nhật Hồ Sơ Thất Bại',
  TTexts.loggingOut: 'Đang đăng xuất...',
  TTexts.logoutErrorTitle: 'Đăng Xuất Thất Bại',
  TTexts.editStoreTitleDialog: 'Chỉnh Sửa Cửa Hàng',
  TTexts.editStoreSubtitleDialog:
      'Bạn có thể cập nhật thông tin cửa hàng tại đây.',
  TTexts.editStoreDialogDescription:
      'Bạn có chắc muốn cập nhật hồ sơ cửa hàng không?',
  TTexts.profileUpdateError: 'Không thể cập nhật hồ sơ',

  //Assign Role
  TTexts.assignsRoleTitle: 'Phân Quyền',
  TTexts.assignsRoleSubtitle: 'Quản lý vai trò và quyền hạn người dùng',
  TTexts.assignsRoleBtnSave: 'Lưu',
  TTexts.assignsRoleSearchHint: 'Tìm kiếm theo tên',
  TTexts.assignsRoleAll: 'Tất Cả',
  TTexts.assignsRoleOwner: 'Chủ Sở Hữu',
  TTexts.assignsRoleManager: 'Quản Lý',
  TTexts.assignsRoleStaff: 'Nhân Viên',

  //Member List
  TTexts.memberRemovedSuccess: 'Đã xóa thành viên khỏi cửa hàng thành công',
  TTexts.deleteMemberTitle: 'Xóa Thành Viên',
  TTexts.deleteMemberMessage: 'Bạn có chắc muốn xóa',
  TTexts.profileNoMembers: 'Không tìm thấy thành viên',
  TTexts.profileNoMembersSubtitle:
      'Không có thành viên nào trong cửa hàng này.',

  //Exceptions
  TTexts.userNotFound: 'Không tìm thấy thông tin người dùng',
  TTexts.userIdNotFound: 'Không tìm thấy ID người dùng để cập nhật hồ sơ',
};
