import 'package:frontend/core/infrastructure/constants/text_strings.dart';

final Map<String, String> enCore = {
  TTexts.appName: 'Smart Inventory',
  TTexts.group21: "Group 21",

  // -- Global Errors
  TTexts.errorTitle: 'Error',
  TTexts.successTitle: 'Success',
  TTexts.warningTitle: 'Warning',
  TTexts.zero: '0',
  TTexts.one: '1',
  TTexts.two: '2',
  TTexts.three: '3',
  TTexts.errorAccessRestrictedTitle: 'Access Restricted',
  TTexts.errorAccessRestrictedSubtitle:
      'This application is exclusively optimized for Smartphones. Please access via a mobile device or a standard desktop web browser for the full experience.',
  TTexts.errorTimeoutTitle: 'Connection Timeout',
  TTexts.errorTimeoutMessage:
      'The server took too long to respond. Please check your network and try again.',
  TTexts.errorTooManyRequestsTitle: 'Too Many Requests',
  TTexts.errorTooManyRequestsMessage:
      'You have requested too many times. Please wait a moment before trying again.',
  TTexts.exit: 'Exit',
  TTexts.next: 'Next',
  TTexts.confirm: 'Confirm',
  TTexts.done: 'Done',
  TTexts.errorServerTitle: 'Server Error',
  TTexts.errorServerMessage:
      'Our servers are currently facing an issue. Please try again later.',
  TTexts.errorNotFoundTitle: 'Not Found',
  TTexts.errorNotFoundMessage: 'The requested data could not be found.',
  TTexts.errorUnknownTitle: 'Unknown Error',
  TTexts.errorUnknownMessage: 'An unexpected error occurred. Please try again.',
  TTexts.fabScanBarcode: 'Scan Barcode',
  TTexts.fabAddManual: 'Add Manual',

  // -- Search
  TTexts.searchHint: 'Search by name,...',
  TTexts.searchItemsPackages: "Search items, packages,...",
  TTexts.recentSearches: 'Recent Searches',
  TTexts.clearAll: 'Clear All',
  TTexts.noResultsTitle: 'No Results Found',
  TTexts.noResultsMessage:
      'We could not find anything matching your search. Please try another keyword.',

  // -- Password Strength
  TTexts.weak: 'Weak',
  TTexts.fair: 'Fair',
  TTexts.good: 'Good',
  TTexts.strong: 'Strong',

  TTexts.loading: 'Loading...',
  TTexts.saving: 'Saving...',
  TTexts.deleting: 'Deleting...',

  // -- Splash Screen
  TTexts.splashSlogan: 'Smart Inventory, Smarter Business',
  TTexts.splashVersion: 'Version',
  TTexts.splashDevelopedBy: 'Developed by Group 21',
  TTexts.splashLoadingStart: 'Initializing system...',
  TTexts.splashLoadingInternet: 'Checking internet connection...',
  TTexts.splashLoadingSettings: 'Loading system settings...',
  TTexts.splashLoadingServices: 'Loading core services...',
  TTexts.splashLoadingUser: 'Verifying user data...',

  // -- Network Error Dialog (Đã cập nhật giao diện bắt buộc)
  TTexts.netErrorTitle: 'No Internet Connection',
  TTexts.netErrorDescription:
      'This app requires an active internet connection to sync inventory data. Please check your network and try again.',
  TTexts.netErrorReloadBtn: 'Reload', // Nút mới
  TTexts.netErrorCheckWifiBtn: 'Check WiFi Settings', // Nút mới
  TTexts.netChecking: 'Checking connection...',
  TTexts.netErrorWaiting: 'Waiting for network...',
  TTexts.netErrorRetryFailedMessage:
      'Still no internet connection. Please try again.', // THÊM DÒNG NÀY

  TTexts.barCodeScan: 'Bar Code Scan',

  TTexts.create: "Create",
  TTexts.cancel: "Cancel",

  TTexts.unknownProduct: 'Unknown Product',
  TTexts.na: 'N/A',
};
