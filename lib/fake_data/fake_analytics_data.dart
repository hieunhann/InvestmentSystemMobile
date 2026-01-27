// 📊 FAKE ANALYTICS DATA
// Dữ liệu thống kê giả lập cho AnalyticsScreen

class FakeAnalyticsData {
  // Tổng quan portfolio
  static const double totalValue = 487250000; // 487.25 triệu VND
  static const double totalCost = 450000000; // 450 triệu VND
  static const double totalProfit = 37250000; // 37.25 triệu VND
  static const double profitPercent = 8.28; // 8.28%

  // Phân bổ tài sản
  static final List<AssetAllocation> assetAllocation = [
    AssetAllocation(type: 'Vàng SJC', value: 300000000, percent: 61.6, color: 0xFFFFD700),
    AssetAllocation(type: 'Vàng 9999', value: 100000000, percent: 20.5, color: 0xFFFFA500),
    AssetAllocation(type: 'Ngoại tệ (USD)', value: 50000000, percent: 10.3, color: 0xFF4CAF50),
    AssetAllocation(type: 'Bạc', value: 30000000, percent: 6.2, color: 0xFF9E9E9E),
    AssetAllocation(type: 'Tiền mặt', value: 7250000, percent: 1.5, color: 0xFF2196F3),
  ];

  // Lịch sử giá trị portfolio (30 ngày gần nhất)
  static final List<PortfolioHistory> portfolioHistory = [
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 29)), value: 450000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 27)), value: 452000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 25)), value: 455000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 23)), value: 458000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 21)), value: 462000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 19)), value: 460000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 17)), value: 465000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 15)), value: 468000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 13)), value: 470000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 11)), value: 472000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 9)), value: 475000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 7)), value: 478000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 5)), value: 480000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 3)), value: 483000000),
    PortfolioHistory(date: DateTime.now().subtract(const Duration(days: 1)), value: 485000000),
    PortfolioHistory(date: DateTime.now(), value: 487250000),
  ];

  // Thống kê giao dịch
  static const int totalTransactions = 24;
  static const int buyTransactions = 16;
  static const int sellTransactions = 8;
  static const double totalBuyValue = 550000000; // 550 triệu VND
  static const double totalSellValue = 100000000; // 100 triệu VND

  // Top assets theo lợi nhuận
  static final List<TopAsset> topAssets = [
    TopAsset(name: 'Vàng SJC 10 chỉ', buyPrice: 75000000, currentPrice: 78500000, profit: 3500000, profitPercent: 4.67),
    TopAsset(name: 'USD 2000', buyPrice: 48000000, currentPrice: 50000000, profit: 2000000, profitPercent: 4.17),
    TopAsset(name: 'Vàng 9999 5 chỉ', buyPrice: 37000000, currentPrice: 38500000, profit: 1500000, profitPercent: 4.05),
    TopAsset(name: 'Bạc 10kg', buyPrice: 25000000, currentPrice: 26000000, profit: 1000000, profitPercent: 4.0),
  ];

  // Hiệu suất theo tháng (6 tháng gần nhất)
  static final List<MonthlyPerformance> monthlyPerformance = [
    MonthlyPerformance(month: 'Tháng 8', profit: 5200000, profitPercent: 1.2),
    MonthlyPerformance(month: 'Tháng 9', profit: 6800000, profitPercent: 1.5),
    MonthlyPerformance(month: 'Tháng 10', profit: 8500000, profitPercent: 1.9),
    MonthlyPerformance(month: 'Tháng 11', profit: 7300000, profitPercent: 1.6),
    MonthlyPerformance(month: 'Tháng 12', profit: 6200000, profitPercent: 1.3),
    MonthlyPerformance(month: 'Tháng 1', profit: 3250000, profitPercent: 0.7),
  ];
}

class AssetAllocation {
  final String type;
  final double value;
  final double percent;
  final int color;

  AssetAllocation({
    required this.type,
    required this.value,
    required this.percent,
    required this.color,
  });
}

class PortfolioHistory {
  final DateTime date;
  final double value;

  PortfolioHistory({required this.date, required this.value});
}

class TopAsset {
  final String name;
  final double buyPrice;
  final double currentPrice;
  final double profit;
  final double profitPercent;

  TopAsset({
    required this.name,
    required this.buyPrice,
    required this.currentPrice,
    required this.profit,
    required this.profitPercent,
  });
}

class MonthlyPerformance {
  final String month;
  final double profit;
  final double profitPercent;

  MonthlyPerformance({
    required this.month,
    required this.profit,
    required this.profitPercent,
  });
}
