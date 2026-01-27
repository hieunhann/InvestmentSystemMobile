class FakeGoldPrice {
  final String type;
  final double buyPrice;
  final double sellPrice;
  final String location;

  FakeGoldPrice({
    required this.type,
    required this.buyPrice,
    required this.sellPrice,
    required this.location,
  });
}

class FakeMarketData {
  // Vietnam Gold Prices
  static final List<FakeGoldPrice> vietnamPrices = [
    FakeGoldPrice(type: 'SJC Gold Bars', buyPrice: 68000000, sellPrice: 69000000, location: 'VN'),
    FakeGoldPrice(type: 'PNJ Rings', buyPrice: 68000000, sellPrice: 69000000, location: 'VN'),
    FakeGoldPrice(type: 'SJC 9999', buyPrice: 67500000, sellPrice: 68500000, location: 'VN'),
    FakeGoldPrice(type: 'DOJI Gold', buyPrice: 67800000, sellPrice: 68800000, location: 'VN'),
    FakeGoldPrice(type: 'PNJ 24K', buyPrice: 67600000, sellPrice: 68600000, location: 'VN'),
    FakeGoldPrice(type: 'Bảo Tín Minh Châu', buyPrice: 67700000, sellPrice: 68700000, location: 'VN'),
  ];

  // Domestic SJC Price (main display)
  static final domesticSellPrice = 68500000.0; // VND sell price
  static final domesticBuyPrice = 69500000.0; // VND buy price
  static final domesticPriceChange = -0.5; // %

  // International Gold Price
  static final worldGoldPrice = 2350.00; // USD per ounce
  static final worldGoldPriceInVND = 69000000.0; // VND approximate (converted)
  static final worldPriceChange = 0.3; // %

  // International Silver Price
  static final worldSilverPrice = 30.50; // USD per ounce
  static final worldSilverPriceInVND = 8950000.0; // VND approximate (converted)

  // Exchange Rate
  static final usdToVnd = 25530.0; // VND

  // Spread Gap
  static final spreadGap = 1000000.0; // VND (difference between domestic and world)
  static final spreadRisk = 'Unknown';

  // Price History (for chart) - 6 days
  static final List<Map<String, dynamic>> priceHistory = [
    {'day': 'Mon', 'domestic': 2370.0, 'world': 2310.0},
    {'day': 'Tue', 'domestic': 2355.0, 'world': 2320.0},
    {'day': 'Wed', 'domestic': 2340.0, 'world': 2325.0},
    {'day': 'Thu', 'domestic': 2325.0, 'world': 2330.0},
    {'day': 'Fri', 'domestic': 2310.0, 'world': 2335.0},
    {'day': 'Sat', 'domestic': 2355.0, 'world': 2350.0},
  ];

  // Convert history to values for chart
  static List<double> getDomesticHistory() {
    return priceHistory.map((e) => e['domestic'] as double).toList();
  }

  static List<double> getWorldHistory() {
    return priceHistory.map((e) => e['world'] as double).toList();
  }

  // Get SJC price
  static FakeGoldPrice? getSjcPrice() {
    try {
      return vietnamPrices.firstWhere((p) => p.type.toUpperCase().contains('SJC'));
    } catch (_) {
      return vietnamPrices.isNotEmpty ? vietnamPrices.first : null;
    }
  }
}
