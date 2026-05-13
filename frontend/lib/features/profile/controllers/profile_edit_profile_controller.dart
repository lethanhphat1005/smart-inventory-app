import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/core/state/provider/user_profile_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:latlong2/latlong.dart';

class ProfileEditController extends GetxController {
  final UserService userService = Get.find<UserService>();
  final UserProfileProvider userProfileProvider = UserProfileProvider();

  GlobalKey<FormState> editProfileFormKey = GlobalKey<FormState>();

  // text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final mapController = MapController();

  final selectedLocation = const LatLng(10.762622, 106.660172).obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingAddress = false.obs;
  final RxBool isEditing = false.obs;
  final RxBool isFetchingProfile = false.obs;

  var completePhoneNumber = "".obs;
  final _dio = Dio();
  final addressPredictions = <dynamic>[].obs;

  static String get notUpdatedYetText => TTexts.profileStatusNotUpdatedYet.tr;

  String _displayOrNotUpdated(String? value) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) return notUpdatedYetText;
    return text;
  }

  String _cleanDisplayValue(String value) {
    final text = value.trim();
    return text == notUpdatedYetText ? "" : text;
  }

  // ===== FIX PHONE =====
  String _normalizePhone(String value) {
    String phone = _cleanDisplayValue(value);

    // Loại bỏ ký tự không phải số
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    return phone;
  }

  bool _isValidVietnamPhone(String phone) {
    // Cho phép rỗng
    if (phone.isEmpty) return true;

    // Bắt buộc đủ 10 số và bắt đầu bằng 0
    return RegExp(r'^0\d{9}$').hasMatch(phone);
  }
  // ===== END FIX PHONE =====

  Future<void> submit() async {
    if (!editProfileFormKey.currentState!.validate()) return;

    final phone = currentPhoneValue;

    // Cho phép rỗng nhưng nếu nhập thì phải đúng
    if (!_isValidVietnamPhone(phone)) {
      TSnackbarsWidget.warning(
        title: TTexts.warningTitle.tr,
        message: TTexts.editPhoneNumberInvalid.tr,
      );
      return;
    }
  }

  // ===== INIT DATA =====
  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
    fetchMyProfile();
  }

  void _safeMoveMap(LatLng location) {
    try {
      mapController.move(location, 16.0);
    } catch (e) {
      debugPrint("Map not ready yet: $e");
    }
  }

  void _initializeUserData() {
    final user = userService.currentUser.value;
    if (user != null) {
      nameController.text = user.fullName;
      emailController.text = user.email;

      if (isEditing.value) {
        addressController.text = user.address ?? "";
        phoneController.text = user.phoneNumber ?? "";
      } else {
        addressController.text = _displayOrNotUpdated(user.address);
        phoneController.text = _displayOrNotUpdated(user.phoneNumber);
      }

      completePhoneNumber.value = user.phoneNumber ?? "";
    }
  }

  Future<void> fetchMyProfile() async {
    try {
      isFetchingProfile.value = true;

      final profile = await userProfileProvider.fetchMyProfile();

      nameController.text = profile.fullName;
      emailController.text = profile.email;

      if (isEditing.value) {
        addressController.text = profile.address ?? "";
        phoneController.text = profile.phoneNumber ?? "";
      } else {
        addressController.text = _displayOrNotUpdated(profile.address);
        phoneController.text = _displayOrNotUpdated(profile.phoneNumber);
      }

      completePhoneNumber.value = profile.phoneNumber ?? "";

      final currentUser = userService.currentUser.value;
      if (currentUser != null) {
        userService.currentUser.value = currentUser.copyWith(
          userId: profile.userId,
          authUserId: profile.authUserId,
          fullName: profile.fullName,
          email: profile.email,
          phoneNumber: profile.phoneNumber ?? "",
          address: profile.address ?? "",
          activeStatus: profile.activeStatus,
          createdAt: profile.createdAt,
          updatedAt: profile.updatedAt,
        );
      }
    } catch (e) {
      debugPrint("Fetch Profile Error: $e");
      _initializeUserData();
    } finally {
      isFetchingProfile.value = false;
    }
  }

  void toggleEditing() {
    if (isLoading.value) return;

    isEditing.value = !isEditing.value;

    _initializeUserData();

    if (!isEditing.value) {
      fetchMyProfile();
      addressPredictions.clear();
    }
  }

  String get currentPhoneValue {
    return _normalizePhone(phoneController.text);
  }

  String get currentAddressValue {
    return _cleanDisplayValue(addressController.text);
  }

  bool get hasAllRequiredFields {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    return name.isNotEmpty && email.isNotEmpty;
  }

  bool get isPhoneValid {
    final phone = currentPhoneValue;

    // Cho phép rỗng
    if (phone.isEmpty) return true;

    return _isValidVietnamPhone(phone);
  }

  bool get hasChangedProfileData {
    final currentUser = userService.currentUser.value;
    if (currentUser == null) return false;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = currentPhoneValue;
    final address = currentAddressValue;

    final originalName = currentUser.fullName.trim();
    final originalEmail = currentUser.email.trim();
    final originalPhone = _normalizePhone(currentUser.phoneNumber ?? '');
    final originalAddress = (currentUser.address ?? '').trim();

    return name != originalName ||
        email != originalEmail ||
        phone != originalPhone ||
        address != originalAddress;
  }

  bool shouldShowConfirmDialog() {
    return hasAllRequiredFields && isPhoneValid && hasChangedProfileData;
  }

  // ---  TÌM KIẾM ĐỊA CHỈ ---
  Future<void> searchAddress(String query) async {
    if (!isEditing.value) return;

    final cleanQuery = _cleanDisplayValue(query);

    if (cleanQuery.length < 3) {
      addressPredictions.clear();
      return;
    }

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': cleanQuery,
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
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.locationErrorMessage.tr,
      );
    }
  }

  // ---  CHỌN GỢI Ý ĐỊA CHỈ ---
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

  // --- LẤY VỊ TRÍ GPS ---
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

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final newPos = LatLng(position.latitude, position.longitude);
      selectedLocation.value = newPos;
      _safeMoveMap(newPos);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
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

  Future<void> handleUpdateProfile() async {
    if (!isEditing.value) {
      toggleEditing();
      return;
    }

    await updateProfile();
  }

  Future<void> updateProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = currentPhoneValue;
    final address = currentAddressValue;

    // 1. Validate form
    if (name.isEmpty || email.isEmpty) {
      TSnackbarsWidget.warning(
        title: TTexts.editErrorEmptyFieldsTitle.tr,
        message: TTexts.fillAllFields.tr,
      );
      return;
    }

    /// validate phone basic
    if (!_isValidVietnamPhone(phone)) {
      TSnackbarsWidget.warning(
        title: TTexts.warningTitle.tr,
        message: TTexts.editPhoneNumberInvalid.tr,
      );
      return;
    }

    if (!hasChangedProfileData) {
      isEditing.value = false;
      _initializeUserData();
      addressPredictions.clear();
      return;
    }

    // 2. Start Loading
    isLoading.value = true;
    FullScreenLoaderUtils.openLoadingDialog(TTexts.editLoading.tr);

    try {
      final currentUser = userService.currentUser.value;

      if (currentUser == null) {
        throw Exception(TTexts.userNotFound.tr);
      }

      final String userId = currentUser.userId;

      if (userId.isEmpty) {
        throw Exception(TTexts.userIdNotFound.tr);
      }

      await userProfileProvider.updateProfile(
        userId,
        {
          'fullName': name,
          'address': address,
          'phone': phone,
        },
      );

      userService.currentUser.value = currentUser.copyWith(
        fullName: name,
        email: email,
        phoneNumber: phone,
        address: address,
      );

      FullScreenLoaderUtils.stopLoading();
      isEditing.value = false;
      addressPredictions.clear();
      _initializeUserData();

      TSnackbarsWidget.success(
        title: TTexts.successTitle.tr,
        message: TTexts.profileUpdateSuccess.tr,
      );
    } on DioError catch (e) {
      FullScreenLoaderUtils.stopLoading();

      debugPrint("API ERROR: ${e.response?.data}");
      debugPrint("STATUS: ${e.response?.statusCode}");

      String errorMessage = TTexts.profileUpdateError.tr;

      if (e.response?.data is Map && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: errorMessage,
      );
    } on TimeoutException catch (_) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTimeoutTitle.tr,
        message: TTexts.errorTimeoutMessage.tr,
      );
    } on SocketException catch (_) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.netErrorTitle.tr,
        message: TTexts.netErrorDescription.tr,
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // CLEANUP
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
