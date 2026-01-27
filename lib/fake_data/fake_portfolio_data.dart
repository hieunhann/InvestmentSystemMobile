// 💼 FAKE PORTFOLIO DATA
// Dữ liệu danh mục đầu tư giả lập cho PortfolioScreen

class FakePortfolioItem {
  final String id;
  final String name;
  final String type; // 'gold', 'silver', 'currency'
  final double quantity;
  final String unit; // 'chỉ', 'kg', 'USD'
  final double buyPrice;
  final double currentPrice;
  final DateTime buyDate;
  final String? note;

  FakePortfolioItem({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.buyPrice,
    required this.currentPrice,
    required this.buyDate,
    this.note,
  });

  double get totalBuyValue => quantity * buyPrice;
  double get totalCurrentValue => quantity * currentPrice;
  double get profit => totalCurrentValue - totalBuyValue;
  double get profitPercent => (profit / totalBuyValue) * 100;
}

class FakePortfolioData {
  static final List<FakePortfolioItem> portfolioItems = [
    // Vàng SJC
    FakePortfolioItem(
      id: '1',
      name: 'Vàng miếng SJC 10 chỉ',
      type: 'gold',
      quantity: 4,
      unit: 'chỉ',
      buyPrice: 75000000,
      currentPrice: 78500000,
      buyDate: DateTime(2025, 10, 15),
      note: 'Mua từ SJC Hà Nội',
    ),
    FakePortfolioItem(
      id: '2',
      name: 'Vàng miếng SJC 5 chỉ',
      type: 'gold',
      quantity: 2,
      unit: 'chỉ',
      buyPrice: 37500000,
      currentPrice: 39250000,
      buyDate: DateTime(2025, 11, 20),
      note: 'Quà tặng ngày cưới',
    ),
    
    // Vàng 9999
    FakePortfolioItem(
      id: '3',
      name: 'Vàng 9999 Doji 10 chỉ',
      type: 'gold',
      quantity: 1,
      unit: 'chỉ',
      buyPrice: 74000000,
      currentPrice: 77000000,
      buyDate: DateTime(2025, 12, 5),
    ),
    FakePortfolioItem(
      id: '4',
      name: 'Vàng 9999 PNJ 5 chỉ',
      type: 'gold',
      quantity: 2,
      unit: 'chỉ',
      buyPrice: 37000000,
      currentPrice: 38500000,
      buyDate: DateTime(2026, 1, 10),
      note: 'Ưu đãi Tết',
    ),

    // Nhẫn vàng
    FakePortfolioItem(
      id: '5',
      name: 'Nhẫn tròn trơn 999',
      type: 'gold',
      quantity: 3,
      unit: 'chỉ',
      buyPrice: 6500000,
      currentPrice: 6800000,
      buyDate: DateTime(2025, 9, 1),
      note: 'Nhẫn cưới',
    ),

    // Bạc
    FakePortfolioItem(
      id: '6',
      name: 'Bạc thỏi 1kg',
      type: 'silver',
      quantity: 10,
      unit: 'kg',
      buyPrice: 2500000,
      currentPrice: 2600000,
      buyDate: DateTime(2025, 11, 1),
    ),
    FakePortfolioItem(
      id: '7',
      name: 'Bạc miếng 999',
      type: 'silver',
      quantity: 5,
      unit: 'kg',
      buyPrice: 2400000,
      currentPrice: 2550000,
      buyDate: DateTime(2025, 12, 15),
      note: 'Bạc nguyên chất',
    ),

    // Ngoại tệ
    FakePortfolioItem(
      id: '8',
      name: 'USD',
      type: 'currency',
      quantity: 2000,
      unit: 'USD',
      buyPrice: 24000,
      currentPrice: 25000,
      buyDate: DateTime(2025, 10, 1),
      note: 'Tiết kiệm USD',
    ),
    FakePortfolioItem(
      id: '9',
      name: 'EUR',
      type: 'currency',
      quantity: 500,
      unit: 'EUR',
      buyPrice: 26000,
      currentPrice: 27000,
      buyDate: DateTime(2025, 11, 15),
    ),
    FakePortfolioItem(
      id: '10',
      name: 'JPY',
      type: 'currency',
      quantity: 100000,
      unit: 'JPY',
      buyPrice: 160,
      currentPrice: 165,
      buyDate: DateTime(2025, 12, 1),
      note: 'Mua từ Nhật Bản',
    ),
  ];

  static List<FakePortfolioItem> getItemsByType(String type) {
    if (type == 'all') return portfolioItems;
    return portfolioItems.where((item) => item.type == type).toList();
  }

  static double getTotalValueByType(String type) {
    final items = getItemsByType(type);
    return items.fold(0.0, (sum, item) => sum + item.totalCurrentValue);
  }

  static double getTotalProfitByType(String type) {
    final items = getItemsByType(type);
    return items.fold(0.0, (sum, item) => sum + item.profit);
  }

  static Map<String, double> getSummary() {
    return {
      'totalValue': portfolioItems.fold(0.0, (sum, item) => sum + item.totalCurrentValue),
      'totalCost': portfolioItems.fold(0.0, (sum, item) => sum + item.totalBuyValue),
      'totalProfit': portfolioItems.fold(0.0, (sum, item) => sum + item.profit),
    };
  }

  static List<String> get types => ['all', 'gold', 'silver', 'currency'];
  
  static String getTypeName(String type) {
    switch (type) {
      case 'all':
        return 'Tất cả';
      case 'gold':
        return 'Vàng';
      case 'silver':
        return 'Bạc';
      case 'currency':
        return 'Ngoại tệ';
      default:
        return type;
    }
  }
}
