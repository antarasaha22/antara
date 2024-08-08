class Stock {
  final int id;
  final String stockName;
  final String symbol;

  Stock({required this.id, required this.stockName, required this.symbol});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      stockName: json['stock_name'],
      symbol: json['symbol'],
    );
  }
}
