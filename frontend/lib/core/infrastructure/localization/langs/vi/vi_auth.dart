import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> viAuth = {
  // Onboarding
  TTexts.onboardingSkip: 'Bỏ qua',
  TTexts.onboardingTitle1Part1: 'Trao quyền\n',
  TTexts.onboardingTitle1Part2: 'Cho\n',
  TTexts.onboardingTitle1Part3: 'Việc ',
  TTexts.onboardingTitle1Part4: 'Quản Lý\nKho Hàng',
  TTexts.onboardingTitle2: 'Nâng Tầm Theo Dõi\nVới Dữ Liệu Thời Gian Thực',
  TTexts.onboardingSubtitle2:
      'Tạm biệt việc kiểm kê thủ công. Theo dõi tồn kho, giám sát di chuyển và quản lý đơn hàng ngay lập tức với độ chính xác tuyệt đối.',
  TTexts.onboardingTitle3: 'Phát Triển Doanh Nghiệp\nVới Phân Tích Thông Minh',
  TTexts.onboardingSubtitle3:
      'Đưa ra quyết định dựa trên dữ liệu một cách dễ dàng. Đồng bộ kho hàng trên mọi thiết bị một cách an toàn và nâng cao hiệu quả làm việc.',

  // -- Error / Restricted Access
  TTexts.errorTimeoutTitle: 'Hết Thời Gian Kết Nối',
  TTexts.errorTimeoutMessage:
      'Máy chủ phản hồi quá lâu. Vui lòng kiểm tra mạng và thử lại.',

  // General Auth
  TTexts.authOrDivider: "Hoặc",
  TTexts.authentication: 'Xác thực',
  TTexts.canceled: 'Đã hủy',
  TTexts.googleSignInCanceled: 'Đăng nhập Google đã bị hủy.',
  TTexts.checkingEmail: 'Đang kiểm tra email...',

  // Login
  TTexts.loginWelcomeTitle: 'Chào Mừng Trở Lại',
  TTexts.loginWelcomeSubtitle:
      'Nhập thông tin của bạn để tiếp tục hoặc tạo tài khoản mới.',
  TTexts.loginTab: 'Đăng Nhập',
  TTexts.signupTab: 'Đăng Ký',
  TTexts.emailLabel: 'Email',
  TTexts.emailHint: 'johndoe@gmail.com',
  TTexts.passwordLabel: 'Mật khẩu',
  TTexts.passwordHint: '********',
  TTexts.rememberMe: 'Ghi nhớ',
  TTexts.forgotPassword: 'Quên mật khẩu?',
  TTexts.loginBtn: 'Đăng Nhập',
  TTexts.loggingIn: 'Đang đăng nhập...',
  TTexts.continueWithGoogle: 'Tiếp tục với Google',
  TTexts.loginErrorEmptyFieldsTitle: 'Lỗi Nhập Liệu',
  TTexts.loginErrorEmptyFieldsMessage: 'Vui lòng nhập Email và Mật khẩu.',
  TTexts.loginErrorInvalidEmailTitle: 'Email Không Hợp Lệ',
  TTexts.loginErrorInvalidEmailMessage: 'Vui lòng nhập đúng định dạng email.',
  TTexts.loginSuccessTitle: 'Chào Mừng Trở Lại',
  TTexts.loginSuccessMessage: 'Đăng nhập thành công: @name',
  TTexts.loginFailedTitle: 'Đăng Nhập Thất Bại',
  TTexts.loginErrorInvalidCredentialsTitle: 'Thông Tin Đăng Nhập Không Hợp Lệ',
  TTexts.loginErrorInvalidCredentialsMessage:
      'Email hoặc mật khẩu không đúng. Vui lòng thử lại.',
  TTexts.loginWarningUnverifiedTitle: 'Email Chưa Xác Minh',
  TTexts.loginWarningUnverifiedMessage:
      'Vui lòng xác minh email trước khi đăng nhập.',

  // Register
  TTexts.registerTitle: 'Tạo Tài Khoản',
  TTexts.registerSubtitle: 'Đăng ký ngay hôm nay để bắt đầu quản lý kho hàng.',
  TTexts.confirmPasswordLabel: 'Xác Nhận Mật Khẩu',
  TTexts.confirmPasswordHint: '********',
  TTexts.registerBtn: 'Đăng Ký',
  TTexts.registering: 'Đang đăng ký...',
  TTexts.registerWithGoogle: 'Đăng ký với Google',
  TTexts.registerErrorEmptyFieldsTitle: 'Thiếu Thông Tin',
  TTexts.registerErrorEmptyFieldsMessage:
      'Vui lòng điền đầy đủ các trường bắt buộc để tiếp tục.',
  TTexts.registerErrorPasswordMismatchTitle: 'Mật Khẩu Không Khớp',
  TTexts.registerErrorPasswordMismatchMessage:
      'Mật khẩu bạn nhập không khớp. Vui lòng thử lại.',
  TTexts.registerSuccessTitle: 'Tạo Tài Khoản Thành Công',
  TTexts.registerSuccessMessage:
      'Chào mừng bạn! Vui lòng kiểm tra email để xác minh tài khoản.',
  TTexts.registerFailedTitle: 'Đăng Ký Thất Bại',
  TTexts.resendEmailSuccessMessage:
      'Liên kết đặt lại mới đã được gửi tới @email.',

  // Thêm vào vùng Register
  TTexts.registerErrorUserExistsTitle: 'Tài Khoản Đã Tồn Tại',
  TTexts.registerErrorUserExistsMessage:
      'Tài khoản với email này đã tồn tại. Vui lòng đăng nhập.',
  TTexts.registerErrorWeakPasswordTitle: 'Mật Khẩu Yếu',
  TTexts.registerErrorWeakPasswordMessage:
      'Mật khẩu của bạn quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.',
  TTexts.registerGoogleSuccessMessage:
      'Vui lòng chọn đăng nhập lại bằng tài khoản Google của bạn.',
  TTexts.registerErrorEmailExistsMessage:
      'Email này đã được đăng ký. Vui lòng đăng nhập!',

  // Forgot Password / Verify
  TTexts.forgetPasswordTitle: 'Quên Mật Khẩu?',
  TTexts.forgetPasswordSubtitle:
      'Nhập email của bạn để nhận mã OTP 8 chữ số an toàn nhằm đặt lại mật khẩu.',
  TTexts.forgotPasswordBtn: 'Gửi tới email của tôi',
  TTexts.forgotPasswordInnerTitle: 'Nhập email của bạn',
  TTexts.goBack: 'Quay lại',
  TTexts.emailSentTitle: 'Đã Gửi Email',
  TTexts.emailSentMessage: 'Mã OTP đã được gửi tới @email',
  TTexts.emailSendFailed: 'Không thể gửi email. Vui lòng thử lại sau.',
  TTexts.emailSending: 'Đang gửi...',
  TTexts.verifyEmailTitle: 'Xác Minh Email',
  TTexts.verifyEmailSubtitle:
      'Sắp xong rồi! Vui lòng xác minh email để bắt đầu.',
  TTexts.verifyEmailInnerTitle: 'Xác minh địa chỉ email của bạn',
  TTexts.verifyEmailMessageP1:
      'Email đặt lại mật khẩu đã được gửi thành công tới địa chỉ email ',
  TTexts.verifyEmailMessageP2:
      '. Vui lòng kiểm tra hộp thư đến và thư rác. Nếu không tìm thấy email, hãy thử gửi lại liên kết từ màn hình trước.',
  TTexts.goToGmail: 'Đi tới Gmail',
  TTexts.resendEmail: 'Gửi Lại Email',
  TTexts.backToLogin: 'Quay Lại Đăng Nhập',
  TTexts.resendEmailIn: 'sau ',
  TTexts.emailAppNotFound: 'Không tìm thấy ứng dụng email nào.',
  TTexts.pickEmailApp: 'Chọn ứng dụng email',

  // Verify OTP
  TTexts.verifyOtpTitle: 'Xác Minh Mã OTP',
  TTexts.verifyOtpSubtitle:
      'Mã xác minh đã được gửi tới địa chỉ email của bạn:\n',

  TTexts.verifyOtpErrorIncomplete: 'Vui lòng nhập đầy đủ 8 chữ số OTP.',
  TTexts.verifyOtpVerifying: 'Đang xác minh...',
  TTexts.verifyOtpVerifyBtn: 'Xác Minh',
  TTexts.verifyOtpFailedTitle: 'Xác Minh Thất Bại',
  TTexts.verifyOtpFailedMessage:
      'Mã OTP không đúng hoặc đã hết hạn. Vui lòng thử lại.',

  TTexts.verifyOtpNotReceived: 'Chưa nhận được mã? ',
  TTexts.verifyOtpResendNow: 'Gửi lại ngay',
  TTexts.verifyOtpResendLater: 'Gửi lại sau',
  TTexts.verifyOtpResending: 'Đang gửi lại mã...',
  TTexts.verifyOtpResendSuccessTitle: 'Thành Công',
  TTexts.verifyOtpResendSuccessMessage:
      'Mã OTP mới đã được gửi tới email của bạn.',

  TTexts.verifyOtpErrorTitle: 'Lỗi',
  TTexts.verifyOtpResendFailed: 'Không thể gửi lại mã: @error',

  // -- Reset password
  TTexts.resetPasswordTitle: 'Đặt Mật Khẩu Mới',
  TTexts.resetPasswordSubtitle:
      'Vui lòng nhập mật khẩu mới để hoàn tất quá trình khôi phục.',
  TTexts.newPasswordLabel: 'Mật Khẩu Mới',
  TTexts.newPasswordHint: 'Nhập mật khẩu mới',
  TTexts.updatingPassword: 'Đang cập nhật mật khẩu...',
  TTexts.updatePasswordBtn: 'Cập Nhật Mật Khẩu',
  TTexts.passwordLengthError: 'Mật khẩu phải có ít nhất 6 ký tự.',
  TTexts.resetPasswordFailedTitle: 'Cập Nhật Thất Bại',
};
