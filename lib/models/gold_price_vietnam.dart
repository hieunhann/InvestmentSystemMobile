/// Model for Vietnam Gold Price from BTMC API
class GoldPriceVietnam {
  final String type;
  final String buy;
  final String sell;
  final String updateTime;

  GoldPriceVietnam({
    required this.type,
    required this.buy,
    required this.sell,
    required this.updateTime,
  });

  factory GoldPriceVietnam.fromJson(Map<String, dynamic> json) {
    return GoldPriceVietnam(
      type: json['@row'] ?? '',
      buy: json['@buy'] ?? '0',
      sell: json['@sell'] ?? '0',
      updateTime: json['@updated'] ?? '',
    );
  }

  // Convert price from String to double
  double get buyPrice => double.tryParse(buy.replaceAll(',', '')) ?? 0.0;
  double get sellPrice => double.tryParse(sell.replaceAll(',', '')) ?? 0.0;
}

/// Response from BTMC API
class BTMCApiResponse {
  final List<GoldPriceVietnam> prices;
  final String city;
  final String date;
  final String time;

  BTMCApiResponse({
    required this.prices,
    required this.city,
    required this.date,
    required this.time,
  });

  factory BTMCApiResponse.fromJson(Map<String, dynamic> json) {
    final dataHolder = json['DataList']?['DataHolder'];
    
    if (dataHolder == null) {
      return BTMCApiResponse(
        prices: [],
        city: '',
        date: '',
        time: '',
      );
    }
    
    final items = dataHolder is List ? dataHolder : [dataHolder];
    
    return BTMCApiResponse(
      prices: items
          .where((item) => item != null)
          .map<GoldPriceVietnam>((item) => GoldPriceVietnam.fromJson(item))
          .toList(),
      city: json['DataList']?['@city'] ?? '',
      date: json['DataList']?['@date'] ?? '',
      time: json['DataList']?['@time'] ?? '',
    );
  }
}
