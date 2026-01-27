// 📝 FAKE TRANSACTION DATA
// Dữ liệu giao dịch giả lập cho RecordTransactionScreen

class FakeTransaction {
  final String id;
  final String type; // 'buy', 'sell'
  final String assetType; // 'gold', 'silver', 'currency'
  final String assetName;
  final double quantity;
  final String unit;
  final double price; // Giá đơn vị
  final double totalValue; // Tổng giá trị
  final DateTime transactionDate;
  final String? note;
  final String? receiptNumber; // Số hóa đơn
  final String? seller; // Người bán/nơi mua

  FakeTransaction({
    required this.id,
    required this.type,
    required this.assetType,
    required this.assetName,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.totalValue,
    required this.transactionDate,
    this.note,
    this.receiptNumber,
    this.seller,
  });

  bool get isBuy => type == 'buy';
  bool get isSell => type == 'sell';
}

class FakeTransactionData {
  static final List<FakeTransaction> transactions = [
    // Giao dịch mới nhất
    FakeTransaction(
      id: 'TXN001',
      type: 'buy',
      assetType: 'gold',
      assetName: 'Vàng miếng SJC 10 chỉ',
      quantity: 1,
      unit: 'chỉ',
      price: 78500000,
      totalValue: 78500000,
      transactionDate: DateTime.now().subtract(const Duration(days: 2)),
      note: 'Mua đợt Tết 2026',
      receiptNumber: 'SJC20260123001',
      seller: 'SJC Hà Nội',
    ),
    FakeTransaction(
      id: 'TXN002',
      type: 'buy',
      assetType: 'currency',
      assetName: 'USD',
      quantity: 500,
      unit: 'USD',
      price: 25000,
      totalValue: 12500000,
      transactionDate: DateTime.now().subtract(const Duration(days: 5)),
      note: 'Tiết kiệm USD',
      seller: 'Vietcombank',
    ),
    FakeTransaction(
      id: 'TXN003',
      type: 'sell',
      assetType: 'gold',
      assetName: 'Nhẫn tròn trơn 999',
      quantity: 1,
      unit: 'chỉ',
      price: 6800000,
      totalValue: 6800000,
      transactionDate: DateTime.now().subtract(const Duration(days: 7)),
      note: 'Bán lại nhẫn cũ',
      receiptNumber: 'PNJ20260118002',
      seller: 'PNJ Cầu Giấy',
    ),
    FakeTransaction(
      id: 'TXN004',
      type: 'buy',
      assetType: 'silver',
      assetName: 'Bạc thỏi 1kg',
      quantity: 5,
      unit: 'kg',
      price: 2600000,
      totalValue: 13000000,
      transactionDate: DateTime.now().subtract(const Duration(days: 10)),
      seller: 'Bạc Việt',
    ),
    FakeTransaction(
      id: 'TXN005',
      type: 'buy',
      assetType: 'gold',
      assetName: 'Vàng 9999 PNJ 5 chỉ',
      quantity: 2,
      unit: 'chỉ',
      price: 38500000,
      totalValue: 77000000,
      transactionDate: DateTime.now().subtract(const Duration(days: 15)),
      note: 'Ưu đãi Tết, giảm 2%',
      receiptNumber: 'PNJ20260110001',
      seller: 'PNJ Hoàn Kiếm',
    ),
    FakeTransaction(
      id: 'TXN006',
      type: 'buy',
      assetType: 'gold',
      assetName: 'Vàng miếng SJC 5 chỉ',
      quantity: 2,
      unit: 'chỉ',
      price: 39250000,
      totalValue: 78500000,
      transactionDate: DateTime(2025, 11, 20),
      note: 'Quà cưới',
      seller: 'SJC TP.HCM',
    ),
    FakeTransaction(
      id: 'TXN007',
      type: 'buy',
      assetType: 'gold',
      assetName: 'Vàng 9999 Doji 10 chỉ',
      quantity: 1,
      unit: 'chỉ',
      price: 77000000,
      totalValue: 77000000,
      transactionDate: DateTime(2025, 12, 5),
      receiptNumber: 'DOJI20251205001',
      seller: 'Doji Tower',
    ),
    FakeTransaction(
      id: 'TXN008',
      type: 'sell',
      assetType: 'currency',
      assetName: 'EUR',
      quantity: 200,
      unit: 'EUR',
      price: 27000,
      totalValue: 5400000,
      transactionDate: DateTime(2025, 11, 25),
      note: 'Bán EUR lấy VND',
      seller: 'Techcombank',
    ),
    FakeTransaction(
      id: 'TXN009',
      type: 'buy',
      assetType: 'currency',
      assetName: 'JPY',
      quantity: 100000,
      unit: 'JPY',
      price: 165,
      totalValue: 16500000,
      transactionDate: DateTime(2025, 12, 1),
      note: 'Mua từ Nhật Bản',
      seller: 'ACB',
    ),
    FakeTransaction(
      id: 'TXN010',
      type: 'buy',
      assetType: 'gold',
      assetName: 'Vàng miếng SJC 10 chỉ',
      quantity: 3,
      unit: 'chỉ',
      price: 75000000,
      totalValue: 225000000,
      transactionDate: DateTime(2025, 10, 15),
      note: 'Mua tích lũy dài hạn',
      receiptNumber: 'SJC20251015001',
      seller: 'SJC Hà Nội',
    ),
    FakeTransaction(
      id: 'TXN011',
      type: 'sell',
      assetType: 'gold',
      assetName: 'Nhẫn tròn trơn 999',
      quantity: 2,
      unit: 'chỉ',
      price: 6500000,
      totalValue: 13000000,
      transactionDate: DateTime(2025, 10, 1),
      note: 'Thanh lý nhẫn cũ',
      seller: 'Bảo Tín Minh Châu',
    ),
    FakeTransaction(
      id: 'TXN012',
      type: 'buy',
      assetType: 'silver',
      assetName: 'Bạc miếng 999',
      quantity: 5,
      unit: 'kg',
      price: 2550000,
      totalValue: 12750000,
      transactionDate: DateTime(2025, 12, 15),
      note: 'Bạc nguyên chất',
      seller: 'Bạc Việt',
    ),
  ];

  static List<FakeTransaction> getTransactionsByType(String type) {
    if (type == 'all') return transactions;
    return transactions.where((t) => t.type == type).toList();
  }

  static List<FakeTransaction> getTransactionsByAssetType(String assetType) {
    return transactions.where((t) => t.assetType == assetType).toList();
  }

  static List<FakeTransaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return transactions
        .where((t) =>
            t.transactionDate.isAfter(start.subtract(const Duration(days: 1))) &&
            t.transactionDate.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  static double getTotalBuyValue() {
    return transactions
        .where((t) => t.isBuy)
        .fold(0.0, (sum, t) => sum + t.totalValue);
  }

  static double getTotalSellValue() {
    return transactions
        .where((t) => t.isSell)
        .fold(0.0, (sum, t) => sum + t.totalValue);
  }

  static int getTotalTransactions() => transactions.length;
  static int getTotalBuyTransactions() => transactions.where((t) => t.isBuy).length;
  static int getTotalSellTransactions() => transactions.where((t) => t.isSell).length;

  static List<String> get transactionTypes => ['all', 'buy', 'sell'];
  static List<String> get assetTypes => ['all', 'gold', 'silver', 'currency'];
  
  static String getTransactionTypeName(String type) {
    switch (type) {
      case 'all':
        return 'Tất cả';
      case 'buy':
        return 'Mua';
      case 'sell':
        return 'Bán';
      default:
        return type;
    }
  }

  static String getAssetTypeName(String type) {
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
