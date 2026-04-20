// lib/features/workspace/views/widgets/workspace_map_preview_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/profile/controllers/profile_edit_store_controller.dart';

class EditStoreMapPreviewWidget extends GetView<ProfileEditStoreController> {
  const EditStoreMapPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radius16),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppSizes.radius16),
        ),
        child: Obx(() => FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.selectedLocation.value,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.group21.storix',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: controller.selectedLocation.value,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on,
                          color: Colors.orange, size: 40),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
