import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/state/services/supabase_storage_service.dart';
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

  final RxString formMode = 'create'.obs;
  bool isEditMode = false;

  ProductModel? productToEdit;
  ProductPackageModel? packageToEdit;

  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString existingImageUrl = ''.obs;

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
  final TextEditingController barcodeController = TextEditingController();

  final RxList<UnitModel> allUnits = <UnitModel>[].obs;
  final RxString selectedUnitId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    _loadUnits();
    _parseArguments();

    nameController.addListener(_updateDynamicDisplayName);
    unitNameController.addListener(_updateDynamicDisplayName);
    packageVariantNameController.addListener(_updateDynamicDisplayName);
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
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                  fontFamily: 'Poppins',
                  fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(
                  color: AppColors.subText,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  height: 1.4)),
        ]));
  }

  void _parseArguments() {
    if (Get.arguments == null) return;

    if (Get.arguments is Map) {
      final args = Get.arguments as Map<String, dynamic>;
      formMode.value = args['mode'] ?? 'create';

      if (args['product'] != null) {
        isEditMode = true;
        isCategoryLocked = true;
        productToEdit = args['product'] as ProductModel;

        final freshImageUrl = args['freshImageUrl'];
        final freshName = args['freshName'];
        final freshBrand = args['freshBrand'];

        existingImageUrl.value = freshImageUrl ?? productToEdit!.imageUrl ?? '';
        nameController.text = freshName ?? productToEdit!.name;
        brandController.text = freshBrand ?? productToEdit!.brand ?? '';
      }

      if (args['package'] != null) {
        packageToEdit = args['package'] as ProductPackageModel;

        importPriceController.text = packageToEdit!.importPrice.toString();
        salePriceController.text = packageToEdit!.sellingPrice.toString();
        barcodeController.text = packageToEdit!.barcodeValue ?? '';
        selectedUnitId.value = packageToEdit!.unitId;

        _fetchAndSetThreshold(packageToEdit!.productPackageId);
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

  Future<void> _loadCategories() async {
    try {
      allCategories = await _provider.getCategories();
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

        final fullName = packageToEdit!.displayName;
        final baseName = productToEdit?.name ?? '';

        String variant = fullName;
        if (baseName.isNotEmpty) {
          variant = variant.replaceAll(baseName, '').trim();
        }
        if (unitName.isNotEmpty) {
          variant = variant.replaceAll(unitName, '').trim();
        }

        packageVariantNameController.text = variant;
      }
    } catch (e) {
      debugPrint("Error loading units: $e");
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
  // WIZARD NAVIGATION (NEXT / PREV)
  // ==========================================
  void nextStep() {
    if (currentStep.value == 1) {
      if (baseFormKey.currentState?.validate() != true ||
          selectedCategory.value == null) {
        TSnackbarsWidget.warning(
            title: TTexts.errorTitle.tr, message: TTexts.fillRequiredFields.tr);
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

  // ==========================================
  // PUBLIC ACTIONS VỚI DIALOG (Dùng cho Action Buttons)
  // ==========================================

  // 1. SKIP & CREATE PRODUCT ONLY (Bỏ qua Package)
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
        _executeCreateProductOnly();
      },
    ));
  }

  // 2. CREATE FULL PRODUCT (Có cả Package)
  void saveProduct() {
    if (packageFormKey.currentState?.validate() != true ||
        selectedUnitId.value.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.errorTitle.tr, message: TTexts.fillRequiredFields.tr);
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
        _executeSaveFullProduct();
      },
    ));
  }

  // 3. SAVE PRODUCT INFO (Edit Base Info)
  void saveProductInfo() {
    if (baseFormKey.currentState?.validate() != true ||
        selectedCategory.value == null) {
      TSnackbarsWidget.warning(
          title: TTexts.errorTitle.tr, message: TTexts.fillRequiredFields.tr);
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
        _executeSaveProductInfo();
      },
    ));
  }

  // 4. SAVE PRODUCT IMAGE (Edit Image)
  void saveProductImage() {
    if (selectedImage.value == null) {
      TSnackbarsWidget.warning(
          title: TTexts.errorTitle.tr, message: TTexts.requirePhoto.tr);
      return;
    }
    Get.dialog(TCustomDialogWidget(
      title: TTexts.confirmUpdateTitle.tr,
      description: TTexts.confirmUpdateMessage.tr,
      icon: const Text('🖼️', style: TextStyle(fontSize: 40)),
      primaryButtonText: TTexts.confirm.tr,
      secondaryButtonText: TTexts.cancel.tr,
      onSecondaryPressed: () => Get.back(),
      onPrimaryPressed: () {
        Get.back();
        _executeSaveProductImage();
      },
    ));
  }

  // 5. SAVE PACKAGE DATA (Dùng khi Add/Edit Package lẻ tẻ)
  void savePackageData() {
    if (packageFormKey.currentState?.validate() != true ||
        selectedUnitId.value.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.errorTitle.tr, message: TTexts.fillRequiredFields.tr);
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
        _executeSavePackageData();
      },
    ));
  }

  // 6. XÓA PACKAGE BẰNG DIALOG (Dành cho trang Chi tiết hoặc Catalog)
  void confirmDeletePackage(String packageId) {
    Get.dialog(TCustomDialogWidget(
      title: TTexts.confirmDeleteTitle.tr,
      description: TTexts.confirmDeleteMessage.tr,
      icon: const Text('🗑️', style: TextStyle(fontSize: 40)),
      primaryButtonText: TTexts.delete.tr,
      secondaryButtonText: TTexts.cancel.tr,
      onSecondaryPressed: () => Get.back(),
      onPrimaryPressed: () async {
        Get.back();
        try {
          FullScreenLoaderUtils.openLoadingDialog(TTexts.deleting.tr);
          await _provider.deleteProductPackage(packageId);
          FullScreenLoaderUtils.stopLoading();
          _triggerRefreshAndClose(TTexts.packageDeletedSuccess.tr);
        } catch (e) {
          FullScreenLoaderUtils.stopLoading();
          handleError(e);
        }
      },
    ));
  }

  // ==========================================
  // CORE API SAVE LOGICS (Internal/Private)
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

  int? _getParsedThreshold() {
    final val = int.tryParse(thresholdController.text.trim());
    if (val != null && val > 0) return val;
    return null; // Trả về null nếu trống hoặc <= 0
  }

  Future<void> _executeSaveFullProduct() async {
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
      final newProduct = await _provider.createProduct(productPayload);

      // Định dạng Package Payload theo API mới
      final packagePayload = {
        'displayNameSuffix': packageVariantNameController.text.trim().isNotEmpty
            ? packageVariantNameController.text.trim()
            : null,
        'unitId': selectedUnitId.value,
        'importPrice': double.tryParse(importPriceController.text),
        'sellingPrice': double.tryParse(salePriceController.text),
        'barcodeValue': barcodeController.text.trim().isNotEmpty
            ? barcodeController.text.trim()
            : null,
        'barcodeType': barcodeController.text.trim().isNotEmpty ? 'ean' : null,
      };

      // Payload cho Inventory đi kèm lúc tạo mới
      final inventoryPayload = {
        'quantity': 0,
        'reorderThreshold': _getParsedThreshold(),
      };

      await _provider.createProductPackage(
          newProduct.productId, packagePayload, inventoryPayload);

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

  Future<void> _executeSaveProductImage() async {
    if (isSaving.value) return;
    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final newImageUrl = await _supabaseStorageService.uploadImage(
          imageFile: selectedImage.value!, folderPath: 'products');
      if (newImageUrl == null) throw Exception("Upload failed");

      await _provider
          .updateProduct(productToEdit!.productId, {'imageUrl': newImageUrl});

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

      final isUpdate =
          (formMode.value == 'edit_package' && packageToEdit != null);
      final thresholdVal = _getParsedThreshold();

      if (isUpdate) {
        // UPDATE MODE: Chỉ gửi các trường cho phép đổi (Không có unitId)
        final packagePayload = {
          'displayNameSuffix':
              packageVariantNameController.text.trim().isNotEmpty
                  ? packageVariantNameController.text.trim()
                  : null,
          'importPrice': double.tryParse(importPriceController.text),
          'sellingPrice': double.tryParse(salePriceController.text),
          'barcodeValue': barcodeController.text.trim().isNotEmpty
              ? barcodeController.text.trim()
              : null,
          'barcodeType':
              barcodeController.text.trim().isNotEmpty ? 'ean' : null,
        };

        await _provider.updateProductPackage(
            packageToEdit!.productPackageId, packagePayload);
        await _provider.updateInventorySettings(packageToEdit!.productPackageId,
            reorderThreshold: thresholdVal);

        FullScreenLoaderUtils.stopLoading();
        _triggerRefreshAndClose(TTexts.packageUpdatedSuccess.tr);
      } else {
        // CREATE PACKAGE LẺ MODE
        final packagePayload = {
          'displayNameSuffix':
              packageVariantNameController.text.trim().isNotEmpty
                  ? packageVariantNameController.text.trim()
                  : null,
          'unitId': selectedUnitId.value,
          'importPrice': double.tryParse(importPriceController.text),
          'sellingPrice': double.tryParse(salePriceController.text),
          'barcodeValue': barcodeController.text.trim().isNotEmpty
              ? barcodeController.text.trim()
              : null,
          'barcodeType':
              barcodeController.text.trim().isNotEmpty ? 'ean' : null,
        };
        final inventoryPayload = {
          'quantity': 0,
          'reorderThreshold': thresholdVal,
        };

        final newPackageData = await _provider.createProductPackage(
            productToEdit!.productId, packagePayload, inventoryPayload);
        final createdPkg = ProductPackageModel.fromJson(newPackageData);

        FullScreenLoaderUtils.stopLoading();
        _triggerRefreshAndClose(TTexts.packageCreatedSuccess.tr,
            updatedPackage: createdPkg);
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
              title: TTexts.errorTitle.tr,
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

    Get.back();
    Future.delayed(const Duration(milliseconds: 300), () {
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr, message: successMessage);
    });
  }

  void openCategoryPicker() {
    if (isCategoryLocked) return;

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
                              fontFamily: 'Poppins',
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
    super.onClose();
  }
}
