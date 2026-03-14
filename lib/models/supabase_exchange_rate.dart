/// Model cho tỷ giá ngoại hối từ Supabase
class SupabaseExchangeRate {
  final int id;
  final String currencyCode;
  final String baseCurrencyCode;
  final double? buyPrice;
  final double? transferPrice;
  final double? sellPrice;
  final int sourceId;
  final DateTime timestamp;
  final DateTime createdAt;

  SupabaseExchangeRate({
    required this.id,
    required this.currencyCode,
    required this.baseCurrencyCode,
    this.buyPrice,
    this.transferPrice,
    this.sellPrice,
    required this.sourceId,
    required this.timestamp,
    required this.createdAt,
  });

  factory SupabaseExchangeRate.fromJson(Map<String, dynamic> json) {
    return SupabaseExchangeRate(
      id: json['id'] as int,
      currencyCode: json['currency_code'] as String,
      baseCurrencyCode: json['base_currency_code'] as String,
      buyPrice: json['buy_price'] != null 
          ? (json['buy_price'] as num).toDouble() 
          : null,
      transferPrice: json['transfer_price'] != null
          ? (json['transfer_price'] as num).toDouble()
          : null,
      sellPrice: json['sell_price'] != null
          ? (json['sell_price'] as num).toDouble()
          : null,
      sourceId: json['source_id'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency_code': currencyCode,
      'base_currency_code': baseCurrencyCode,
      'buy_price': buyPrice,
      'transfer_price': transferPrice,
      'sell_price': sellPrice,
      'source_id': sourceId,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Currency names mapping
  static const Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'HKD': 'Hong Kong Dollar',
    'SGD': 'Singapore Dollar',
    'THB': 'Thai Baht',
    'KRW': 'South Korean Won',
  };

  String get currencyName => currencyNames[currencyCode] ?? currencyCode;
  
  String get buyPriceFormatted => buyPrice?.toStringAsFixed(2) ?? '-';
  String get transferPriceFormatted => transferPrice?.toStringAsFixed(2) ?? '-';
  String get sellPriceFormatted => sellPrice?.toStringAsFixed(2) ?? '-';
}
