enum InventoryActionType { stockIn, stockOut, adjust }

class InventoryHistoryModel {
  final String date;
  final InventoryActionType type;
  final int qty;
  final String note;

  InventoryHistoryModel({
    required this.date,
    required this.type,
    required this.qty,
    required this.note,
  });
}
