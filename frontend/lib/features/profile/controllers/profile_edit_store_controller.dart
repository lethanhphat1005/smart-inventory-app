import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/models/store_member_model.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/profile/providers/store_provider.dart';
import 'package:frontend/features/profile/providers/store_member_provider.dart';

class ProfileEditStoreController extends GetxController {
  static ProfileEditStoreController get instance => Get.find();

  // Services & Providers
  final _storeService = Get.find<StoreService>();
  final _storeProvider = StoreProvider();
  final _storeMemberProvider = StoreMemberProvider();

  // Controllers cho các ô nhập liệu (TextField)
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final mapController = MapController();

  // GlobalKey để validate Form
  GlobalKey<FormState> editStoreFormKey = GlobalKey<FormState>();

  // States
  final isLoading = false.obs;
  final isLoadingAddress = false.obs;
  final isEditing = false.obs;

  final storeAddress = ''.obs;
  final memberCount = 0.obs;

  // Members states
  final isLoadingMembers = false.obs;
  final hasLoadedMembers = false.obs;
  final members = <StoreMemberModel>[].obs;
  final filteredMembers = <StoreMemberModel>[].obs;

  final selectedLocation = const LatLng(10.762622, 106.660172).obs;
  final addressPredictions = <dynamic>[].obs;

  final _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    _initializeFields();
    loadStoreExtraData();
    loadMembers(showLoading: true);
  }

  /// Nạp dữ liệu cũ vào các ô nhập liệu khi vừa mở dialog
  void _initializeFields() {
    nameController.text = _storeService.currentStoreName.value;

    if (_storeService.currentStoreAddress.value.isNotEmpty) {
      addressController.text = _storeService.currentStoreAddress.value;
      storeAddress.value = _storeService.currentStoreAddress.value;
    }
  }

  /// Load địa chỉ thật từ database
  Future<void> loadStoreExtraData() async {
    try {
      final storeId = _storeService.currentStoreId.value;
      if (storeId.isEmpty) return;

      final store = await _storeProvider.getStoreDetail(storeId);
      final fetchedAddress = (store['address'] ?? '').toString();

      storeAddress.value = fetchedAddress;

      if (fetchedAddress.isNotEmpty) {
        addressController.text = fetchedAddress;
        await _storeService.saveStoreAddress(fetchedAddress);
      }
    } catch (e) {
      debugPrint("Load store extra data error: $e");
    }
  }

  /// Load danh sách nhân viên cửa hàng hiện tại
  Future<void> loadMembers({bool showLoading = false}) async {
    try {
      final storeId = _storeService.currentStoreId.value;

      if (storeId.isEmpty) {
        debugPrint("StoreId đang rỗng, không thể load members");
        members.clear();
        filteredMembers.clear();
        memberCount.value = 0;
        hasLoadedMembers.value = true;
        return;
      }

      if (showLoading) {
        isLoadingMembers.value = true;
      }

      final data = await _storeMemberProvider.getStoreMembers(storeId);

      final mappedMembers = data.map<StoreMemberModel>((item) {
        return StoreMemberModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();

      members.assignAll(mappedMembers);
      filteredMembers.assignAll(mappedMembers);
      memberCount.value = mappedMembers.length;
    } catch (e) {
      debugPrint("Lỗi load members: $e");

      if (members.isEmpty) {
        filteredMembers.clear();
        memberCount.value = 0;
      }
    } finally {
      isLoadingMembers.value = false;
      hasLoadedMembers.value = true;
    }
  }

  /// Refresh dữ liệu members
  Future<void> refreshMembers() async {
    await loadMembers(showLoading: false);
  }

  /// Thêm member mới vào list local để UI cập nhật ngay
  void addMemberToList(StoreMemberModel newMember) {
    final alreadyExists = members.any((m) => m.userId == newMember.userId);
    if (alreadyExists) return;

    members.add(newMember);
    filteredMembers.add(newMember);
    memberCount.value = members.length;
  }

  /// Xóa member local
  void removeMemberFromList(String userId) {
    members.removeWhere((m) => m.userId == userId);
    filteredMembers.removeWhere((m) => m.userId == userId);
    memberCount.value = members.length;
  }

  /// Update role local
  void updateMemberRole({
    required String userId,
    required String newRole,
  }) {
    final memberIndex = members.indexWhere((m) => m.userId == userId);
    if (memberIndex != -1) {
      members[memberIndex] = members[memberIndex].copyWith(role: newRole);
    }

    final filteredIndex = filteredMembers.indexWhere((m) => m.userId == userId);
    if (filteredIndex != -1) {
      filteredMembers[filteredIndex] =
          filteredMembers[filteredIndex].copyWith(role: newRole);
    }

    members.refresh();
    filteredMembers.refresh();
  }

  /// Bật/tắt mode chỉnh sửa
  void toggleEditing() {
    if (isLoading.value) return;
    isEditing.value = !isEditing.value;
  }

  void _safeMoveMap(LatLng location) {
    try {
      mapController.move(location, 16.0);
    } catch (e) {
      debugPrint("Map not ready yet: $e");
    }
  }

  // --- 1. TÌM KIẾM ĐỊA CHỈ ---
  Future<void> searchAddress(String query) async {
    if (!isEditing.value) return;

    if (query.trim().length < 3) {
      addressPredictions.clear();
      return;
    }

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
          'countrycodes': 'vn',
        },
        options: Options(headers: {
          'User-Agent': 'StorixApp/1.0',
        }),
      );

      if (response.statusCode == 200) {
        addressPredictions.assignAll(response.data);
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    }
  }

  // --- 2. CHỌN GỢI Ý ĐỊA CHỈ ---
  void onSuggestionSelected(dynamic place) {
    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);
    final newLocation = LatLng(lat, lon);

    selectedLocation.value = newLocation;
    addressController.text = place['display_name'] ?? "";
    addressPredictions.clear();

    _safeMoveMap(newLocation);

    addressController.selection = TextSelection.fromPosition(
      TextPosition(offset: addressController.text.length),
    );
  }

  // --- 3. LẤY VỊ TRÍ GPS ---
  Future<void> getCurrentLocation() async {
    if (!isEditing.value) return;

    try {
      isLoadingAddress.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        TSnackbarsWidget.error(
          title: TTexts.gpsOffTitle.tr,
          message: TTexts.gpsOffMessage.tr,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final newPos = LatLng(position.latitude, position.longitude);
      selectedLocation.value = newPos;
      _safeMoveMap(newPos);

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        addressController.text =
            "${p.street}, ${p.subAdministrativeArea}, ${p.administrativeArea}";
      }
    } catch (e) {
      debugPrint("GPS Error: $e");
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.locationErrorMessage.tr,
      );
    } finally {
      isLoadingAddress.value = false;
    }
  }

  /// Getter lấy dữ liệu hiện tại trong form
  String get currentName => nameController.text.trim();
  String get currentAddress => addressController.text.trim();

  /// Kiểm tra đã nhập đủ dữ liệu bắt buộc chưa
  bool get hasAllRequiredFields {
    return currentName.isNotEmpty && currentAddress.isNotEmpty;
  }

  /// Kiểm tra xem có thay đổi dữ liệu hay không
  bool get hasChanged {
    final originalName = _storeService.currentStoreName.value.trim();
    final originalAddress = _storeService.currentStoreAddress.value.trim();

    return currentName != originalName || currentAddress != originalAddress;
  }

  bool shouldShowConfirmDialog() {
    return hasAllRequiredFields && hasChanged;
  }

  Future<void> updateStore() async {
    await updateStoreDetails();
  }

  /// Logic cập nhật thông tin cửa hàng
  Future<void> updateStoreDetails() async {
    try {
      if (!editStoreFormKey.currentState!.validate()) return;

      if (!hasAllRequiredFields) {
        TSnackbarsWidget.warning(
          title: TTexts.errorTitle.tr,
          message: TTexts.fillAllFields.tr,
        );
        return;
      }

      if (!hasChanged) {
        isEditing.value = false;
        return;
      }

      isLoading.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loadingTitle.tr);

      final Map<String, dynamic> updateData = {
        'name': currentName,
        'address': currentAddress,
        'latitude': selectedLocation.value.latitude,
        'longitude': selectedLocation.value.longitude,
      };

      await _storeProvider.updateStore(updateData);

      await _storeService.updateStoreInfo(
        name: currentName,
        address: currentAddress,
      );

      storeAddress.value = currentAddress;

      FullScreenLoaderUtils.stopLoading();

      await loadStoreExtraData();
      await loadMembers();

      isEditing.value = false;
      Get.back();

      Future.delayed(const Duration(milliseconds: 100), () {
        TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.profileUpdateStoreSuccess.tr,
        );
      });
    } catch (e) {
      debugPrint("Update Store Error: $e");
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.profileUpdateError.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
