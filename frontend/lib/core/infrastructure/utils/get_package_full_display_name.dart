import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:get/utils.dart';

class DisplayNameUtils {
  static String getFullPackageDisplayName(ProductPackageModel? package) {
    if (package == null) {
      return TTexts.unknownProduct.tr;
    }

    final displayName = package.displayName.trim();
    final variant = package.variant?.trim();

    if (variant == null || variant.isEmpty) {
      return displayName;
    }

    return '$displayName - $variant';
  }

  static String getFullPackageDisplayNameFromJson(
    Map<String, dynamic>? package,
  ) {
    if (package == null) {
      return TTexts.unknownProduct.tr;
    }

    final displayName = package['displayName']?.toString();

    if (displayName == null || displayName.isEmpty) {
      return TTexts.unknownProduct.tr;
    }

    final variant = package['variant']?.toString().trim();

    if (variant == null || variant.isEmpty) {
      return displayName;
    }

    return '$displayName $variant';
  }
}
