import 'package:frontend/features/auth/bindings/forgot_password_binding.dart';
import 'package:frontend/features/auth/bindings/login_binding.dart';
import 'package:frontend/features/auth/bindings/register_binding.dart';
import 'package:frontend/features/auth/bindings/verify_email_binding.dart';
import 'package:frontend/features/auth/views/forgot_password_view.dart';
import 'package:frontend/features/auth/views/login_view.dart';
import 'package:frontend/features/auth/views/register_view.dart';
import 'package:frontend/features/auth/views/verify_email_view.dart';
import 'package:frontend/features/home/bindings/adjustment_history_binding.dart';
import 'package:frontend/features/home/bindings/low_stock_binding.dart';
import 'package:frontend/features/home/views/adjustment_history_view.dart';
import 'package:frontend/features/home/views/home_view.dart';
import 'package:frontend/features/home/views/low_stock_view.dart';
import 'package:frontend/features/inventory/bindings/all_products_binding.dart';
import 'package:frontend/features/inventory/bindings/category_form_binding.dart';
import 'package:frontend/features/inventory/bindings/category_detail_binding.dart';
import 'package:frontend/features/inventory/bindings/customize_catalog_binding.dart';
import 'package:frontend/features/inventory/bindings/inventory_detail_binding.dart';
import 'package:frontend/features/inventory/bindings/inventory_insight_binding.dart';
import 'package:frontend/features/inventory/bindings/product_catalog_bindings.dart';
import 'package:frontend/features/inventory/bindings/product_catalog_detail_binding.dart';
import 'package:frontend/features/inventory/bindings/product_form_binding.dart';
import 'package:frontend/features/inventory/views/all_products_view.dart';
import 'package:frontend/features/inventory/views/category_form_view.dart';
import 'package:frontend/features/inventory/views/category_detail_view.dart';
import 'package:frontend/features/inventory/views/customize_catalog_view.dart';
import 'package:frontend/features/inventory/views/inventory_detail_view.dart';
import 'package:frontend/features/inventory/views/inventory_insight_view.dart';
import 'package:frontend/features/inventory/views/inventory_view.dart';
import 'package:frontend/features/inventory/views/product_catalog_detail_view.dart';
import 'package:frontend/features/inventory/views/product_catalog_view.dart';
import 'package:frontend/features/inventory/views/product_form_view.dart';
import 'package:frontend/features/navigation/bindings/navigation_binding.dart';
import 'package:frontend/features/navigation/views/navigation_view.dart';
import 'package:frontend/features/notification/bindings/reorder_suggestion_binding.dart';
import 'package:frontend/features/notification/view/notification_view.dart';
import 'package:frontend/features/notification/view/reorder_suggestion_view.dart';
import 'package:frontend/features/onboarding/bindings/onboarding_binding.dart';
import 'package:frontend/features/profile/bindings/profile_assigns_role_binding.dart';
import 'package:frontend/features/profile/bindings/profile_binding.dart';
import 'package:frontend/features/profile/bindings/profile_edit_profile_binding.dart';
import 'package:frontend/features/profile/bindings/profile_edit_store_binding.dart';
import 'package:frontend/features/profile/views/profile_assigns_role_view.dart';
import 'package:frontend/features/profile/views/profile_change_password_view.dart';
import 'package:frontend/features/profile/views/profile_edit_store_view.dart';
import 'package:frontend/features/profile/views/profile_edit_view.dart';
import 'package:frontend/features/profile/views/profile_view.dart';
import 'package:frontend/features/report/bindings/report_transaction_detail_binding.dart';
import 'package:frontend/features/report/views/platform/report_transaction_detail_mobile_view.dart';
import 'package:frontend/features/report/views/report_view.dart';
import 'package:frontend/features/search/bindings/search_binding.dart';
import 'package:frontend/features/search/views/search_view.dart';
import 'package:frontend/features/transaction/bindings/inbound_transaction_binding.dart';
import 'package:frontend/features/transaction/bindings/outbound_transaction_binding.dart';
import 'package:frontend/features/transaction/bindings/inbound_transaction_item_add_binding.dart';
import 'package:frontend/features/transaction/bindings/outbound_transaction_item_add_binding.dart';
import 'package:frontend/features/transaction/bindings/stock_adjustment_binding.dart';
import 'package:frontend/features/transaction/bindings/stock_adjustment_item_binding.dart';
import 'package:frontend/features/transaction/bindings/transaction_summary_binding.dart';
import 'package:frontend/features/transaction/views/inbound_transaction_view.dart';
import 'package:frontend/features/transaction/views/outbound_transaction_item_add_view.dart';
import 'package:frontend/features/transaction/views/outbound_transaction_view.dart';
import 'package:frontend/features/transaction/views/inbound_transaction_item_add_view.dart';
import 'package:frontend/features/transaction/views/stock_adjustment_item_view.dart';
import 'package:frontend/features/transaction/views/stock_adjustment_view.dart';
import 'package:frontend/features/transaction/views/transaction_summary_view.dart';
import 'package:frontend/features/workspace/bindings/add_members_binding.dart';
import 'package:frontend/features/workspace/bindings/create_store_binding.dart';
import 'package:frontend/features/workspace/bindings/join_store_binding.dart';
import 'package:frontend/features/workspace/bindings/store_selection_binding.dart';
import 'package:frontend/features/workspace/views/add_members_view.dart';
import 'package:frontend/features/workspace/views/create_store_view.dart';
import 'package:frontend/features/workspace/views/join_store_view.dart';
import 'package:frontend/features/workspace/views/store_selection_view.dart';
import 'package:frontend/features/workspace/views/workspace_ready_view.dart';
import 'package:get/get.dart';

import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/features/splash/bindings/splash_binding.dart';
import 'package:frontend/features/splash/views/splash_view.dart';
import 'package:frontend/features/onboarding/views/onboarding_view.dart';

class AppPages {
  AppPages._();

  // Đổi từ onboarding sang splash để app luôn khởi động từ màn hình loading
  static const initial = AppRoutes.splash;
  // static const initial = AppRoutes.main;
  static final routes = [
    // -- Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // -- On boarding
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Login
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Register
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Forgot password
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Verify email
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyEmailView(),
      binding: VerfiEmailBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Store Selection
    GetPage(
      name: AppRoutes.storeSelection,
      page: () => const StoreSelectionView(),
      binding: StoreSelectionBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Create Store
    GetPage(
      name: AppRoutes.createStore,
      page: () => const CreateStoreView(),
      binding: CreateStoreBinding(),
      transition: Transition.cupertino,
    ),

    // -- Workspace Ready
    GetPage(
      name: AppRoutes.workspaceReady,
      page: () => const WorkspaceReadyView(),
      transition: Transition.cupertino,
    ),

    // -- Join Store
    GetPage(
      name: AppRoutes.joinStore,
      page: () => const JoinStoreView(),
      binding: JoinStoreBinding(),
      transition: Transition.cupertino,
    ),

    // -- Add member
    GetPage(
      name: AppRoutes.addMembers,
      page: () => const AddMembersView(),
      binding: AddMembersBinding(),
      transition: Transition.cupertino,
    ),

    // -- Main (Navigation)
    GetPage(
      name: AppRoutes.main,
      page: () => const NavigationView(),
      binding: NavigationBinding(),
    ),

    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
      transition: Transition.fadeIn,
    ),

    // -- Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),

    // -- Adjustment History
    GetPage(
      name: AppRoutes.adjustmentHistory,
      page: () => const AdjustmentHistoryView(),
      binding: AdjustmentHistoryBinding(),
      transition: Transition.cupertino,
    ),

    // -- Low Stock
    GetPage(
      name: AppRoutes.lowStock,
      page: () => const LowStockView(),
      binding: LowStockBinding(),
      transition: Transition.cupertino,
    ),

    // -- Inventory
    GetPage(
      name: AppRoutes.inventory,
      page: () => const InventoryView(),
    ),

    // -- Inventory List
    GetPage(
      name: AppRoutes.inventorySight,
      page: () => const InventoryInsightView(),
      binding: InventoryListBinding(),
      transition: Transition.cupertino,
    ),

    // -- Inventory Detail
    GetPage(
      name: AppRoutes.inventoryDetail,
      page: () => const InventoryDetailView(),
      binding: InventoryDetailBinding(),
      transition: Transition.cupertino,
    ),

    // -- Product Catalog
    GetPage(
      name: AppRoutes.productCatalog,
      page: () => const ProductCatalogView(),
      binding: ProductCatalogBinding(),
      transition: Transition.cupertino,
    ),

    // -- All Products
    GetPage(
      name: AppRoutes.allProducts,
      page: () => const AllProductsView(),
      binding: AllProductsBinding(),
      transition: Transition.cupertino,
    ),

    // -- Category Detail
    GetPage(
      name: AppRoutes.categoryDetail,
      page: () => const CategoryDetaiView(),
      binding: CategoryDetailBinding(),
      transition: Transition.cupertino,
    ),

    // -- Product Catalog Detail
    GetPage(
      name: AppRoutes.productCatalogDetail,
      page: () => const ProductCatalogDetailView(),
      binding: ProductCatalogDetailBinding(),
      transition: Transition.cupertino,
    ),

    // -- Category Form
    GetPage(
      name: AppRoutes.categoryForm,
      page: () => const CategoryFormView(),
      binding: CategoryFormBinding(),
      transition: Transition.cupertino,
    ),

    // -- Product Form
    GetPage(
      name: AppRoutes.productForm,
      page: () => const ProductFormView(),
      binding: ProductFormBinding(),
      transition: Transition.cupertino,
    ),

    // -- Customize Catalog
    GetPage(
      name: AppRoutes.customizeCatalog,
      page: () => const CustomizeCatalogView(),
      binding: CustomizeCatalogBinding(),
      transition: Transition.cupertino,
    ),

    // -- Inbound Transaction Item Add
    GetPage(
      name: AppRoutes.inboundTransaction,
      page: () => const InboundTransactionView(),
      binding: InboundTransactionBinding(),
      transition: Transition.cupertino,
    ),

    // -- Inbound Transaction Item Add
    GetPage(
      name: AppRoutes.inboundTransactionItemAdd,
      page: () => const InboundTransactionItemAddView(),
      binding: InboundTransactionItemAddBinding(),
      transition: Transition.cupertino,
    ),

    // -- Outbound Transaction
    GetPage(
      name: AppRoutes.outboundTransaction,
      page: () => const OutboundTransactionView(),
      binding: OutboundTransactionBinding(),
      transition: Transition.cupertino,
    ),

    // -- Outbound Transaction Item Add
    GetPage(
      name: AppRoutes.outboundTransactionItemAdd,
      page: () => const OutboundTransactionItemAddView(),
      binding: OutboundTransactionItemAddBinding(),
      transition: Transition.cupertino,
    ),

    // -- Stock Adjustment
    GetPage(
      name: AppRoutes.stockAdjustment,
      page: () => const StockAdjustmentView(),
      binding: StockAdjustmentBinding(),
      transition: Transition.cupertino,
    ),

    // -- Stock Adjustment
    GetPage(
      name: AppRoutes.stockAdjustmentItem,
      page: () => const StockAdjustmentItemView(),
      binding: StockAdjustmentItemBinding(),
      transition: Transition.cupertino,
    ),

    // -- Transaction Summary
    GetPage(
      name: AppRoutes.transactionSummary,
      page: () => const TransactionSummaryView(),
      binding: TransactionSummaryBinding(),
      transition: Transition.cupertino,
    ),

    // -- Report
    GetPage(
      name: AppRoutes.report,
      page: () => const ReportView(),
    ),

    GetPage(
      name: AppRoutes.transactionDetail,
      page: () => const ReportTransactionDetailView(),
      binding: ReportTransactionDetailBinding(),
      transition: Transition.cupertino,
    ),

    // -- Notification
    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationView(),
    ),

    // -- Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
    ),

    // -- Edit profile
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const ProfileEditView(),
      binding: ProfileEditBinding(),
      transition: Transition.cupertino,
    ),

    //-- Change password
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ProfileChangePasswordView(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
    ),

    //-- Edit Store
    GetPage(
      name: AppRoutes.editStore,
      page: () => const ProfileEditStoreView(),
      binding: ProfileEditStoreBinding(),
      transition: Transition.cupertino,
    ),

    // -- Assign Role
    GetPage(
      name: AppRoutes.assignsRole,
      page: () => const ProfileAssignsRoleView(),
      binding: ProfileAssignsRoleBinding(),
      transition: Transition.cupertino,
    ),

    // -- Reorder suggestion
    GetPage(
        name: AppRoutes.reorderSuggestion,
        page: () => const ReorderSuggestionView(),
        binding: ReorderSuggestionBinding()),
  ];
}
