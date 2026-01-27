/// Model cho tỷ giá ngoại tệ từ Vietcombank
class ExchangeRate {
  final String currencyCode;
  final String currencyName;
  final String buy;
  final String transfer;
  final String sell;

  ExchangeRate({
    required this.currencyCode,
    required this.currencyName,
    required this.buy,
    required this.transfer,
    required this.sell,
  });

  factory ExchangeRate.fromXml(dynamic xmlElement) {
    return ExchangeRate(
      currencyCode: xmlElement.getAttribute('CurrencyCode') ?? '',
      currencyName: xmlElement.getAttribute('CurrencyName') ?? '',
      buy: xmlElement.getAttribute('Buy') ?? '-',
      transfer: xmlElement.getAttribute('Transfer') ?? '-',
      sell: xmlElement.getAttribute('Sell') ?? '-',
    );
  }

  // Chuyển đổi giá trị có dấu phấy sang số
  double get buyValue => _parseValue(buy);
  double get transferValue => _parseValue(transfer);
  double get sellValue => _parseValue(sell);

  double _parseValue(String value) {
    if (value == '-' || value.isEmpty) return 0;
    return double.tryParse(value.replaceAll(',', '')) ?? 0;
  }
}

class ExchangeRateResponse {
  final List<ExchangeRate> rates;
  final String dateTime;
  final String source;

  ExchangeRateResponse({
    required this.rates,
    required this.dateTime,
    this.source = 'Vietcombank',
  });
}
