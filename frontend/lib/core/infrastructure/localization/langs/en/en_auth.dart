import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enAuth = {
  // Onboarding
  TTexts.onboardingSkip: 'Skip',
  TTexts.onboardingTitle1Part1: 'Empower\n',
  TTexts.onboardingTitle1Part2: 'Your\n',
  TTexts.onboardingTitle1Part3: 'S',
  TTexts.onboardingTitle1Part4: 'torage\nManagement',
  TTexts.onboardingTitle2: 'Elevate Your Tracking\nWith Real-Time Data',
  TTexts.onboardingSubtitle2:
      'Say goodbye to manual counting. Monitor your stock, track movements, and manage orders instantly with absolute precision.',
  TTexts.onboardingTitle3: 'Scale Your Business\nWith Smart Insights',
  TTexts.onboardingSubtitle3:
      'Make data-driven decisions effortlessly. Sync your inventory across all devices securely and watch your efficiency grow.',

  // -- Error / Restricted Access
  TTexts.errorTimeoutTitle: 'Connection Timeout',
  TTexts.errorTimeoutMessage:
      'The server took too long to respond. Please check your network and try again.',

  // -- Language Select
  TTexts.languageSelectTitle: "Welcome to Storix!",
  TTexts.languageSelectSubtitle: "Please select your language to continue.",
  TTexts.languageSelectBtnContinue: "Continue",
  TTexts.languageSelectSelectLanguage: "Selected Language",

  // General Auth
  TTexts.authOrDivider: "Or",
  TTexts.authentication: 'Authentication',
  TTexts.canceled: 'Canceled',
  TTexts.googleSignInCanceled: 'Google Sign-In was canceled.',
  TTexts.checkingEmail: 'Checking email...',

  // Login
  TTexts.loginWelcomeTitle: 'Welcome Back',
  TTexts.loginWelcomeSubtitle:
      'Enter your details to proceed or create a new account.',
  TTexts.loginTab: 'Log In',
  TTexts.signupTab: 'Sign Up',
  TTexts.emailLabel: 'Email',
  TTexts.emailHint: 'johndoe@gmail.com',
  TTexts.passwordLabel: 'Password',
  TTexts.passwordHint: '********',
  TTexts.rememberMe: 'Remember me',
  TTexts.forgotPassword: 'Forgot Password?',
  TTexts.loginBtn: 'Log In',
  TTexts.loggingIn: 'Logging...',
  TTexts.continueWithGoogle: 'Continue with Google',
  TTexts.loginErrorEmptyFieldsTitle: 'Input Error',
  TTexts.loginErrorEmptyFieldsMessage: 'Please enter both Email and Password.',
  TTexts.loginErrorInvalidEmailTitle: 'Invalid Email',
  TTexts.loginErrorInvalidEmailMessage: 'Please enter a valid email format.',
  TTexts.loginSuccessTitle: 'Welcome Back',
  TTexts.loginSuccessMessage: 'Login successful: @name',
  TTexts.loginFailedTitle: 'Login Failed',
  TTexts.loginErrorInvalidCredentialsTitle: 'Login Failed',
  TTexts.loginErrorInvalidCredentialsMessage:
      'Invalid email or password. Please try again.',
  TTexts.loginWarningUnverifiedTitle: 'Email Not Verified',
  TTexts.loginWarningUnverifiedMessage:
      'Please verify your email address before logging in.',

  // Register
  TTexts.registerTitle: 'Create an Account',
  TTexts.registerSubtitle: 'Sign up today to start managing your inventory.',
  TTexts.confirmPasswordLabel: 'Confirm Password',
  TTexts.confirmPasswordHint: '********',
  TTexts.registerBtn: 'Register',
  TTexts.registering: 'Registering...',
  TTexts.registerWithGoogle: 'Register with Google',
  TTexts.registerErrorEmptyFieldsTitle: 'Missing Information',
  TTexts.registerErrorEmptyFieldsMessage:
      'Please fill in all required fields to continue.',
  TTexts.registerErrorPasswordMismatchTitle: 'Password Mismatch',
  TTexts.registerErrorPasswordMismatchMessage:
      'The passwords you entered do not match. Please try again.',
  TTexts.registerSuccessTitle: 'Account Created',
  TTexts.registerSuccessMessage:
      'Welcome aboard! Please check your email to verify your account.',
  TTexts.registerFailedTitle: 'Registration Failed',
  TTexts.resendEmailSuccessMessage: 'A new reset link has been sent to @email.',
  // Thêm vào vùng Register
  TTexts.registerErrorUserExistsTitle: 'Account Exists',
  TTexts.registerErrorUserExistsMessage:
      'An account with this email already exists. Please log in instead.',
  TTexts.registerErrorWeakPasswordTitle: 'Weak Password',
  TTexts.registerErrorWeakPasswordMessage:
      'Your password is too weak. Please use a stronger password.',
  TTexts.registerGoogleSuccessMessage:
      'Please select login with your Google account again.',
  TTexts.registerErrorEmailExistsMessage:
      'This email is already registered. Please log in!',

  // Forgot Password / Verify
  TTexts.forgetPasswordTitle: 'Forgot Password?',
  TTexts.forgetPasswordSubtitle:
      'Enter your email to receive a secure 8-digit OTP code to reset your password.',
  TTexts.forgotPasswordBtn: 'Send to my email',
  TTexts.forgotPasswordInnerTitle: 'Enter your email',
  TTexts.goBack: 'Go back',
  TTexts.emailSentTitle: 'Email Sent',
  TTexts.emailSentMessage: 'OTP code has been sent to @email',
  TTexts.emailSendFailed: 'Cannot send email. Please try again later.',
  TTexts.emailSending: 'Sending...',
  TTexts.verifyEmailTitle: 'Verify Email',
  TTexts.verifyEmailSubtitle:
      'Almost there! Please verify your email to get started.',
  TTexts.verifyEmailInnerTitle: 'Verify your email address',
  TTexts.verifyEmailMessageP1:
      'A email to reset your password has been successfully sent to the email address ',
  TTexts.verifyEmailMessageP2:
      '. Please check your inbox and junk folder. If you cannot find the email, try resending the link from the previous screen.',
  TTexts.goToGmail: 'Go to Gmail',
  TTexts.resendEmail: 'Resend Email',
  TTexts.backToLogin: 'Back to Login',
  TTexts.resendEmailIn: 'after ',
  TTexts.emailAppNotFound: 'Not finding any kind of email.',
  TTexts.pickEmailApp: 'Pick an email',

  // Verify OTP
  TTexts.verifyOtpTitle: 'Verify OTP Code',
  TTexts.verifyOtpSubtitle:
      'Verification code has been sent to your email address:\n',

  TTexts.verifyOtpErrorIncomplete: 'Please enter all 8 digits of the OTP.',
  TTexts.verifyOtpVerifying: 'Verifying...',
  TTexts.verifyOtpVerifyBtn: 'Verify',
  TTexts.verifyOtpFailedTitle: 'Verification Failed',
  TTexts.verifyOtpFailedMessage:
      'Incorrect or expired OTP code. Please try again.',

  TTexts.verifyOtpNotReceived: 'Didn\'t receive the code? ',
  TTexts.verifyOtpResendNow: 'Resend now',
  TTexts.verifyOtpResendLater: 'Resend in',
  TTexts.verifyOtpResending: 'Resending code...',
  TTexts.verifyOtpResendSuccessTitle: 'Success',
  TTexts.verifyOtpResendSuccessMessage:
      'A new OTP code has been sent to your email.',

  TTexts.verifyOtpErrorTitle: 'Error',
  TTexts.verifyOtpResendFailed: 'Cannot resend code: @error',

  // -- Reset password
  TTexts.resetPasswordTitle: 'Set New Password',
  TTexts.resetPasswordSubtitle:
      'Please enter your new password to complete the recovery process.',
  TTexts.newPasswordLabel: 'New Password',
  TTexts.newPasswordHint: 'Enter new password',
  TTexts.updatingPassword: 'Updating password...',
  TTexts.updatePasswordBtn: 'Update Password',
  TTexts.passwordLengthError: 'Password must be at least 6 characters.',
  TTexts.resetPasswordFailedTitle: 'Update Failed',
};
