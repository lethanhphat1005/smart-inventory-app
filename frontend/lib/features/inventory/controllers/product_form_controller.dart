import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/state/services/supabase_storage_service.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:frontend/core/ui/widgets/t_primary_button_widget.dart';
import 'package:frontend/features/inventory/models/package_draft_model.dart';
import 'package:frontend/features/inventory/widgets/shared/inventory_product_package_form_fields_widget.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/unit_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_detail_controller.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';

class ProductFormController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();
  final SupabaseStorageService _supabaseStorageService =
      SupabaseStorageService();

  final GlobalKey<FormState> baseFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> packageFormKey = GlobalKey<FormState>();

  final RxInt currentStep = 1.obs;
  final RxBool isSaving = false.obs;
  final RxBool isPickingImage = false.obs;
  String? initialBarcode;
  bool _isInitialBarcodeUsed = false;

  final RxString formMode = 'create'.obs;
  bool isEditMode = false;

  ProductModel? productToEdit;
  ProductPackageModel? packageToEdit;

  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString existingImageUrl = ''.obs;
  String originalImageUrl = '';
  final RxBool isLoadingData = true.obs;
  bool _isDeleteDialogShowing = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();

  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  List<CategoryModel> allCategories = [];
  bool isCategoryLocked = false;

  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController packageDisplayNameController =
      TextEditingController();
  final TextEditingController packageVariantNameController =
      TextEditingController();

  final TextEditingController importPriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController thresholdController = TextEditingController();
  final TextEditingController quantityController =
      TextEditingController(text: '0');

  final RxList<UnitModel> allUnits = <UnitModel>[].obs;
  final RxString selectedUnitId = ''.obs;

  // ==========================================
  // XỬ LÝ BARCODE LIST & GIÁ TIỀN CHO PRODUCT PACKAGE
  // ==========================================

  final RxList<String> packageBarcodes = <String>[].obs;
  final RxList<String> originalBarcodes = <String>[].obs;
  final RxList<String> pendingDeleteBarcodes = <String>[].obs;
  final RxList<PackageDraft> packageDrafts = <PackageDraft>[].obs;
  final TextEditingController barcodeInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    _initializeData();

    nameController.addListener(_updateDynamicDisplayName);
    unitNameController.addListener(_updateDynamicDisplayName);
    packageVariantNameController.addListener(_updateDynamicDisplayName);
  }

  Future<void> _initializeData() async {
    isLoadingData.value = true;
    try {
      // Chờ toàn bộ các tiến trình lấy dữ liệu chạy xong
      await Future.wait([
        _loadCategories(),
        _loadUnits(),
        _parseArgumentsAsync(),
      ]);
    } catch (e) {
      handleError(e);
    } finally {
      // Dù thành công hay lỗi thì cũng phải tắt shimmer để hiện UI
      isLoadingData.value = false;
    }
  }

  Future<void> _parseArgumentsAsync() async {
    if (Get.arguments == null) return;

    if (Get.arguments is Map) {
      final args = Get.arguments as Map<String, dynamic>;
      formMode.value = args['mode'] ?? 'create';

      if (formMode.value == 'create') {
        if (formMode.value == 'create') {
          if (args['barcode'] != null) {
            initialBarcode = args['barcode'];
            packageBarcodes.add(args['barcode']);
          }
        }
        if (args['freshName'] != null) {
          nameController.text = args['freshName'];
        }
        if (args['freshBrand'] != null) {
          brandController.text = args['freshBrand'];
        }
      }

      if (args['product'] != null) {
        isEditMode = true;
        isCategoryLocked = true;
        productToEdit = args['product'] as ProductModel;

        final freshImageUrl = args['freshImageUrl'];
        final freshName = args['freshName'];
        final freshBrand = args['freshBrand'];

        existingImageUrl.value = freshImageUrl ?? productToEdit!.imageUrl ?? '';
        originalImageUrl = existingImageUrl.value;

        nameController.text = freshName ?? productToEdit!.name;
        brandController.text = freshBrand ?? productToEdit!.brand ?? '';
      }
      if (args['package'] != null) {
        packageToEdit = args['package'] as ProductPackageModel;

        importPriceController.text = packageToEdit!.importPrice.toString();
        salePriceController.text = packageToEdit!.sellingPrice.toString();
        selectedUnitId.value = packageToEdit!.unitId;
        packageVariantNameController.text = packageToEdit!.variant ?? '';

        packageBarcodes.clear();
        originalBarcodes.clear();
        pendingDeleteBarcodes.clear();

        if (packageToEdit!.barcodes.isNotEmpty) {
          final codes = packageToEdit!.barcodes.map((b) => b.barcode).toList();
          packageBarcodes.assignAll(codes);
          originalBarcodes.assignAll(codes);
        } else if (packageToEdit!.barcodeValue?.isNotEmpty == true) {
          packageBarcodes.add(packageToEdit!.barcodeValue!);
          originalBarcodes.add(packageToEdit!.barcodeValue!);
        }

        await _fetchAndSetThreshold(packageToEdit!.productPackageId);
      }

      if (args['category'] != null) {
        isCategoryLocked = true;
        selectedCategory.value = args['category'] as CategoryModel;
      }
    } else if (Get.arguments is CategoryModel) {
      isCategoryLocked = true;
      selectedCategory.value = Get.arguments as CategoryModel;
    }
  }

  void _updateDynamicDisplayName() {
    final baseName = nameController.text.isNotEmpty
        ? nameController.text.trim()
        : (productToEdit?.name ?? '');
    final unitName = unitNameController.text.trim();
    final variant = packageVariantNameController.text.trim();

    final parts =
        [baseName, unitName, variant].where((e) => e.isNotEmpty).join(' ');
    packageDisplayNameController.text = parts;
  }

  List<String> get variantNameSuggestions {
    final _ = allUnits.length;
    final unitId = selectedUnitId.value;
    if (unitId.isEmpty) return [];

    final unit = allUnits.firstWhereOrNull((u) => u.unitId == unitId);
    if (unit == null) return [];

    final unitCode = unit.code.toUpperCase();
    List<String> suggestions = [];

    switch (unitCode) {
      case 'CAN':
      case 'BTL':
        suggestions.addAll(['330ml', '500ml', '1.5L']);
        break;
      case 'BOX':
      case 'CRT':
        suggestions.addAll(['6-Pack', '12-Pack', '24-Pack']);
        break;
      case 'PKT':
      case 'BAG':
        suggestions.addAll(['Small', 'Large', '500g', '1kg']);
        break;
      case 'PCS':
        suggestions.addAll(['Standard', 'Premium', 'Single']);
        break;
      case 'TUBE':
        suggestions.addAll(['50g', '150ml']);
        break;
      default:
        suggestions.addAll(['Standard', 'Premium']);
    }
    return suggestions;
  }

  void selectVariantSuggestion(String suggestion) {
    packageVariantNameController.text = suggestion;
  }

  void showInstructionBottomSheet() {
    TBottomSheetWidget.show(
        title: TTexts.instructionTitle.tr,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionItem(
                  TTexts.baseInfo.tr, TTexts.instructionBaseInfo.tr),
              _buildInstructionItem(
                  TTexts.productImage.tr, TTexts.instructionImage.tr),
              _buildInstructionItem(
                  TTexts.packageInfo.tr, TTexts.instructionPackage.tr),
            ],
          ),
        ));
  }

  Widget _buildInstructionItem(String title, String desc) {
    return Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                  fontFamily: AppFonts.mainFont,
                  fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc,
              style: TextStyle(
                  color: AppColors.subText,
                  fontSize: 13,
                  fontFamily: AppFonts.mainFont,
                  height: 1.4)),
        ]));
  }

  Future<void> _loadCategories() async {
    try {
      allCategories = await _provider.getCategories();

      allCategories
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      if (isEditMode && productToEdit != null) {
        selectedCategory.value = allCategories
            .firstWhereOrNull((c) => c.categoryId == productToEdit!.categoryId);
        final currentCat = selectedCategory.value;
        if (currentCat != null &&
            (currentCat.isDefault ||
                currentCat.name.toLowerCase() == 'uncategorized')) {
          isCategoryLocked = false;
        }
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> _loadUnits() async {
    try {
      final fetchedUnits = await _provider.getUnits();
      allUnits.assignAll(fetchedUnits);

      if (selectedUnitId.value.isNotEmpty && packageToEdit != null) {
        final unit =
            allUnits.firstWhereOrNull((u) => u.unitId == selectedUnitId.value);
        final unitName = unit?.name ?? '';
        unitNameController.text = unitName;
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> _fetchAndSetThreshold(String packageId) async {
    try {
      final inv = await _provider.getInventoryDetail(packageId);
      thresholdController.text =
          inv.reorderThreshold == 0 ? '' : inv.reorderThreshold.toString();
    } catch (e) {
      handleError(e);
    }
  }

  // ==========================================
  // WIZARD NAVIGATION
  // ==========================================
  void nextStep() {
    if (currentStep.value == 1) {
      if (baseFormKey.currentState?.validate() != true ||
          selectedCategory.value == null) {
        TSnackbarsWidget.warning(
            title: TTexts.warningTitle.tr,
            message: TTexts.fillRequiredFields.tr);
        return;
      }
      currentStep.value = 2;
    } else if (currentStep.value == 2) {
      if (selectedImage.value == null) {
        Get.dialog(
          TCustomDialogWidget(
            title: TTexts.confirmNoImageTitle.tr,
            description: TTexts.confirmNoImageMessage.tr,
            icon: const Text('🖼️', style: TextStyle(fontSize: 40)),
            primaryButtonText: TTexts.yesContinue.tr,
            secondaryButtonText: TTexts.addPhoto.tr,
            onSecondaryPressed: () => Get.back(),
            onPrimaryPressed: () {
              Get.back();
              currentStep.value = 3;
            },
          ),
          barrierDismissible: false,
        );
        return;
      }
      currentStep.value = 3;
    }
  }

  void previousStep() {
    if (currentStep.value > 1) currentStep.value--;
  }

  void goToInventoryDetail() {
    if (packageToEdit != null && productToEdit != null) {
      Get.toNamed(AppRoutes.inventoryDetail, arguments: {
        'productId': productToEdit!.productId,
        'packageId': packageToEdit!.productPackageId,
      });
    }
  }

  void clearPackageForm() {
    selectedUnitId.value = '';
    unitNameController.clear();
    packageVariantNameController.clear();
    importPriceController.clear();
    salePriceController.clear();
    thresholdController.clear();
    quantityController.text = '0';
    packageBarcodes.clear();
    pendingDeleteBarcodes.clear();
    barcodeInputController.clear();
    packageDisplayNameController.clear();
    if (initialBarcode != null && !_isInitialBarcodeUsed) {
      packageBarcodes.add(initialBarcode!);
    }
  }

  void editPackageInList(int index) {
    final draft = packageDrafts[index];

    // Đổ ngược dữ liệu từ mảng tạm vào các ô nhập liệu
    selectedUnitId.value = draft.unitId;
    unitNameController.text = draft.unitName;
    packageVariantNameController.text = draft.variant;
    importPriceController.text =
        draft.importPrice == 0 ? '' : draft.importPrice.toString();
    salePriceController.text =
        draft.salePrice == 0 ? '' : draft.salePrice.toString();
    thresholdController.text =
        draft.threshold == 0 ? '' : draft.threshold.toString();
    quantityController.text = draft.quantity.toString();

    // Nạp lại danh sách mã vạch riêng của item này
    packageBarcodes.assignAll(draft.barcodes);
    _updateDynamicDisplayName();

    TBottomSheetWidget.show(
      title: TTexts.editPackage.tr,
      child: Column(
        children: [
          const InventoryProductPackageFormFieldsWidget(),
          const SizedBox(height: 24),
          TPrimaryButtonWidget(
            text: TTexts.saveChanges.tr,
            onPressed: () {
              if (packageFormKey.currentState?.validate() != true ||
                  selectedUnitId.value.isEmpty) {
                TSnackbarsWidget.warning(
                    title: TTexts.warningTitle.tr,
                    message: TTexts.fillRequiredFields.tr);
                return;
              }

              packageDrafts[index] = PackageDraft(
                unitId: selectedUnitId.value,
                unitName: unitNameController.text.trim(),
                variant: packageVariantNameController.text.trim(),
                importPrice: parsePrice(importPriceController.text) ?? 0.0,
                salePrice: parsePrice(salePriceController.text) ?? 0.0,
                threshold: _getParsedThreshold(),
                quantity: _getParsedQuantity(),
                barcodes: List.from(packageBarcodes),
              );

              Get.back();
              clearPackageForm();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void addPackageToList() {
    if (packageFormKey.currentState?.validate() != true ||
        selectedUnitId.value.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.fillRequiredFields.tr);
      return;
    }

    final draft = PackageDraft(
      unitId: selectedUnitId.value,
      unitName: unitNameController.text.trim(),
      variant: packageVariantNameController.text.trim(),
      importPrice: parsePrice(importPriceController.text) ?? 0.0,
      salePrice: parsePrice(salePriceController.text) ?? 0.0,
      threshold: _getParsedThreshold(),
      quantity: _getParsedQuantity(),
      barcodes: List.from(packageBarcodes), // Copy danh sách barcode
    );

    packageDrafts.add(draft);
    _isInitialBarcodeUsed = true;
    Get.back(); // Đóng BottomSheet nhập liệu
    clearPackageForm(); // Dọn form cho lần nhập sau
  }

// 4. Hàm xóa package khỏi danh sách
  void removePackageDraft(int index) {
    packageDrafts.removeAt(index);
  }

  // ==========================================
  // PUBLIC ACTIONS (CÓ DELAY CHỐNG COLLISION KHI ĐÓNG POPUP)
  // ==========================================

  void confirmSkipAndCreateProductOnly() {
    Get.dialog(TCustomDialogWidget(
      title: TTexts.confirmSkipPackageTitle.tr,
      description: TTexts.confirmSkipPackageMessage.tr,
      icon: const Text('⏭️', style: TextStyle(fontSize: 40)),
      primaryButtonText: TTexts.createOnlyProduct.tr,
      secondaryButtonText: TTexts.cancel.tr,
      onSecondaryPressed: () => Get.back(),
      onPrimaryPressed: () {
        Get.back();
        Future.delayed(const Duration(milliseconds: 200), () {
          _executeCreateProductOnly();
        });
      },
    ));
  }

  void saveProduct() {
    if (packageDrafts.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.fillRequiredFields.tr);
      return;
    }

    Get.dialog(TCustomDialogWidget(
      title: TTexts.confirmCreateTitle.tr,
      description: TTexts.confirmCreateMessage.tr,
      icon: const Text('📦', style: TextStyle(fontSize: 40)),
      primaryButtonText: TTexts.createFullProduct.tr,
      secondaryButtonText: TTexts.cancel.tr,
      onSecondaryPressed: () => Get.back(),
      onPrimaryPressed: () {
        Get.back();

        Future.delayed(const Duration(milliseconds: 200), () {
          _executeSaveFullProduct();
        });
      },
    ));
  }

  void saveProductInfo() {
    if (baseFormKey.currentState?.validate() != true ||
        selectedCategory.value == null) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.fillRequiredFields.tr);
      return;
    }
    Get.dialog(TCustomDialogWidget(
      title: TTexts.confirmUpdateTitle.tr,
      description: TTexts.confirmUpdateMessage.tr,
      icon: const Text('📝', style: TextStyle(fontSize: 40)),
      primaryButtonText: TTexts.confirm.tr,
      secondaryButtonText: TTexts.cancel.tr,
      onSecondaryPressed: () => Get.back(),
      onPrimaryPressed: () {
        Get.back();
        Future.delayed(const Duration(milliseconds: 200), () {
          _executeSaveProductInfo();
        });
      },
    ));
  }

  void saveProductImage() {
    bool isImageEmptyNow =
        selectedImage.value == null && existingImageUrl.value.isEmpty;
    bool hadImageBefore = originalImageUrl.isNotEmpty;

    // TRƯỜNG HỢP 1: CÓ ẢNH RỒI XÓA ĐI TRỐNG TRƠN -> BẬT DIALOG HỎI XÁC NHẬN
    if (isImageEmptyNow && hadImageBefore) {
      Get.dialog(TCustomDialogWidget(
        title: TTexts.deleteProductImageTitle.tr,
        description: TTexts.deleteProductImageMessage.tr,
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.delete.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
        onPrimaryPressed: () {
          Get.back();
          Future.delayed(const Duration(milliseconds: 200), () {
            // Gọi hàm thực thi với cờ isNullify = true
            _executeSaveProductImage(isNullify: true);
          });
        },
      ));
      return;
    }

    // TRƯỜNG HỢP 2: TRỐNG TỪ ĐẦU, VÀ VẪN CHƯA CHỌN ẢNH -> CẢNH BÁO
    if (isImageEmptyNow && !hadImageBefore) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.requirePhoto.tr);
      return;
    }

    // TRƯỜNG HỢP 3: CÓ ẢNH CŨ NHƯNG KHÔNG THAY ĐỔI GÌ -> ĐÓNG FORM
    if (selectedImage.value == null && existingImageUrl.value.isNotEmpty) {
      Get.back();
      return;
    }

    // TRƯỜNG HỢP 4: THÊM ẢNH MỚI HOẶC ĐỔI ẢNH BÌNH THƯỜNG
    Get.dialog(TCustomDialogWidget(
      title: TTexts.confirmUpdateTitle.tr,
      description: TTexts.confirmUpdateMessage.tr,
      icon: const Text('🖼️', style: TextStyle(fontSize: 40)),
      primaryButtonText: TTexts.confirm.tr,
      secondaryButtonText: TTexts.cancel.tr,
      onSecondaryPressed: () => Get.back(),
      onPrimaryPressed: () {
        Get.back();
        Future.delayed(const Duration(milliseconds: 200), () {
          // Gọi hàm thực thi với cờ isNullify = false
          _executeSaveProductImage(isNullify: false);
        });
      },
    ));
  }

  void savePackageData() {
    if (packageFormKey.currentState?.validate() != true ||
        selectedUnitId.value.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.fillRequiredFields.tr);
      return;
    }

    if (parsePrice(importPriceController.text) == null ||
        parsePrice(salePriceController.text) == null) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.invalidPrice.tr);
      return;
    }

    bool isUpdate = formMode.value == 'edit_package';

    Get.dialog(TCustomDialogWidget(
      title: isUpdate
          ? TTexts.confirmUpdateTitle.tr
          : TTexts.confirmCreateTitle.tr,
      description: isUpdate
          ? TTexts.confirmUpdateMessage.tr
          : TTexts.confirmCreateMessage.tr,
      icon: const Text('💾', style: TextStyle(fontSize: 40)),
      primaryButtonText: TTexts.confirm.tr,
      secondaryButtonText: TTexts.cancel.tr,
      onSecondaryPressed: () => Get.back(),
      onPrimaryPressed: () {
        Get.back();
        // Delay chống kẹt UI trước khi mở loading dialog
        Future.delayed(const Duration(milliseconds: 200), () {
          _executeSavePackageData();
        });
      },
    ));
  }

  void confirmDeletePackage(String packageId) async {
    if (_isDeleteDialogShowing) return;

    // Ở form, packageToEdit là package đang được thao tác
    if (packageToEdit == null || packageToEdit!.productPackageId != packageId) {
      return;
    }

    _isDeleteDialogShowing = true;
    final package = packageToEdit!;

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loading.tr);

      // 1. Lấy dữ liệu tồn kho từ API
      final inv = await _provider.getInventoryDetail(packageId);
      final int currentQuantity = inv.quantity;

      FullScreenLoaderUtils.stopLoading();

      // 2. NẾU CÒN TỒN KHO -> Bật Dialog yêu cầu xuất kho
      if (currentQuantity > 0) {
        await Get.dialog(
          TCustomDialogWidget(
            title: TTexts.inventoryNotEmptyTitle.tr,
            description:
                '${TTexts.inventoryNotEmptyMessage.tr}\n\n(${TTexts.currentStockWithCount.trParams({
                  'count': currentQuantity.toString()
                })})',
            icon: const Text('📦', style: TextStyle(fontSize: 40)),
            primaryButtonText: TTexts.clearStock.tr,
            secondaryButtonText: TTexts.cancel.tr,
            onSecondaryPressed: () => Get.back(),
            onPrimaryPressed: () {
              Get.back(); // Đóng dialog

              // Đóng sạch các popup/form để quay về màn hình gốc
              Get.until((route) => route.settings.name == AppRoutes.main);

              // Chuyển sang màn hình tạo đơn xuất kho kèm data
              Get.toNamed(AppRoutes.outboundTransaction, arguments: {
                'autoAddItems': [
                  {
                    'package': package,
                    'inventory': inv,
                    'quantity': currentQuantity,
                  }
                ]
              });
            },
          ),
          barrierDismissible: false,
        );
        return;
      }

      // 3. NẾU HẾT HÀNG -> Bật Dialog xác nhận xóa bình thường
      final bool? shouldDelete = await Get.dialog<bool>(
        TCustomDialogWidget(
          title: TTexts.deletePackage.tr,
          description:
              '${TTexts.confirmDeletePackageMessage.tr}\n(${package.displayName})',
          icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.delete.tr,
          secondaryButtonText: TTexts.cancel.tr,
          onSecondaryPressed: () => Get.back(result: false),
          onPrimaryPressed: () => Get.back(result: true),
        ),
        barrierDismissible: false,
      );

      if (shouldDelete == true) {
        FullScreenLoaderUtils.openLoadingDialog(TTexts.deletingPackage.tr);
        await _provider.deleteProductPackage(packageId);
        FullScreenLoaderUtils.stopLoading();

        // Load lại danh sách và đóng Form
        _triggerRefreshAndClose(TTexts.packageDeletedSuccess.tr);
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isDeleteDialogShowing = false;
    }
  }

  void confirmRemoveBarcode(String code) {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmDeleteTitle.tr,
        description:
            '${TTexts.confirmDeleteMessage.tr}\n\n${TTexts.barcodeLabel.tr}: $code',
        icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.delete.tr,
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
        onPrimaryPressed: () {
          try {
            Get.back();
            packageBarcodes.remove(code);
            TSnackbarsWidget.success(
                title: TTexts.successTitle.tr,
                message: '${TTexts.barcodeDeleted.tr}: $code');
          } catch (e) {
            handleError(e);
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  // ==========================================
  // BARCODE LOGICS
  // ==========================================

  void removeOrMarkBarcode(String code) {
    if (originalBarcodes.contains(code)) {
      if (!pendingDeleteBarcodes.contains(code)) {
        pendingDeleteBarcodes.add(code);
      }
    } else {
      packageBarcodes.remove(code);
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: '${TTexts.barcodeDeleted.tr}: $code');
    }
  }

  void undoMarkBarcode(String code) {
    pendingDeleteBarcodes.remove(code);
  }

  void addBarcode(String code) {
    String cleanCode = code.replaceAll(RegExp(r'\x00'), '').trim();

    if (cleanCode.length < 5) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.barcodeTooShort.tr);
      return;
    }
    if (packageBarcodes.contains(cleanCode)) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.barcodeDuplicate.tr);
      return;
    }

    packageBarcodes.add(cleanCode);
    barcodeInputController.clear();
    TSnackbarsWidget.success(
        title: TTexts.successTitle.tr,
        message: '${TTexts.barcodeAdded.tr}: $cleanCode');
  }

  // KIỂM TRA MÃ VẠCH: TRẢ VỀ LỖI STRING ĐỂ BÊN GỌI CHỦ ĐỘNG ĐÓNG LOADING TRƯỚC KHI BẮN SNACKBAR
  Future<String?> _checkBarcodeAvailability() async {
    final newBarcodesToCheck =
        packageBarcodes.where((c) => !originalBarcodes.contains(c)).toList();

    if (newBarcodesToCheck.isEmpty) return null; // Pass

    try {
      for (String barcode in newBarcodesToCheck) {
        final result = await _provider.scanBarcode(barcode);

        if (result['resolutionType'] == 'exact_match') {
          final pkg = result['productPackage'];

          if (formMode.value == 'edit_package' &&
              packageToEdit?.productPackageId == pkg['productPackageId']) {
            continue;
          }

          // Trả về lỗi dạng chuỗi, KHÔNG GỌI SNACKBAR Ở ĐÂY
          return '${TTexts.barcodeDuplicate.tr}: $barcode - ${pkg['displayName']}';
        }
      }
      return null; // Pass
    } catch (e) {
      return TTexts.errorServerMessage.tr;
    }
  }

  double? parsePrice(String value) {
    if (value.isEmpty) return null;
    String normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  int _getParsedThreshold() {
    final text = thresholdController.text.trim();
    if (text.isEmpty) return 0;
    final val = int.tryParse(text);
    if (val != null && val >= 0) return val;
    return 0;
  }

  int _getParsedQuantity() {
    final text = quantityController.text.trim();
    if (text.isEmpty) return 0;
    final val = int.tryParse(text);
    if (val != null && val >= 0) return val;
    return 0; // Trả về 0 nếu nhập sai hoặc để trống
  }

  // ==========================================
  // CORE API SAVE LOGICS
  // ==========================================

  Future<void> _executeCreateProductOnly() async {
    if (isSaving.value) return;
    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      String? imageUrl;
      if (selectedImage.value != null) {
        imageUrl = await _supabaseStorageService.uploadImage(
            imageFile: selectedImage.value!, folderPath: 'products');
      }

      final productPayload = {
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'categoryId': selectedCategory.value!.categoryId,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      await _provider.createProduct(productPayload);

      FullScreenLoaderUtils.stopLoading();
      _triggerRefreshAndClose(TTexts.productCreatedSuccess.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _executeSaveFullProduct() async {
    if (isSaving.value) return;

    if (packageDrafts.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.fillRequiredFields.tr);
      return;
    }

    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      // ==========================================
      // BƯỚC 1: TẠO PRODUCT GỐC
      // ==========================================
      String? imageUrl;
      if (selectedImage.value != null) {
        imageUrl = await _supabaseStorageService.uploadImage(
            imageFile: selectedImage.value!, folderPath: 'products');
      }

      final productPayload = {
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'categoryId': selectedCategory.value!.categoryId,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      final newProduct = await _provider.createProduct(productPayload);

      // ==========================================
      // BƯỚC 2: GOM DATA VÀ GỌI API TẠO NHIỀU PACKAGE (API CŨ CỦA BẠN)
      // ==========================================

      // 2.1 Chuẩn bị mảng payload y hệt như hình bạn chụp
      List<Map<String, dynamic>> bulkPackagesPayload = [];

      for (var draft in packageDrafts) {
        bulkPackagesPayload.add({
          'package': {
            'variant': draft.variant,
            'unitId': draft.unitId,
            'importPrice': draft.importPrice,
            'sellingPrice': draft.salePrice,
          },
          'inventory': {
            'quantity': draft.quantity,
            'reorderThreshold': draft.threshold,
          }
        });
      }

      // 2.2 Bắn mảng này lên server (Gọi 1 lần duy nhất)
      final createdPackagesData = await _provider.createMultipleProductPackages(
          newProduct.productId, bulkPackagesPayload);

      // ==========================================
      // BƯỚC 3: MAP BARCODE (NẾU CÓ)
      // ==========================================
      // Cần map ID trả về từ server với danh sách barcode tương ứng mà user đã nhập
      for (int i = 0; i < createdPackagesData.length; i++) {
        final createdPkg = ProductPackageModel.fromJson(createdPackagesData[i]);
        final originalDraft =
            packageDrafts[i]; // Lấy lại draft tương ứng để lấy barcode

        if (originalDraft.barcodes.isNotEmpty &&
            createdPkg.productPackageId.isNotEmpty) {
          for (String code in originalDraft.barcodes) {
            try {
              await _provider.confirmBarcodeMapping(
                barcode: code,
                productPackageId: createdPkg.productPackageId,
              );
            } catch (e) {
              debugPrint("Lỗi map barcode $code: $e");
            }
          }
        }
      }

      FullScreenLoaderUtils.stopLoading();
      _triggerRefreshAndClose(TTexts.productCreatedSuccess.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _executeSaveProductInfo() async {
    if (isSaving.value) return;
    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final payload = {
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'categoryId': selectedCategory.value!.categoryId,
      };

      await _provider.updateProduct(productToEdit!.productId, payload);
      FullScreenLoaderUtils.stopLoading();
      _triggerRefreshAndClose(TTexts.productUpdatedSuccess.tr,
          newName: nameController.text.trim(),
          newBrand: brandController.text.trim());
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  // Thêm tham số isNullify
  Future<void> _executeSaveProductImage({required bool isNullify}) async {
    if (isSaving.value) return;
    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      String? newImageUrl;

      if (isNullify) {
        // Nếu chọn xóa ảnh: Gọi thẳng API cập nhật thành null
        await _provider
            .updateProduct(productToEdit!.productId, {'imageUrl': null});
        newImageUrl = ''; // Set chuỗi rỗng để UI detail bên kia clear ảnh
      } else {
        // Nếu có chọn ảnh mới: Upload lên Supabase như bình thường
        newImageUrl = await _supabaseStorageService.uploadImage(
            imageFile: selectedImage.value!, folderPath: 'products');

        if (newImageUrl == null) throw Exception("Upload failed");

        await _provider
            .updateProduct(productToEdit!.productId, {'imageUrl': newImageUrl});
      }

      FullScreenLoaderUtils.stopLoading();

      _triggerRefreshAndClose(TTexts.imageUpdatedSuccess.tr,
          newImageUrl: newImageUrl);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _executeSavePackageData() async {
    if (isSaving.value) return;
    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      // 1. Kiểm tra tính hợp lệ của mã vạch
      final barcodeError = await _checkBarcodeAvailability();
      if (barcodeError != null) {
        FullScreenLoaderUtils.stopLoading(); // ĐÓNG LOADING TRƯỚC
        Future.delayed(const Duration(milliseconds: 200), () {
          // SAU ĐÓ MỚI BẮN SNACKBAR ĐỂ KHÔNG BỊ KẸT UI
          TSnackbarsWidget.error(
              title: TTexts.errorServerTitle.tr, message: barcodeError);
        });
        return; // Dừng tiến trình save
      }

      final isUpdate =
          (formMode.value == 'edit_package' && packageToEdit != null);
      final thresholdVal = _getParsedThreshold();

      if (isUpdate) {
        final targetPackageId = packageToEdit!.productPackageId;
        final packagePayload = {
          'variant': packageVariantNameController.text.trim(),
          'unitId': selectedUnitId.value,
          'importPrice': parsePrice(importPriceController.text),
          'sellingPrice': parsePrice(salePriceController.text),
        };

        // Update Info & Threshold
        await _provider.updateProductPackage(targetPackageId, packagePayload);
        await _provider.updateInventorySettings(targetPackageId,
            reorderThreshold: thresholdVal);

        // Gọi API DELETE CÁC MÃ BỊ GẠCH NGANG
        if (pendingDeleteBarcodes.isNotEmpty) {
          for (String code in pendingDeleteBarcodes) {
            try {
              await _provider.deletePackageBarcode(targetPackageId, code);
            } catch (e) {
              handleError(e);
            }
          }
        }

        // Gọi API MAP CÁC MÃ MỚI
        final newBarcodes = packageBarcodes
            .where((c) =>
                !originalBarcodes.contains(c) &&
                !pendingDeleteBarcodes.contains(c))
            .toList();

        if (newBarcodes.isNotEmpty) {
          for (String code in newBarcodes) {
            try {
              await _provider.confirmBarcodeMapping(
                barcode: code,
                productPackageId: targetPackageId,
              );
            } catch (e) {
              handleError(e);
            }
          }
        }

        FullScreenLoaderUtils.stopLoading();
        _triggerRefreshAndClose(TTexts.packageUpdatedSuccess.tr);
      } else {
        final packagePayload = {
          'variant': packageVariantNameController.text.trim(),
          'unitId': selectedUnitId.value,
          'importPrice': parsePrice(importPriceController.text),
          'sellingPrice': parsePrice(salePriceController.text),
        };
        final inventoryPayload = {
          'quantity': _getParsedQuantity(),
          'reorderThreshold': thresholdVal,
        };

        final newPackageData = await _provider.createProductPackage(
            productToEdit!.productId, packagePayload, inventoryPayload);

        final createdPkg = ProductPackageModel.fromJson(newPackageData);

        if (packageBarcodes.isNotEmpty) {
          for (String code in packageBarcodes) {
            try {
              await _provider.confirmBarcodeMapping(
                barcode: code,
                productPackageId: createdPkg.productPackageId,
              );
            } catch (e) {
              handleError(e);
            }
          }
        }

        FullScreenLoaderUtils.stopLoading();
        _triggerRefreshAndClose(
          TTexts.packageCreatedSuccess.tr,
        );
      }
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  // ==========================================
  // IMAGE PICKER & UI HELPERS
  // ==========================================

  Future<void> pickImage(ImageSource source) async {
    if (isPickingImage.value) return;
    try {
      isPickingImage.value = true;
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          TSnackbarsWidget.error(
              title: TTexts.errorServerTitle.tr,
              message: TTexts.cameraPermissionDenied.tr);
          if (status.isPermanentlyDenied) openAppSettings();
          return;
        }
      }

      final XFile? image =
          await _picker.pickImage(source: source, imageQuality: 80);

      if (image != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: TTexts.cropImage.tr,
              toolbarColor: AppColors.background,
              toolbarWidgetColor: AppColors.primaryText,
              backgroundColor: AppColors.background,
              activeControlsWidgetColor: AppColors.primary,
              statusBarColor: AppColors.background,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: false,
              showCropGrid: true,
            ),
            IOSUiSettings(
              title: TTexts.cropImage.tr,
              aspectRatioLockEnabled: true,
              resetButtonHidden: false,
              aspectRatioPickerButtonHidden: true,
              doneButtonTitle: TTexts.done.tr,
              cancelButtonTitle: TTexts.cancel.tr,
            ),
          ],
        );

        if (croppedFile != null) {
          selectedImage.value = File(croppedFile.path);
        }
      }
    } catch (e) {
      if (!e.toString().contains('camera_access_denied')) handleError(e);
    } finally {
      isPickingImage.value = false;
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
    existingImageUrl.value = '';
  }

  void _triggerRefreshAndClose(String successMessage,
      {String? newName,
      String? newBrand,
      String? newImageUrl,
      ProductPackageModel? updatedPackage}) {
    if (Get.isRegistered<CategoryDetailController>()) {
      Get.find<CategoryDetailController>().fetchProducts(isRefresh: true);
    }
    if (Get.isRegistered<ProductCatalogDetailController>()) {
      final detailCtrl = Get.find<ProductCatalogDetailController>();
      if (updatedPackage != null) {
        detailCtrl.updateLocalPackage(updatedPackage);
      } else {
        detailCtrl.fetchPackages(isRefresh: true);
      }
      detailCtrl.updateLocalInfo(
          name: newName, brand: newBrand, imageUrl: newImageUrl);
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      Get.back(); // Đóng trang Form Product
      Future.delayed(const Duration(milliseconds: 300), () {
        TSnackbarsWidget.success(
            title: TTexts.successTitle.tr, message: successMessage);
      });
    });
  }

  void openCategoryPicker() {
    // if (isCategoryLocked) return;

    TBottomSheetWidget.show(
      title: TTexts.selectCategory.tr,
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.4),
        padding: const EdgeInsets.only(bottom: AppSizes.p16),
        child: allCategories.isEmpty
            ? Center(
                child: Text(TTexts.errorNotFoundMessage.tr,
                    style: const TextStyle(color: AppColors.subText)),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: allCategories.length,
                separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AppColors.divider,
                    indent: 12,
                    endIndent: 12),
                itemBuilder: (context, index) {
                  final cat = allCategories[index];
                  return Obx(() {
                    final isSelected =
                        selectedCategory.value?.categoryId == cat.categoryId;
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      title: Text(cat.name,
                          style: TextStyle(
                              fontFamily: AppFonts.mainFont,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primaryText)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 20)
                          : null,
                      onTap: () {
                        selectedCategory.value = cat;
                        Get.back();
                      },
                    );
                  });
                },
              ),
      ),
    );
  }

  void confirmExit() {
    Get.dialog(
        TCustomDialogWidget(
          title: TTexts.discardChangesTitle.tr,
          description: TTexts.discardChangesMessage.tr,
          icon: const Text('⚠️', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.discard.tr,
          secondaryButtonText: TTexts.keepEditing.tr,
          onSecondaryPressed: () => Get.back(),
          onPrimaryPressed: () {
            Get.back();
            Get.back();
          },
        ),
        barrierDismissible: false);
  }

  @override
  void onClose() {
    nameController.removeListener(_updateDynamicDisplayName);
    unitNameController.removeListener(_updateDynamicDisplayName);
    packageVariantNameController.removeListener(_updateDynamicDisplayName);

    unitNameController.dispose();
    packageDisplayNameController.dispose();
    packageVariantNameController.dispose();
    barcodeInputController.dispose();
    quantityController.dispose();
    super.onClose();
  }
}
