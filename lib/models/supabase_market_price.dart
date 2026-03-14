/// Model cho giá vàng/bạc từ Supabase
class SupabaseMarketPrice {
  final int id;
  final int assetId;
  final int sourceId;
  final int regionId;
  final int unitId;
  final String currencyCode;
  final double buyPrice;
  final double sellPrice;
  final DateTime timestamp;
  final DateTime createdAt;

  SupabaseMarketPrice({
    required this.id,
    required this.assetId,
    required this.sourceId,
    required this.regionId,
    required this.unitId,
    required this.currencyCode,
    required this.buyPrice,
    required this.sellPrice,
    required this.timestamp,
    required this.createdAt,
  });

  factory SupabaseMarketPrice.fromJson(Map<String, dynamic> json) {
    return SupabaseMarketPrice(
      id: json['id'] as int,
      assetId: json['asset_id'] as int,
      sourceId: json['source_id'] as int,
      regionId: json['region_id'] as int,
      unitId: json['unit_id'] as int,
      currencyCode: json['currency_code'] as String,
      buyPrice: (json['buy_price'] as num).toDouble(),
      sellPrice: (json['sell_price'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_id': assetId,
      'source_id': sourceId,
      'region_id': regionId,
      'unit_id': unitId,
      'currency_code': currencyCode,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Asset ID constants
  static const int ASSET_GOLD = 1;
  static const int ASSET_SILVER = 2;

  /// Source ID constants
  static const int SOURCE_CAFEF = 1;
  static const int SOURCE_KITCO = 2;
  static const int SOURCE_VIETCOMBANK = 3;

  /// Region ID constants
  static const int REGION_HANOI = 1;
  static const int REGION_HOCHIMINH = 2;
  static const int REGION_DANANG = 3;
  static const int REGION_CANTHO = 4;
  static const int REGION_TAYNGUYEN = 5;
  static const int REGION_DONGNAMBO = 6;
  static const int REGION_GLOBAL = 8;

  /// Unit ID constants
  static const int UNIT_LUONG = 1; // 37.5g - Vietnamese unit
  static const int UNIT_OUNCE = 2; // Troy Ounce - ~31.1g

  /// Region names mapping
  static const Map<int, String> regionNames = {
    1: 'Hà Nội',
    2: 'Hồ Chí Minh',
    3: 'Đà Nẵng',
    4: 'Cần Thơ',
    5: 'Tây Nguyên',
    6: 'Đông Nam Bộ',
    8: 'Global',
  };

  /// Source names mapping
  static const Map<int, String> sourceNames = {
    1: 'CafeF',
    2: 'Kitco',
    3: 'Vietcombank',
  };

  /// Unit names mapping
  static const Map<int, String> unitNames = {
    1: 'Lượng (37.5g)',
    2: 'Ounce Troy (~31.1g)',
  };

  String get regionName => regionNames[regionId] ?? 'Unknown';
  String get sourceName => sourceNames[sourceId] ?? 'Unknown';
  String get unitName => unitNames[unitId] ?? 'Unknown';
  bool get isGold => assetId == ASSET_GOLD;
  bool get isSilver => assetId == ASSET_SILVER;
  bool get isVietnam => sourceId == SOURCE_CAFEF;
  bool get isGlobal => regionId == REGION_GLOBAL;

  /// Format giá VND (triệu đồng)
  String get buyPriceFormatted {
    if (currencyCode == 'VND') {
      final millions = buyPrice / 1000000;
      return '${millions.toStringAsFixed(2)} triệu';
    }
    return '\$${buyPrice.toStringAsFixed(2)}';
  }

  String get sellPriceFormatted {
    if (currencyCode == 'VND') {
      final millions = sellPrice / 1000000;
      return '${millions.toStringAsFixed(2)} triệu';
    }
    return '\$${sellPrice.toStringAsFixed(2)}';
  }
}
