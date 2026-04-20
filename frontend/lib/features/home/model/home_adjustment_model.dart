class HomeAdjustmentModel {
  final String id;
  final String productName;
  final int oldQuantity;
  final int newQuantity;
  final int difference;
  final DateTime time;
  final String note;
  final bool isManual;

  bool get isPositive => difference > 0;

  HomeAdjustmentModel({
    required this.id,
    required this.productName,
    required this.oldQuantity,
    required this.newQuantity,
    required this.difference,
    required this.time,
    required this.note,
    required this.isManual,
  });
}
