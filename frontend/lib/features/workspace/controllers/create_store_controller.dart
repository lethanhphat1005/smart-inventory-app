import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart'; // Bổ sung import
import 'package:frontend/features/navigation/controllers/navigation_controller.dart';

class CreateStoreController extends GetxController {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final mapController = MapController();

  final isLoading = false.obs;
  final isLoadingAddress = false.obs;

  final selectedLocation = const LatLng(10.762622, 106.660172).obs;
  final currentAddress = "".obs;
  bool isMapReady = false;

  // KHÔI PHỤC: Logic gợi ý địa chỉ
  final RxList<dynamic> addressPredictions = <dynamic>[].obs;
  Timer? _debounce;

  final WorkspaceProvider _workspaceProvider = WorkspaceProvider();
  final StoreService _storeService = Get.find<StoreService>();

  // --- LOGIC MAP & GPS ---

  void onMapCreated() {
    isMapReady = true;
    mapController.move(selectedLocation.value, 15.0);
  }

  void onMapTap(TapPosition tapPosition, LatLng point) async {
    selectedLocation.value = point;
    mapController.move(point, mapController.camera.zoom);
    await _getAddressFromLatLng(point);
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoadingAddress.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoadingAddress.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoadingAddress.value = false;
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final newLatLng = LatLng(position.latitude, position.longitude);
      selectedLocation.value = newLatLng;

      if (isMapReady) {
        mapController.move(newLatLng, 15.0);
      }

      await _getAddressFromLatLng(newLatLng);
    } catch (e) {
      debugPrint("Error location: $e");
    } finally {
      isLoadingAddress.value = false;
    }
  }

  Future<void> _getAddressFromLatLng(LatLng point) async {
    try {
      isLoadingAddress.value = true;
      List<Placemark> placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            "${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
        currentAddress.value = address;
        addressController.text = address;
      }
    } catch (e) {
      currentAddress.value = "Unknown address";
    } finally {
      isLoadingAddress.value = false;
    }
  }

  // --- LOGIC SEARCH ĐỊA CHỈ ---

  Future<void> searchAddress(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.isEmpty || query.length < 3) {
      addressPredictions.clear();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final response = await Dio().get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {'q': query, 'format': 'json', 'limit': 5},
          options: Options(headers: {'User-Agent': 'StorixApp/1.0'}),
        );
        addressPredictions.assignAll(response.data);
      } catch (e) {
        debugPrint("Autocomplete Error: $e");
      }
    });
  }

  void onSuggestionSelected(dynamic place) {
    final String displayName = place['display_name'] ?? "";
    addressController.text = displayName;
    currentAddress.value = displayName;
    addressPredictions.clear();

    final lat = double.tryParse(place['lat'].toString()) ?? 0.0;
    final lon = double.tryParse(place['lon'].toString()) ?? 0.0;
    if (lat != 0.0 && lon != 0.0) {
      final newLatLng = LatLng(lat, lon);
      selectedLocation.value = newLatLng;
      if (isMapReady) {
        mapController.move(newLatLng, 16.0);
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // --- LOGIC TẠO WORKSPACE ---

  Future<void> onTryCreateWorkspace() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr, message: TTexts.warningEmptyName.tr);
      return;
    }

    try {
      FullScreenLoaderUtils.openLoadingDialog(TTexts.creatingWorkspace.tr);

      String currentTimezone = 'Asia/Ho_Chi_Minh';
      try {
        // Fix lỗi TimezoneInfo bằng .toString()
        final dynamic tz = await FlutterTimezone.getLocalTimezone();
        currentTimezone = tz.toString();
      } catch (_) {}

      final payload = {
        "name": name,
        "address": addressController.text.trim(),
        "latitude": selectedLocation.value.latitude,
        "longitude": selectedLocation.value.longitude,
        "timezone": currentTimezone,
      };

      final createdStore = await _workspaceProvider.createStore(payload);

      // 1. CẬP NHẬT USER PROFILE NGAY LẬP TỨC (ĐỂ NHẬN ROLE OWNER)
      await Get.find<UserService>().fetchAndSaveProfile();

      // 2. LƯU STORE MỚI VÀO BỘ NHỚ LÀM STORE HIỆN TẠI
      await _storeService.saveSelectedStore(
        createdStore.storeId,
        createdStore.name,
        'owner', // Gán cứng owner vì người tạo chắc chắn là owner
        createdStore.inviteCode ?? '',
      );

      // 3. RESET NAVIGATION VỀ TAB HOME
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().selectedIndex.value = 0;
      }

      FullScreenLoaderUtils.stopLoading();
      Get.offNamed(AppRoutes.workspaceReady,
          arguments: {'storeName': createdStore.name});
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      if (e is DioException && e.response?.statusCode == 409) {
        Get.dialog(TCustomDialogWidget(
          title: TTexts.errorServerTitle.tr,
          description: TTexts.warningStoreExists.tr,
          icon: const Text('🏢', style: TextStyle(fontSize: 40)),
          primaryButtonText: TTexts.tryAgain.tr,
          onPrimaryPressed: () => Get.back(),
        ));
      } else {
        TSnackbarsWidget.error(
            title: TTexts.errorServerTitle.tr, message: e.toString());
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    mapController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
