import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TBarcodeCandidateBottomSheet extends StatefulWidget {
  final String barcode;
  final List<Map<String, dynamic>> candidates;
  final Map<String, dynamic> prefill;

  const TBarcodeCandidateBottomSheet({
    super.key,
    required this.barcode,
    required this.candidates,
    required this.prefill,
  });

  static Future<Map<String, dynamic>?> show({
    required String barcode,
    required List<dynamic> candidates,
    required Map<String, dynamic> prefill,
  }) {
    return Get.bottomSheet<Map<String, dynamic>>(
      TBarcodeCandidateBottomSheet(
        barcode: barcode,
        candidates: candidates.cast<Map<String, dynamic>>(),
        prefill: prefill,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<TBarcodeCandidateBottomSheet> createState() =>
      _TBarcodeCandidateBottomSheetState();
}

class _TBarcodeCandidateBottomSheetState
    extends State<TBarcodeCandidateBottomSheet> {
  int _selectedCandidateIndex = -1;

  @override
  Widget build(BuildContext context) {
    return TBottomSheetWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Icon Header
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Iconsax.scan_barcode_copy,
                  color: AppColors.primary, size: 32),
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // 2. Title
          Text(
            TTexts.barcodeCandidateTitle.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: AppSizes.p8),

          // 3. Subtitle (Barcode: [code] matches multiple products. Please select one:)
          Text(
            '${TTexts.barcodeCandidateSubtitle.tr} [${widget.barcode}] ${TTexts.barcodeMatchesMultipleProducts.tr}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subText,
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: AppSizes.p24),

          // 4. List of candidate products presented in elegantly designed, elevated cards
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.candidates.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.p12),
              itemBuilder: (context, index) {
                final candidate = widget.candidates[index];
                final isSelected = index == _selectedCandidateIndex;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16, vertical: AppSizes.p12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.05)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius12),
                    border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.divider,
                        width: isSelected ? 1.5 : 1),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(isSelected ? 0.05 : 0.02),
                        blurRadius: isSelected ? 8 : 5,
                        offset: Offset(0, isSelected ? 3 : 2),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: ThemeData(
                      radioTheme: RadioThemeData(
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primary;
                          }
                          return AppColors.softGrey;
                        }),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: AppColors.primary, size: 22),
                      ),
                      title: Text(
                        candidate['productName'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primaryText),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(Iconsax.barcode_copy,
                              color: AppColors.subText, size: 14),
                          const SizedBox(width: 6),
                          Text(candidate['sku'] ?? '',
                              style: const TextStyle(
                                  color: AppColors.subText, fontSize: 12)),
                        ],
                      ),
                      trailing: Radio<int>(
                        value: index,
                        groupValue: _selectedCandidateIndex,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedCandidateIndex = value!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCandidateIndex = index;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.p24),

          // 5. Footer action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.softGrey),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius12)),
                  ),
                  child: Text(
                    TTexts.skipLabel.tr,
                    style: const TextStyle(
                        color: AppColors.softGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.p16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(result: {
                      'status': 'create_from_flow',
                      'prefill': widget.prefill,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.add_square_copy,
                          color: AppColors.whiteText, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        TTexts.createProduct.tr,
                        style: const TextStyle(
                            color: AppColors.whiteText,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
