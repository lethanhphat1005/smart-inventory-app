class CurrencyModel {
  final String code;
  final String symbol;
  final String name;

  CurrencyModel({required this.code, required this.symbol, required this.name});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
    );
  }
}