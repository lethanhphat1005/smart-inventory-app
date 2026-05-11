import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';

class InventoryProductFormImageWidget extends GetView<ProductFormController> {
  const InventoryProductFormImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Obx(() {
            final image = controller.selectedImage.value;
            final existingUrl = controller.existingImageUrl.value;
            final isLoading = controller.isPickingImage.value;

            // XÁC ĐỊNH NGUỒN ẢNH ĐỂ HIỂN THỊ
            ImageProvider? imageProvider;
            if (image != null) {
              imageProvider =
                  FileImage(File(image.path)); // Ưu tiên ảnh mới chụp
            } else if (existingUrl.isNotEmpty) {
              imageProvider = CachedNetworkImageProvider(
                  existingUrl); // Không có ảnh mới thì load ảnh cũ
            }

            final bool hasImage = imageProvider != null;

            return Stack(
              children: [
                // KHUNG ẢNH CHÍNH
                GestureDetector(
                  onTap: isLoading ? null : () => _showImageOptions(context),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.softGrey.withOpacity(0.3),
                          width: 1.5),
                      // HIỂN THỊ ẢNH NẾU CÓ
                      image: hasImage
                          ? DecorationImage(
                              image: imageProvider, fit: BoxFit.cover)
                          : null,
                    ),
                    // NẾU TRỐNG THÌ HIỆN CHỮ UPLOAD
                    child: !hasImage
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isLoading)
                                const CircularProgressIndicator(
                                    color: AppColors.primary)
                              else ...[
                                const Icon(Iconsax.camera_copy,
                                    size: 56, color: AppColors.primary),
                                const SizedBox(height: 12),
                                Text(TTexts.uploadImage.tr,
                                    style: TextStyle(
                                        fontFamily: AppFonts.mainFont,
                                        fontSize: 14,
                                        color: AppColors.primaryText,
                                        fontWeight: FontWeight.w600)),
                              ]
                            ],
                          )
                        : null,
                  ),
                ),

                // NÚT THÙNG RÁC
                if (hasImage && !isLoading)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => controller.removeSelectedImage(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: const Icon(Iconsax.trash_copy,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _showImageOptions(BuildContext context) {
    TBottomSheetWidget.show(
      title: TTexts.productImage.tr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Iconsax.camera_copy, color: AppColors.primary),
            title: Text(TTexts.takePhoto.tr,
                style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontWeight: FontWeight.w600)),
            onTap: () {
              Get.back();
              controller.pickImage(ImageSource.camera);
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Iconsax.gallery_copy, color: AppColors.primary),
            title: Text(TTexts.chooseFromGallery.tr,
                style: TextStyle(
                    fontFamily: AppFonts.mainFont,
                    fontWeight: FontWeight.w600)),
            onTap: () {
              Get.back();
              controller.pickImage(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
