class PackageDraft {
  final String unitId;
  final String unitName;
  final String variant;
  final double importPrice;
  final double salePrice;
  final int threshold;
  final int quantity;
  final List<String> barcodes;

  PackageDraft({
    required this.unitId,
    required this.unitName,
    required this.variant,
    required this.importPrice,
    required this.salePrice,
    required this.threshold,
    required this.quantity,
    required this.barcodes,
  });
}