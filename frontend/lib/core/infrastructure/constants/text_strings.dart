/// Class tập trung toàn bộ các Key ngôn ngữ để dùng trong UI
class TTexts {
  TTexts._(); // Tránh khởi tạo class

  // -- Global Texts
  static const String appName = "app_name";
  static const String group21 = "group_21";
  static const String tryAgain = "try_again";
  static const String successTitle = "success_title";
  static const String weak = "weak";
  static const String fair = "fair";
  static const String good = "good";
  static const String strong = "strong";
  static const String create = "create";
  static const String cancel = "cancel";
  static const String zero = "zero";
  static const String one = "one";
  static const String two = "two";
  static const String three = "three";
  static const String unknownProduct = "unknown_product";
  static const String na = "n_a";
  static const String warningTitle = "warning_title";
  static const String errorServerTitle = "error_server_title";
  static const String errorServerMessage = "error_server_message";
  static const String errorNotFoundTitle = "error_not_found_title";
  static const String errorNotFoundMessage = "error_not_found_message";
  static const String errorUnknownTitle = "error_unknown_title";
  static const String errorUnknownMessage = "error_unknown_message";
  static const String fabScanBarcode = "fab_scan_barcode";
  static const String fabAddManual = "fab_add_manual";
  static const String loading = "loading";
  static const String saving = "saving";
  static const String deleting = "deleting";

  // -- Search
  static const String searchHint = "search_hint";
  static const String recentSearches = "recent_searches";
  static const String clearAll = "clear_all";
  static const String noResultsTitle = "no_results_title";
  static const String noResultsMessage = "no_results_message";
  static const String searchItemsPackages = "search_items_packages";
  static const String searchEverything = "search_everything";
  static const String noResultsFound = "no_results_found";
  static const String didYouMean = "did_you_mean";
  static const String transactionType = "transaction_type";
  static const String transactionStatus = "transaction_status";
  static const String applyFilters = "apply_filters";
  static const String resetFilters = "reset_filters";
  static const String filterInbound = "filter_inbound";
  static const String filterOutbound = "filter_outbound";
  static const String filterAdjustment = "filter_adjustment";
  static const String filterCompleted = "filter_completed";
  static const String filterPending = "filter_pending";
  static const String filterCancelled = "filter_cancelled";
  static const String searchTransactionHint = "search_transaction_hint";
  static const String noTransactionsFound = "no_transactions_found";
  static const String dateRange = "date_range";
  static const String selectDateRange = "select_date_range";
  static const String createdByUser = "created_by_user";
  static const String enterUsernameOrId = "enter_username_or_id";
  static const String activeFilters = "active_filters";
  static const String userLabel = "user_label";
  static const String me = "me";
  static const String resultsFound = "results found";

  // -- Network Error Dialog
  static const String netErrorTitle = "net_error_title";
  static const String netErrorDescription = "net_error_description";
  static const String netErrorReloadBtn = "net_error_reload_btn";
  static const String netErrorCheckWifiBtn = "net_error_check_wifi_btn";
  static const String netErrorWaiting = "net_error_waiting";
  static const String netChecking = "net_checking";
  static const String netErrorRetryFailedMessage =
      "net_error_retry_failed_message";
  static const String barCodeScan = "bar_code_scan";

  // -- Error / Restricted Access
  static const String errorTitle = "error_title";
  static const String errorAccessRestrictedTitle =
      "error_access_restricted_title";
  static const String errorAccessRestrictedSubtitle =
      "error_access_restricted_subtitle";
  static const String errorTimeoutTitle = "error_timeout_title";
  static const String errorTimeoutMessage = "error_timeout_message";
  static const String errorTooManyRequestsTitle =
      "error_too_many_requests_title";
  static const String errorTooManyRequestsMessage =
      "error_too_many_requests_message";
  static const String exit = "exit";
  static const String done = "done";
  static const String next = "next";
  static const String confirm = "confirm";

  // -- Splash Screen
  static const String splashSlogan = "splash_slogan";
  static const String splashVersion = "splash_version";
  static const String splashDevelopedBy = "splash_developed_by";
  static const String splashLoadingStart = "splash_loading_start";
  static const String splashLoadingInternet = "splash_loading_internet";
  static const String splashLoadingSettings = "splash_loading_settings";
  static const String splashLoadingServices = "splash_loading_services";
  static const String splashLoadingUser = "splash_loading_user";

  // -- Onboarding
  static const String onboardingSkip = "onboarding_skip";
  static const String onboardingTitle1Part1 = "onboarding_title_1_p1";
  static const String onboardingTitle1Part2 = "onboarding_title_1_p2";
  static const String onboardingTitle1Part3 = "onboarding_title_1_p3";
  static const String onboardingTitle1Part4 = "onboarding_title_1_p4";
  static const String onboardingTitle2 = "onboarding_title_2";
  static const String onboardingSubtitle2 = "onboarding_subtitle_2";
  static const String onboardingTitle3 = "onboarding_title_3";
  static const String onboardingSubtitle3 = "onboarding_subtitle_3";

  // -- Auth
  static const String authOrDivider = "auth_or_divider";
  static const String authentication = "authentication";
  static const String canceled = "canceled";
  static const String googleSignInCanceled = "google_sign_in_canceled";
  static const String checkingEmail = "checking_email";

  // -- Login Screen
  static const String loginWelcomeTitle = "login_welcome_title";
  static const String loginWelcomeSubtitle = "login_welcome_subtitle";
  static const String loginTab = "login_tab";
  static const String signupTab = "signup_tab";
  static const String emailLabel = "email_label";
  static const String emailHint = "email_hint";
  static const String passwordLabel = "password_label";
  static const String passwordHint = "password_hint";
  static const String rememberMe = "remember_me";
  static const String forgotPassword = "forgot_password";
  static const String loginBtn = "login_btn";
  static const String loggingIn = "logging";
  static const String continueWithGoogle = "continue_with_google";
  static const String loginErrorEmptyFieldsTitle =
      "login_error_empty_fields_title";
  static const String loginErrorEmptyFieldsMessage =
      "login_error_empty_fields_message";
  static const String loginErrorInvalidEmailTitle =
      "login_error_invalid_email_title";
  static const String loginErrorInvalidEmailMessage =
      "login_error_invalid_email_message";
  static const String loginSuccessTitle = "login_success_title";
  static const String loginSuccessMessage = "login_success_message";
  static const String loginFailedTitle = "login_failed_title";
  static const String loginErrorInvalidCredentialsTitle =
      "login_error_invalid_credentials_title";
  static const String loginErrorInvalidCredentialsMessage =
      "login_error_invalid_credentials_message";
  static const String loginWarningUnverifiedTitle =
      "login_warning_unverified_title";
  static const String loginWarningUnverifiedMessage =
      "login_warning_unverified_message";

  // -- Register Screen
  static const String registerTitle = "register_title";
  static const String registerSubtitle = "register_subtitle";
  static const String confirmPasswordLabel = "confirm_password_label";
  static const String confirmPasswordHint = "confirm_password_hint";
  static const String registerBtn = "register_btn";
  static const String registering = "registering";
  static const String registerWithGoogle = "register_with_google";
  static const String registerErrorEmptyFieldsTitle =
      "register_error_empty_fields_title";
  static const String registerErrorEmptyFieldsMessage =
      "register_error_empty_fields_message";
  static const String registerErrorPasswordMismatchTitle =
      "register_error_password_mismatch_title";
  static const String registerErrorPasswordMismatchMessage =
      "register_error_password_mismatch_message";
  static const String registerSuccessTitle = "register_success_title";
  static const String registerSuccessMessage = "register_success_message";
  static const String registerFailedTitle = "register_failed_title";
  static const String resendEmailSuccessMessage =
      "resend_email_success_message";
  static const String registerErrorUserExistsTitle =
      "register_error_user_exists_title";
  static const String registerErrorUserExistsMessage =
      "register_error_user_exists_message";
  static const String registerErrorWeakPasswordTitle =
      "register_error_weak_password_title";
  static const String registerErrorWeakPasswordMessage =
      "register_error_weak_password_message";
  static const String registerGoogleSuccessMessage =
      "register_google_success_message";
  static const String registerErrorEmailExistsMessage =
      "register_error_email_exists_message";

  // -- Forgot Password & Verify
  static const String forgetPasswordTitle = "forget_password_title";
  static const String forgetPasswordSubtitle = "forget_password_subtitle";
  static const String forgotPasswordBtn = "forgot_password_btn";
  static const String forgotPasswordInnerTitle = 'forgot_password_inner_title';
  static const String goBack = "go_back";
  static const String emailSentTitle = "email_sent_title";
  static const String emailSentMessage = "email_sent_message";
  static const String emailSendFailed = "email_send_failed";
  static const String emailSending = "email_sending";
  static const String verifyEmailTitle = "verify_email_title";
  static const String verifyEmailSubtitle = "verify_email_subtitle";
  static const String verifyEmailInnerTitle = "verify_email_inner_title";
  static const String verifyEmailMessageP1 = "verify_email_message_p1";
  static const String verifyEmailMessageP2 = "verify_email_message_p2";
  static const String goToGmail = "go_to_gmail";
  static const String backToLogin = "back_to_login";
  static const String resendEmail = "resend_email";
  static const String resendEmailIn = "resend_email_in";
  static const String emailAppNotFound = "email_app_not_found";
  static const String pickEmailApp = "pick_email_app";

  // -- Workspace Selection
  static const String workspaceSelectionTitle = "workspace_selection_title";
  static const String workspaceSelectionSubtitle =
      "workspace_selection_subtitle";
  static const String joinAWorkspace = "join_a_workspace";
  static const String createYourWorkspace = "create_your_workspace";
  static const String requestAccess = "request_access";
  static const String requestAccessDesc = "request_access_desc";
  static const String needHelp = "need_help";
  static const String whatIsWorkspace = "what_is_workspace";
  static const String workspaceDescription = "workspace_description";
  static const String understood = "understood";

  // -- Create Workspace
  static const String createStoreTitle = "create_store_title";
  static const String createStoreSubtitle = "create_store_subtitle";
  static const String storeNameLabel = "store_name_label";
  static const String storeNameHint = "store_name_hint";
  static const String storeAddressLabel = "store_address_label";
  static const String storeAddressHint = "store_address_hint";
  static const String storeNameEmptyError = "store_name_empty_error";
  static const String confirmCreateStoreTitle = "confirm_create_store_title";
  static const String confirmCreateStoreMessage =
      "confirm_create_store_message";
  static const String workspaceCreatedTitle = "workspace_created_title";
  static const String workspaceCreatedDesc = "workspace_created_desc";
  static const String youAreManager = "you_are_manager";
  static const String addMembers = "add_members";
  static const String goToDashboard = "go_to_dashboard";
  static const String searchAddressHint = "search_address_hint";
  static const String useCurrentLocation = "use_current_location";
  static const String locationStr = "location_str";
  static const String creatingWorkspace = "creating_workspace";
  static const String creatingYourWorkspace = "creating_your_workspace";
  static const String backToWorkspaces = "back_to_workspaces";
  static const String gpsOffTitle = "gps_off_title";
  static const String gpsOffMessage = "gps_off_message";
  static const String locationErrorMessage = "location_error_message";

  // -- Invite Code & Join Store
  static const String inviteCodeTitle = "invite_code_title";
  static const String inviteCodeSubtitle = "invite_code_subtitle";
  static const String inviteCodeCopiedTitle = "invite_code_copied_title";
  static const String inviteCodeCopiedMessage = "invite_code_copied_message";
  static const String joinWorkspaceTitle = "join_workspace_title";
  static const String joinWorkspaceSubtitle = "join_workspace_subtitle";
  static const String enterInviteCodeLabel = "enter_invite_code_label";
  static const String enterInviteCodeHint = "enter_invite_code_hint";
  static const String joinBtn = "join_btn";
  static const String joiningBtn = "joining_btn";
  static const String checkingInviteCode = "checking_invite_code";
  static const String joinMissingCodeTitle = "join_missing_code_title";
  static const String joinMissingCodeMessage = "join_missing_code_message";
  static const String joinInvalidCodeTitle = "join_invalid_code_title";
  static const String joinInvalidCodeMessage = "join_invalid_code_message";
  static const String joinAlreadyMemberTitle = "join_already_member_title";
  static const String joinAlreadyMemberMessage = "join_already_member_message";
  static const String joinSuccessTitle = "join_success_title";
  static const String joinSuccessMessage = "join_success_message";

  // -- Add Members Screen
  static const String addMembersTitle = "add_members_title";
  static const String addMembersSubtitle = "add_members_subtitle";
  static const String membersCount = "members_count";
  static const String roleManager = "role_manager";
  static const String roleOwner = "role_owner";
  static const String roleStaff = "role_staff";
  static const String youBadge = "you_badge";
  static const String generateInviteCodeBtn = "generate_invite_code_btn";
  static const String generateCodeDialogTitle = "generate_code_dialog_title";
  static const String generateCodeDialogMessage =
      "generate_code_dialog_message";
  static const String confirmGenerate = "confirm_generate";
  static const String generatingCode = "generating_code";
  static const String generatedAt = "generated_at";
  static const String expiresAt = "expires_at";
  static const String activeInviteCodeTitle = "active_invite_code_title";
  static const String emptyMemberTitle = "empty_member_title";
  static const String emptyMemberSubtitle = "empty_member_subtitle";
  static const String confirmChangeRoleTitle = "confirm_change_role_title";
  static const String confirmChangeRoleMessage = "confirm_change_role_message";
  static const String updatingRole = "updating_role";
  static const String roleUpdatedSuccess = "role_updated_success";
  static const String inviteCodeGeneratedSuccess =
      "invite_code_generated_success";
  static const String plsGenerateNewCode = "pls_generate_new_code";
  static const String copyTooltip = "copy_tooltip";
  static const String shareTooltip = "share_tooltip";
  static const String generateNewCodeTooltip = "generate_new_code_tooltip";

  // -- Home
  static const String homeRoleOwnerTooltip = "home_role_owner_tooltip";
  static const String homeRoleManagerTooltip = "home_role_manager_tooltip";
  static const String homeRoleStaffTooltip = "home_role_staff_tooltip";
  static const String goodMorning = "goodMorning";
  static const String goodAfternoon = "goodAfternoon";
  static const String goodEvening = "goodEvening";
  static const String homeDailyOverview = "home_daily_overview";
  static const String homeTodaysRevenue = "home_todays_revenue";
  static const String homeProfitLossWeek = "home_profit_loss_week";
  static const String homeVsYesterday = "home_vs_yesterday";
  static const String homeThisWeek = "home_this_week";
  static const String homeRevenueTitle = "home_revenue_title";
  static const String homeProfit = "home_profit";
  static const String homeLoss = "home_loss";
  static const String homeInventoryOverview = "home_inventory_overview";
  static const String homeTotalItems = "home_total_items";
  static const String homeStockIn = "home_stock_in";
  static const String homeStockOut = "home_stock_out";
  static const String homeTodaysTransactions = "home_todays_transactions";
  static const String homeTapToViewMoreHistory =
      "home_tap_to_view_more_history";
  static const String homeInboundShipment = "home_inbound_shipment";
  static const String homeOutboundDelivery = "home_outbound_delivery";
  static const String homeStockAdjustment = "home_stock_adjustment";
  static const String homeScanBarcode = "home_scan_barcode";
  static const String homeScanBarcodeSub = "home_scan_barcode_sub";
  static const String homeAddProduct = "home_add_product";
  static const String homeAddProductSub = "home_add_product_sub";
  static const String homeViewReports = "home_view_reports";
  static const String homeViewReportsSub = "home_view_reports_sub";
  static const String surplus = 'surplus';
  static const String shrinkage = 'shrinkage';
  static const String dailyStockHealth = 'daily_stock_health';
  static const String recentAdjustments = 'recent_adjustments';
  static const String systemAdjustment = 'system_adjustment';
  static const String itemsText = 'items_text';
  static const String adjustmentHistoryTitle = 'adjustment_history_title';
  static const String searchAdjustmentHint = 'search_adjustment_hint';
  static const String selectDate = 'select_date';
  static const String clearFilter = 'clear_filter';
  static const String noAdjustmentsFound = 'no_adjustments_found';
  static const String noAdjustmentsFoundDesc = 'no_adjustments_found_desc';
  static const String filtered = 'filtered';
  static const String today = 'today';
  static const String yesterday = 'yesterday';
  static const String note = 'note';
  static const String productName = 'product_name';
  static const String overviewInfoTitle = 'overview_info_title';
  static const String inboundDesc = 'inbound_desc';
  static const String outboundDesc = 'outbound_desc';
  static const String adjustmentDesc = 'adjustment_desc';
  static const String totalInDesc = 'total_in_desc';
  static const String totalOutDesc = 'total_out_desc';
  static const String adjust = 'adjust';
  static const String totalIn = 'total_in';
  static const String totalOut = 'total_out';
  static const String noRecentAdjustments = 'no_recent_adjustments';
  static const String homeViewAdjustments = 'home_view_adjustments';
  static const String homeViewAdjustmentsSub = 'home_view_adjustments_sub';
  static const String homeLowStock = 'home_low_stock';
  static const String homeLowStockSub = 'home_low_stock_sub';
  static const String lowStockTitle = 'low_stock_title';
  static const String noLowStock = 'no_low_stock';
  static const String noLowStockDesc = 'no_low_stock_desc';
  static const String stockLeft = 'stock_left';
  static const String qtyChange = "qty_change";

  // -- Low Stock
  static const String outOfStockSection = 'out_of_stock_section';
  static const String lowStockSection = 'low_stock_section';

  // -- Inventory
  static const String inventoryHub = "inventory_hub";
  static const String manageProductsStock = "manage_products_stock";
  static const String details = "details";
  static const String inboundOutbound7Days = "inbound_outbound_7_days";
  static const String inventoryTitle = "inventory_title";
  static const String inventoryInsights = "inventory_insights";
  static const String manageData = "manage_data";
  static const String productCatalog = "product_catalog";
  static const String totalItemsValue = "total_items_value";
  static const String stockValue = "stock_value";
  static const String stockHealth = "stock_health";
  static const String statusHealthy = "status_healthy";
  static const String statusLow = "status_low";
  static const String statusOut = "status_out";
  static const String topCategoriesByVolume = "top_categories_by_volume";
  static const String stockFlow = "stock_flow";
  static const String flowIn = "flow_in";
  static const String flowOut = "flow_out";
  static const String items = "items";
  static const String more = "more";
  static const String noDataAvailable = "no_data_available";
  static const String noCategoriesFound = "no_categories_found";
  static const String totalInventory = "total_inventory";
  static const String clearFilters = "clear_filters";
  static const String emptyFilterMessage = "empty_filter_message";
  static const String totalActiveProducts = 'total_active_products';
  static const String totalStockValue = 'total_stock_value';
  static const String inventoryHealth = 'inventory_health';
  static const String topCategories = 'top_categories';
  static const String inventoryFlow = 'inventory_flow';
  static const String chartTooltipIn = 'chart_tooltip_in';
  static const String chartTooltipOut = 'chart_tooltip_out';
  static const String noHistoryAvailable = "no_history_available";
  static const String stockTake = "stock_take";
  static const String importGoods = "import_goods";
  static const String exportGoods = "export_goods";
  static const String stockAdjustmentOrCheck = "stock_adjustment_or_check";
  static const String currentQty = "current_qty";
  static const String errorProductOrPackageIdMissing =
      "error_product_or_package_id_missing";

  // -- Chatbot AI
  static const String chatbotName = "chatbot_name";
  static const String chatbotOnline = "chatbot_online";
  static const String chatbotInputHint = "chatbot_input_hint";
  static const String chatbotWelcomeMsg = "chatbot_welcome_msg";
  static const String chatbotErrorTitle = "chatbot_error_title";
  static const String chatbotErrorMsg = "chatbot_error_msg";
  static const String chatbotTyping = "chatbot_typing";
  static const String chatbotEmptyInputWarning = "chatbot_empty_input_warning";
  static const String chatbotMockResponse = "chatbot_mock_response";

  // -- Customize Catalog
  static const String customizeCatalog = "customize_catalog";
  static const String pinnedOnHome = "pinned_on_home";
  static const String tapAndHoldToDrag = "tap_and_hold_to_drag";
  static const String save = "save";

  // -- Inventory Insight
  static const String inventoryList = "inventory_list";
  static const String tabAll = "tab_all";
  static const String tabHealthy = "tab_healthy";
  static const String allItems = "all_items";
  static const String tabLowStock = "tab_low_stock";
  static const String tabOutStock = "tab_out_stock";
  static const String sku = "sku";
  static const String inStock = "in_stock";
  static const String insightsOverview = "insights_overview";
  static const String actionRequired = "action_required";
  static const String goodCondition = "good_condition";

  // -- Inventory Detail
  static const String inventoryDetails = "inventory_details";
  static const String quantityInStock = "quantity_in_stock";
  static const String reorderThreshold = "reorder_threshold";
  static const String importPrice = "import_price";
  static const String adjustStock = "adjust_stock";
  static const String totalInStock = "total_in_stock";
  static const String lowStockAlert = "low_stock_alert";
  static const String noThreshold = "no_threshold";
  static const String productSku = "product_sku";
  static const String productPrice = "product_price";
  static const String totalValue = "total_value";
  static const String editItem = "edit_item";
  static const String deleteItem = "delete_item";
  static const String deleteConfirmation = "delete_confirmation";
  static const String confirmDeleteText =
      "are_you_sure_you_want_to_delete_this_item";
  static const String delete = "delete";
  static const String barcodeType = "barcode_type";
  static const String noLimit = "no_limit";
  static const String thresholdTitle = "threshold_title";
  static const String totalStockTitle = "total_stock_title";
  static const String featureComingSoon = "feature_coming_soon";
  static const String itemDeletedSuccess = "item_deleted_success";
  static const String itemDeletedMessage = "item_deleted_message";
  static const String info = "info";
  static const String totalStockInTitle = "total_stock_in_title";
  static const String totalStockOutTitle = "total_stock_out_title";
  static const String importCost = "import_cost";
  static const String salePrice = "sale_price";
  static const String profitMargin = "profit_margin";
  static const String barcodeLabel = "barcode_label";
  static const String noRelatedPackages = "no_related_packages";
  static const String unknownPackage = "unknown_package";
  static const String left = "left";
  static const String stockMovement = "stock_movement";
  static const String data = "data";
  static const String chart = "chart";
  static const String stockIn = "stock_in";
  static const String stockOut = "stock_out";
  static const String inventoryStatus = "inventory_status";
  static const String relatedPackages = "related_packages";
  static const String inventoryHistory = "inventory_history";
  static const String latestInventoryCount = "latest_inventory_count";
  static const String restockFromSupplier = "restock_from_supplier";
  static const String salesOrder = "sales_order";
  static const String loadingProduct = "loading_product";
  static const String viewProductInfo = 'view_product_info';

  // --- Transaction Bottom Sheet
  static const String addToTransaction = "add_to_transaction";
  static const String enterQuantityToAdd = "enter_quantity_to_add";
  static const String quantityToImport = "quantity_to_import";
  static const String importPriceLot = "import_price_lot";
  static const String confirmAndAdd = "confirm_and_add";

  // --- Product Catalog & Categories
  static const String categoryCatalog = 'category_catalog';
  static const String searchCategories = 'search_categories';
  static const String totalCategories = 'total_categories';
  static const String categoriesUnit = 'categories_unit';
  static const String addNewCategory = 'add_new_category';
  static const String addNewCategorySub = 'add_new_category_sub';
  static const String categoryDescription = 'category_description';
  static const String noCategoryDescription = 'no_description';
  static const String emptyCategoryMessage = 'empty_category_message';

  // --- View All Products
  static const String viewAllProducts = 'view_all_products';
  static const String viewAllProductsSub = 'view_all_products_sub';

  // --- Category Detail
  static const String addNewProduct = 'add_new_product';
  static const String addNewProductSub = 'add_new_product_sub';
  static const String editCategory = 'editCategory';
  static const String deleteCategory = 'delete_category';
  static const String noProductsFound = 'no_products_found';
  static const String noProductsAssigned = 'no_products_assigned';
  static const String deleteCategoryConfirm = 'delete_category_confirm';

  // --- Product Catalog Detail
  static const String brand = 'brand';
  static const String packagesOrVariants = 'packages_or_variants';
  static const String add = 'add';
  static const String addPackageSubtitle = 'add_package_subtitle';
  static const String noBarcode = 'no_barcode';
  static const String editProduct = 'edit_product';
  static const String deleteProduct = 'delete_product';
  static const String addNewPackage = 'add_new_package';
  static const String editPackage = 'edit_package';
  static const String noPackagesFound = 'no_packages_found';
  static const String deleteCategoryTitle = "delete_category_title";
  static const String deleteCategoryWarning = "delete_category_warning";
  static const String deleteCategoryConfirmBtn = "delete_category_confirm_btn";
  static const String deleteCategorySuccess = "delete_category_success";
  static const String productDataRefreshing = "product_data_refreshing";

  // -- Add Category
  static const String categoryNameLabel = 'category_name_label';
  static const String categoryNameHint = 'category_name_hint';
  static const String categoryDescLabel = 'category_desc_label';
  static const String categoryDescHint = 'category_desc_hint';
  static const String saveCategory = 'save_category';
  static const String categoryNameRequired = 'category_name_required';
  static const String categoryCreatedSuccessTitle =
      'category_created_success_title';
  static const String categoryCreatedSuccessMessage =
      'category_created_success_message';
  static const String categoryNameExists = 'category_name_exists';
  static const String savingCategory = 'saving_category';

  // -- Edit Category
  static const String editCategoryTitle = 'edit_category_title';
  static const String categoryUpdatedSuccessMessage =
      'category_updated_success_message';
  static const String deleteCategorySuccessMessage =
      'delete_category_success_message';
  static const String categoryNotEmptyError = 'category_not_empty_error';

  // -- Add Product
  static const String addNewProductTitle = 'add_new_product_title';
  static const String editProductTitle = 'edit_product_title';
  static const String productNameLabel = 'product_name_label';
  static const String productNameSubLabel = 'product_name_sub_label';
  static const String brandSub = 'brand_Sub';
  static const String selectCategory = 'select_category';
  static const String initialPackageInfo = 'initial_package_info';
  static const String unitLabel = 'unitLabel';
  static const String productCreatedSuccess = 'product_created_success';
  static const String productUpdatedSuccess = 'product_updated_success';
  static const String step1 = 'step_1';
  static const String step2 = 'step_2';
  static const String baseInfo = 'base_info';
  static const String packageInfo = 'package_info';
  static const String nextStep = 'next_step';
  static const String previousStep = 'previous_step';
  static const String variantNameLabel = 'variant_name_label';
  static const String variantNameHint = 'variant_name_hint';
  static const String selectCategoryWarning = 'select_category_warning';
  static const String tapToSelect = 'tap_to_select';
  static const String step1Title = 'step_1_title';
  static const String step1Sub = 'step_1_sub';
  static const String step2Title = 'step_2_title';
  static const String step2Sub = 'step_2_sub';
  static const String productImage = 'product_image';
  static const String uploadImage = 'upload_image';
  static const String takePhoto = 'take_photo';
  static const String chooseFromGallery = 'choose_from_gallery';
  static const String stepProductBaseInfo = 'step_product_base_info';
  static const String stepProductImage = 'step_product_image';
  static const String stepProductPackage = 'step_product_package';
  static const String productBaseTitle = 'product_base_title';
  static const String productBaseSub = 'product_base_sub';
  static const String productImageTitle = 'product_image_title';
  static const String productImageSub = 'product_image_sub';
  static const String productPackageTitle = 'product_package_title';
  static const String productPackageSub = 'product_package_sub';
  static const String requirePhoto = 'require_photo';
  static const String cameraPermissionDenied = 'camera_permission_denied';
  static const String scanOrTypeBarcode = 'scan_or_type';
  static const String zeroPointZero = 'zero_point_zero';
  static const String selectUnit = 'select_unit';
  static const String discardChangesTitle = 'discard_changes_title';
  static const String discardChangesMessage = 'discard_changes_message';
  static const String discard = 'discard';
  static const String keepEditing = 'keep_editing';
  static const String confirmNoImageTitle = 'confirm_no_image_title';
  static const String confirmNoImageMessage = 'confirm_no_image_message';
  static const String yesContinue = 'yes_continue';
  static const String addPhoto = 'add_photo';
  static const String cropImage = 'crop_image';
  static const String reorderThresholdLabel = 'reorder_threshold_label';
  static const String reorderThresholdHint = 'reorder_threshold_hint';
  static const String unitLockedMessage = "unit_locked_message";
  static const String thresholdMustBeGreaterThanZero =
      "threshold_must_be_greater_than_zero";
  static const String leaveEmptyForNoLimit = "leave_empty_for_no_limit";
  static const String displayNameSuffixLabel = "display_name_suffix_label";
  static const String displayNameSuffixHint = "display_name_suffix_hint";
  static const String fieldRequired = 'field_required';
  static const String invalidNumber = 'invalid_number';
  static const String suggestedNames = 'suggested_names';
  static const String priceGreaterThanZero = 'price_greater_than_zero';
  static const String displayNameLabel = "display_name_label";
  static const String displayNameHint = "display_name_hint";
  static const String instructionTitle = "instruction_title";
  static const String instructionBaseInfo = "instruction_base_info";
  static const String instructionImage = "instruction_image";
  static const String instructionPackage = "instruction_package";
  static const String fillRequiredFields = "fill_required_fields";
  static const String confirmCreateTitle = "confirm_create_title";
  static const String confirmCreateMessage = "confirm_create_message";
  static const String confirmUpdateTitle = "confirm_update_title";
  static const String confirmUpdateMessage = "confirm_update_message";
  static const String confirmDeleteTitle = "confirm_delete_title";
  static const String confirmDeleteMessage = "confirm_delete_message";
  static const String confirmSkipPackageTitle = "confirm_skip_package_title";
  static const String confirmSkipPackageMessage =
      "confirm_skip_package_message";
  static const String createOnlyProduct = "create_only_product";
  static const String createFullProduct = "create_full_product";
  static const String skipAndCreate = "skip_and_create";

  // -- Edit Product
  static const String editProductImageTitle = 'edit_product_image_title';
  static const String editProductImageSub = 'edit_product_image_sub';
  static const String editPackageTitle = 'edit_package_title';
  static const String editPackageSub = 'edit_package_sub';
  static const String addPackageTitle = 'add_package_title';
  static const String addPackageSub = 'add_package_sub';
  static const String saveChanges = 'save_changes';
  static const String saveImage = 'save_image';
  static const String savePackage = 'save_package';
  static const String deletePackage = 'delete_package';
  static const String addPackageBtn = 'add_package_btn';
  static const String imageUpdatedSuccess = 'image_updated_success';
  static const String packageUpdatedSuccess = 'package_updated_success';
  static const String packageCreatedSuccess = 'package_created_success';
  static const String deletingProduct = "deleting_product";
  static const String productDeletedSuccess = "product_deleted_success";
  static const String deletingPackage = "deleting_package";
  static const String packageDeletedSuccess = "package_deleted_success";
  static const String productDataMissing = "product_data_missing";
  static const String productNotEmptyError = "product_not_empty_error";
  static const String confirmMoveProductToTrash =
      "confirm_move_product_to_trash";
  static const String confirmMovePackageToTrash =
      "confirm_move_package_to_trash";
  static const String inventoryNotEmptyTitle = "inventory_not_empty_title";
  static const String inventoryNotEmptyMessage = "inventory_not_empty_message";
  static const String makeTransaction = "make_transaction";
  static const String confirmDeletePackageMessage =
      "confirm_delete_package_message";
  static const String currentStockWithCount = "current_stock_with_count";
  static const String importPriceLabel = 'import_price_label';
  static const String sellingPriceLabel = 'selling_price_label';
  static const String stockQuantityLabel = 'stock_quantity_label';
  static const String inventoryThreshold = 'inventory_threshold';
  static const String sellingPrice = 'selling_price';

  // Empty State
  static const String homeQuickActions = "home_quick_actions";
  static const String homeLowStockAlerts = "home_low_stock_alerts";
  static const String homeItems = "home_items";
  static const String homeOnlyLeft = "home_only_left";
  static const String homeTapToViewAll = "home_tap_to_view_all";
  static const String homeInStock = "home_in_stock";
  static const String homeOutOfStock = "home_out_of_stock";

  // --- Transaction ---
  static const String createNewTransaction = "createNewTransaction";
  static const String manageInventory = "manageInventory";
  static const String manageInventoryDesc = "manageInventoryDesc";
  static const String inbound = "inbound";
  static const String outbound = "outbound";
  static const String stockAdjustment = "stockAdjustment";

  // --- Inbound ---
  static const String inboundTransaction = "inbound_transaction";
  static const String emptyInboundCartTitle = "empty_inbound_cart_title";
  static const String emptyInboundCartSub = "empty_inbound_cart_sub";
  static const String completeImport = "complete_import";
  static const String totalFunds = "total_funds";
  static const String searchProductToAdd = "search_product_to_add";
  static const String emptyTransactionTitle = "empty_transaction_title";
  static const String emptyTransactionSubtitle = "empty_transaction_subtitle";
  static const String transactionCompletedTitle = "transaction_completed_title";
  static const String transactionCompletedSubtitle =
      "transaction_completed_subtitle";
  static const String backToHome = "back_to_home";
  static const String scanProductBarcode = "scan_product_barcode";
  static const String confirmImportTitle = "confirm_import_title";
  static const String confirmImportDescription = "confirm_import_description";
  static const String proceedImport = "proceed_import";

  // --- Outbound ---
  static const String outboundTransactionTitle = "outbound_transaction_title";
  static const String searchDot = "search_dot";
  static const String confirmExport = "confirm_export";
  static const String stocksLabel = "stocks_label";
  static const String outOfStockAlert = "out_of_stock_alert";
  static const String outOfStockTitle = "out_of_stock_title";
  static const String outOfStockDesc = "out_of_stock_desc";
  static const String actualStock = "actual_stock";
  static const String autoRemovedFromCart = "auto_removed_from_cart";
  static const String updatedListLabel = "updated_list_label";
  static const String clearStock = 'clear_stock';
  static const String clearAllStock = 'clear_all_stock';
  static const String productHasRemainingStock = 'product_has_remaining_stock';
  static const String autoGeneratedClearanceNote =
      'auto_generated_clearance_note';

  // --- Inbound/Outbound Transaction Item Add ---
  static const String loadingAddingToCart = "loading_adding_to_cart";
  static const String productNameUnknown = "product_name_unknown";
  static const String completeExport = "complete_export";
  static const String labelNoBarcode = "label_no_barcode";
  static const String labelStock = "label_stock";
  static const String labelImportPrice = "label_import_price";
  static const String labelQuantity = "label_quantity";
  static const String labelTicket = "label_ticket";
  static const String errorNoPackageId = "error_no_package_id";
  static const String subtotal = "subtotal";
  static const String item = "item";
  static const String removeItem = "remove_item";
  static const String confirmRemoveItemTransaction =
      "confirm_remove_item_transaction";
  static const String remove = "remove";
  static const String creatingImportTicket = "creating_import_ticket";
  static const String manualImport = "manual_import";
  static const String importTicketCreated = "import_ticket_created";
  static const String errorCreatingImportTicket =
      "error_creating_import_ticket";
  static const String uncategorized = "uncategorized";
  static const String noBrand = "no_brand";
  static const String inactive = "inactive";
  static const String product = "product";
  static const String recentlyAddedSuggested = "recently_added_suggested";
  static const String checkoutDetails = "checkout_details";
  static const String transactionReason = "transaction_reason";
  static const String selectReason = "select_reason";
  static const String transactionNote = "transaction_note";
  static const String noteHint = "note_hint";
  static const String priceChangeDetected = "price_change_detected";
  static const String priceChangeMessage = "price_change_message";
  static const String updatePricesAndCreate = "update_prices_and_create";
  static const String justCreateTransaction = "just_create_transaction";
  static const String transactionSuccessTitle = "transaction_success_title";
  static const String transactionSuccessSub = "transaction_success_sub";
  static const String transactionNumber = "transaction_number";
  static const String transactionDate = "transaction_date";
  static const String totalItemsTransaction = "total_items_transaction";
  static const String checkDetails = "check_details";
  static const String transactionDetails = "transaction_details";
  static const String selectExportType = "select_export_type";

  // Specific Reasons
  static const String reasonRetailSale = "reason_retail_sale";
  static const String reasonWholesale = "reason_wholesale";
  static const String reasonDamaged = "reason_damaged";
  static const String reasonInternalTransfer = "reason_internal_transfer";
  static const String reasonReturn = "reason_return";
  static const String reasonOther = "reason_other";
  static const String reasonIncome = "reason_income";
  static const String reasonNeutral = "reason_neutral";
  static const String reasonExpense = "reason_expense";

  static const String selectBatchFIFO = "select_batch_fifo";
  static const String batchRemaining = "batch_remaining";
  static const String expiresOn = "expires_on";
  static const String batchExceedsStock = "batch_exceeds_stock";
  static const String quantityToExport = "quantity_to_export";
  static const String sellingPriceLot = "selling_price_lot";
  static const String importedOn = "imported_on";
  static const String outOfStockBatch = "out_of_stock_batch";
  static const String outboundTransaction = 'outbound_transaction';
  static const String loadingCreatingTransaction =
      'loading_creating_transaction';

  // Export process
  static const String confirmExportTitle = "confirm_export_title";
  static const String confirmExportDescription = "confirm_export_description";
  static const String processingExport = "processing_export";
  static const String exportSuccessMessage = "export_success_message";
  static const String noteLabel = "note_label";
  static const String emptyCartWarning = "empty_cart_warning";
  static const String priceChangeDetectedTitle = "price_change_detected_title";
  static const String priceChangeDetectedDesc = "price_change_detected_desc";
  static const String proceedExport = "proceed_export";
  static const String reasonForExport = "reason_for_export";
  static const String total = "total";
  static const String totalQuantity = "total_quantity";
  static const String specifyBatchQuantity = "specify_batch_quantity";

  // -- Stock Adjustment
  static const String confirmAdjustmentTitle = "confirm_adjustment_title";
  static const String confirmAdjustmentDesc = "confirm_adjustment_desc";
  static const String proceedAdjustment = "proceed_adjustment";
  static const String listItems = "list_items";
  static const String system = "system";
  static const String actual = "actual";
  static const String spread = "spread";
  static const String status = "status";
  static const String checked = "checked";
  static const String unchecked = "unchecked";
  static const String checkedItems = "checked_items";
  static const String saveAll = "save_all";
  static const String updateActualQty = "update_actual_qty";
  static const String mismatched = "mismatched";
  static const String reason = "reason";
  static const String damage = "damage";
  static const String expired = "expired";
  static const String loss = "loss";
  static const String itemFound = "item_found";
  static const String inputError = "input_error";
  static const String additionalNote = "additional_note";
  static const String stockOutput = "stock_output";
  static const String checkComplete = "check_complete";
  static const String mismatchedReasonLabel = "mismatched_reason_label";
  static const String productInformation = "product_information";
  static const String stockCount = "stock_count";
  static const String otherReason = "other_reason";
  static const String notEnoughStockWarning = "not_enough_stock_warning";
  static const String quantityToAdjust = "quantity_to_adjust";
  static const String automatedNote = "automated_note";
  static const String currentStock = "current_stock";
  static const String barcode = "barcode";
  static const String checkAll = "check_all";
  static const String uncheckAll = "uncheck_all";
  static const String confirmCheckAllTitle = "confirm_check_all_title";
  static const String confirmCheckAllDesc = "confirm_check_all_desc";
  static const String confirmUncheckAllTitle = "confirm_uncheck_all_title";
  static const String confirmUncheckAllDesc = "confirm_uncheck_all_desc";
  static const String incompleteSaveTitle = "incomplete_save_title";
  static const String incompleteSaveDesc = "incomplete_save_desc";
  static const String confirmSaveTitle = "confirm_save_title";
  static const String confirmSaveDesc = "confirm_save_desc";
  static const String combinedNotesTitle = "combined_notes_title";
  static const String noItemsFound = "no_items_found";
  static const String noItemsFoundDesc = "no_items_found_desc";
  static const String discardTransactionTitle = "discard_transaction_title";
  static const String discardTransactionDesc = "discard_transaction_desc";
  static const String profileEmailUser = "profile_email_user";
  static const String noDifferencesFound = 'no_differences_found';
  static const String adjustmentCompletedTitle = 'adjustment_completed_title';
  static const String adjustmentSuccessSub = 'adjustment_success_sub';
  static const String adjustmentId = 'adjustment_id';
  static const String checkItemsStats = 'check_items_stats';
  static const String totalDifference = 'total_difference';

  // -- Transaction Summary
  static const String qty = "qty";
  static const String modifiedProducts = 'modified_products';
  static const String adjustmentSummaryBrief = "adjustment_summary_brief";

  // -- Report
  static const String reportTabToday = 'report_tab_today';
  static const String reportTabCalendar = 'report_tab_calendar';
  static const String export = 'export';
  static const String exportingProgress = 'exporting_progress';
  static const String exportTransactionsTitle = 'export_transactions_title';
  static const String exportTransactionsDesc = 'export_transactions_desc';
  static const String reportEmptyTitle = 'report_empty_title';
  static const String reportEmptySubtitle = 'report_empty_subtitle';
  static const String reportHistory = 'report_history';
  static const String reportTransactionsOverview =
      'report_transactions_overview';
  static const String exportFailedTitle = 'export_failed_title';
  static const String exportFailedMessage = 'export_failed_message';
  static const String amount = "amount";

  // -- Report Transaction Detail
  static const String totalItems = 'total_items';
  static const String totalAmount = 'total_amount';
  static const String transactionDetailsNotFound =
      'transaction_details_not_found';
  static const String unknownUser = 'unknown_user';
  static const String staff = 'staff';
  static const String mainHQStore = 'main_hq_store';
  static const String transactionId = 'transaction_id';
  static const String dateAndTime = 'date_and_time';
  static const String cashier = 'cashier';
  static const String role = 'role';
  static const String store = 'store';
  static const String itemDeletedOrUnavailable = 'item_deleted_or_unavailable';
  static const String exportTransaction = 'export_transaction';
  static const String exportDailyReport = 'export_daily_report';
  static const String exportDailyReportDesc = 'export_daily_report_desc';
  static const String exportSingleTransactionDesc =
      'export_single_transaction_desc';

  // -- Notifications
  static const String notificationTitle = "notification_title";
  static const String loadingNotifications = "loading_notifications";
  static const String emptyNotificationTitle = "empty_notification_title";
  static const String emptyNotificationSub = "empty_notification_sub";
  static const String reload = "reload";

  // -- Notification Snackbars & Actions
  static const String notificationDeleted = "notification_deleted";
  static const String undoAvailable = "undo_available";
  static const String connectionError = "connection_error";
  static const String cannotDeleteNotification = "cannot_delete_notification";
  static const String undoButton = "undo_button";

  // -- Time Ago
  static const String daysAgo = "days_ago";
  static const String hoursAgo = "hours_ago";
  static const String minutesAgo = "minutes_ago";
  static const String justNow = "just_now";

  // -- Notification Filters
  static const String filterAll = "filter_all";
  static const String filterAlerts = "filter_alerts";
  static const String filterTransactions = "filter_transactions";
  static const String filterSystem = "filter_system";
  static const String filterLowStock = "filter_low_stock";
  static const String filterDiscrepancy = "filter_discrepancy";
  static const String filterReorder = "filter_reorder";
  static const String filterImport = "filter_import";
  static const String filterExport = "filter_export";

  // -- Notification Router & Errors
  static const String storeNotFound = "store_not_found";
  static const String cannotAccessStore = "cannot_access_store";
  static const String sessionExpiredTitle = "session_expired_title";
  static const String sessionExpiredMessage = "session_expired_message";

  //--Profile
  static const String profileTitle = 'profile_title';
  static const String profileNameUser = 'profile_name_user';
  static const String profilePhoneNumber = 'profile_phone_number';
  static const String profileNameStore = 'profile_name_store';
  static const String profileBtnSwitchStore = 'profile_btn_switch_store';
  static const String profileAccount = 'profile_account';
  static const String profileManagement = 'profile_management';
  static const String profileMyAccount = 'profile_my_account';
  static const String profileChangePassword = 'profile_change_password';
  static const String profileUserManagement = 'profile_user_management';
  static const String profileBtnLogout = 'profile_btn_logout';
  static const String profileDialogTitleLogout = 'profile_dialog_title_logout';
  static const String profileDialogDescriptionLogout =
      'profile_dialog_description_logout';
  static const String profileDialogBtnLogout = 'profile_dialog_btn_logout';
  static const String errorLoadingData = "error_loading_data";
  static const String verifyingData = "verifying_data";
  static const String syncDataWarningTitle = "sync_data_warning_title";
  static const String syncDataWarningDesc = "sync_data_warning_desc";
  static const String unsavedChangesTitle = "unsaved_changes_title";
  static const String unsavedChangesDesc = "unsaved_changes_desc";
  static const String exitAnyway = "exit_anyway";
  static const String inventoryUpdatedSuccess = "inventory_updated_success";
  static const String noReasonNeededWarning = "no_reason_needed_warning";
  static const String defaultAdjustmentNote = "default_adjustment_note";
  static const String itemFoundText = "item_found_text";
  static const String defaultUnit = "default_unit";
  static const String specificNoteHint = "specific_note_hint";

  //--Edit profile
  static const String editTitle = 'edit_title';
  static const String editLoading = 'edit_loading';
  static const String editName = 'edit_name';
  static const String editEmail = 'edit_email';
  static const String editHintName = 'edit_hint_name';
  static const String editHintEmail = 'edit_hint_email';
  static const String editUpdate = 'edit_update';
  static const String editPhoneNumberEmpty = 'edit_phone_number_empty';
  static const String editPhoneNumberInvalid = 'edit_phone_number_invalid';
  static const String editPhoneNumber = 'edit_phone_number';
  static const String editPhoneNumberHint = 'edit_phone_number_hint';
  static const String editErrorEmptyFieldsTitle =
      'edit_error_empty_fields_title';
  static const String editErrorEmptyFieldsMessage =
      'edit_error_empty_fields_message';
  static const String confirmUpdateDescription = 'confirm_update_description';
  static const String confirmUpdate = 'confirm_update';

  //--Change password
  static const String changePasswordTitle = "change_password_title";
  static const String changePasswordOldPassword =
      "change_password_old_password";
  static const String changePasswordNewPassword =
      "change_password_new_password";
  static const String changePasswordConfirm = "change_password_confirm";
  static const String changePasswordBtnConfirm = "change_password_btn_confirm";

  static const String changePasswordHintOldPassword =
      "change_password_hint_old_password";
  static const String changePasswordHintNewPassword =
      "change_password_hint_new_password";
  static const String changePasswordHintConfirmPassword =
      "change_password_hint_confirm";
  static const String passwordNotMatch = "password_not_match";
  static const String passwordSameAsOld = "password_same_as_old";
  static const String passwordChangedSuccess = "password_changed_success";
  static const String oldPasswordIncorrect = "old_password_incorrect";
  static const String authSessionExpired = "auth_session_expired";
  static const String systemError = "system_error";
  static const String authError = "auth_error";
  static const String changePasswordDialogDescription =
      "change_password_dialog_description";
  static const String fillAllFields = "fill_all_fields";

  //--Edit store
  static const String editStoreTitle = 'edit_store_title';
  static const String editStoreSubtitle = 'edit_store_subtitle';
  static const String editStoreNameLabel = 'edit_store_name_label';
  static const String editStoreNameHint = 'edit_store_name_hint';
  static const String editStoreAmountMember = 'edit_store_amount_member';
  static const String editStoreBtnEdit = 'edit_store_btn_edit';
  static const String profileUpdateSuccess = 'profile_update_success';
  static const String loadingTitle = 'loading_title';
  static const String editStoreCurrentStore = 'edit_store_current_store';
  static const String profileNoStoreSelected = 'profile_no_store_selected';
  static const String profileUpdateErrorTitle = 'profile_update_error_title';
  static const String loggingOut = 'logging_out';
  static const String logoutErrorTitle = 'logout_error_title';
  static const String editStoreTitleDialog = 'edit_store_title_dialog';
  static const String editStoreSubtitleDialog = 'edit_store_subtitle_dialog';
  static const String editStoreAddressLabel = 'edit_store_address_label';
  static const String editStoreAddressHint = 'edit_store_address_hint';
  static const String profileUpdateError = 'profile_update_error';
  static const String editStoreDialogDescription =
      'edit_store_dialog_description';
  static const String profileUpdateStoreSuccess =
      'profile_update_store_success';

  // --Assigns role
  static const String assignsRoleTitle = 'assigns_role_title';
  static const String assignsRoleSubtitle = 'assigns_role_subtitle';
  static const String assignsRoleBtnSave = 'assigns_role_btn_save';
  static const String assignsRoleBtnCancel = 'assigns_role_btn_cancel';
  static const String assignsRoleManager = 'assigns_role_manager';
  static const String assignsRoleStaff = 'assigns_role_staff';
  static const String assignsRoleAll = 'assigns_role_all';
  static const String assignsRoleOwner = 'assigns_role_owner';
  static const String assignsRoleSearchHint = 'assigns_role_search_hint';

  //Member
  static const String profileNoMembers = 'profile_no_members';
  static const String profileNoMembersSubtitle = 'profile_no_members_subtitle';

  //-- System
  static const String systemSnackbarTitle = "system_snackbar_title";
  static const String systemSnackbar403Error = "system_snackbar_403_error";

  // -- Smart Decision (Reorder Suggestion)
  static const String reorderReportTitle = "reorder_report_title";
  static const String aiAnalyzingStock = "ai_analyzing_stock";
  static const String optimalStockTitle = "optimal_stock_title";
  static const String optimalStockDesc = "optimal_stock_desc";
  static const String productLabel = "product_label";
  static const String currentStockLabel = "current_stock_label";
  static const String alertThresholdLabel = "alert_threshold_label";
  static const String suggestedImportLabel = "suggested_import_label";
}
