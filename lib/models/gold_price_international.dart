/// Model cho giá vàng quốc tế từ Metal Price API
class GoldPriceInternational {
  final double goldPrice;    // Giá vàng (USD/oz)
  final double silverPrice;  // Giá bạc (USD/oz)
  final String timestamp;
  final String currency;

  GoldPriceInternational({
    required this.goldPrice,
    required this.silverPrice,
    required this.timestamp,
    this.currency = 'USD',
  });

  factory GoldPriceInternational.fromJson(Map<String, dynamic> json) {
    final rates = json['rates'] ?? {};
    
    return GoldPriceInternational(
      goldPrice: (rates['XAU'] ?? 0.0).toDouble(),
      silverPrice: (rates['XAG'] ?? 0.0).toDouble(),
      timestamp: json['timestamp']?.toString() ?? '',
      currency: json['base'] ?? 'USD',
    );
  }

  // Chuyển đổi sang VND
  double goldPricePerOzInVND(double usdToVndRate) {
    return goldPrice * usdToVndRate;
  }

  double goldPricePerTaelInVND(double usdToVndRate) {
    // 1 oz = 1.20565 lượng (tael)
    return goldPrice * usdToVndRate * 1.20565;
  }

  double silverPricePerOzInVND(double usdToVndRate) {
    return silverPrice * usdToVndRate;
  }

  double silverPricePerTaelInVND(double usdToVndRate) {
    return silverPrice * usdToVndRate * 1.20565;
  }

  // Legacy/Helper methods (per Chỉ - 3.75g)
  double goldPriceInVND(double usdToVndRate) {
    if (goldPrice == 0) return 0;
    const ozToGram = 31.1035;
    const chiToGram = 3.75;
    return (goldPrice * usdToVndRate * chiToGram) / ozToGram;
  }

  double silverPriceInVND(double usdToVndRate) {
    if (silverPrice == 0) return 0;
    const ozToGram = 31.1035;
    const chiToGram = 3.75;
    return (silverPrice * usdToVndRate * chiToGram) / ozToGram;
  }
}
