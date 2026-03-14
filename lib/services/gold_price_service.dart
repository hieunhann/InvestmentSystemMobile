import 'package:my_flutter_app/models/gold_price_vietnam.dart';
import 'package:my_flutter_app/models/gold_price_international.dart';
import 'package:my_flutter_app/models/exchange_rate.dart';
import 'package:my_flutter_app/services/api_service.dart';

class GoldPriceService {
  // ❌ DISABLED: PNJ API không hoạt động
  // static const String _pnjApiUrl =
  //     'https://api.pnj.io/pnjcomvn/v1/gold-price';
  
  // ⚠️ NOT USED: MetalPriceAPI - Requires paid API key ($19/month)
  // static const String _metalPriceApiUrl = 
  //     'https://api.metalpriceapi.com/v1/latest';
  // static const String _metalPriceApiKey = 'YOUR_API_KEY';
  
  // Tỷ giá USD/VND (sẽ được cập nhật từ Vietcombank API)
  static double _usdToVnd = 24000.0;
  static GoldPriceInternational? _lastInternational;
  static ExchangeRateResponse? _lastExchangeRates;

  /// Lấy giá vàng Việt Nam từ Backend API
  Future<BTMCApiResponse?> getVietnamGoldPrice() async {
    try {
      print('🔄 Đang gọi API giá vàng Việt Nam (Backend API)...');
      
      final apiService = ApiService();
      // Yêu cầu Token hợp lệ (authorized: true)
      final response = await apiService.get('/prices/vn-all/gold/1d', authorized: true);
      
      if (response is List && response.isNotEmpty) {
        // API trả về list theo thứ tự thời gian tăng dần, lấy phần tử cuối cùng (mới nhất)
        final latestData = response.last;
        final buyPrice = latestData['buyPrice']?.toString() ?? '0';
        final sellPrice = latestData['sellPrice']?.toString() ?? '0';
        final timestampStr = latestData['timestamp']?.toString() ?? '';

        final prices = <GoldPriceVietnam>[];

        final baseBuy = _normalizeDomesticGoldVnd(
          double.tryParse(buyPrice) ?? 0,
        );
        final baseSell = _normalizeDomesticGoldVnd(
          double.tryParse(sellPrice) ?? 0,
        );

        // Keep parity with Market Insights FE: backend latest row -> single VN Gold product.
        prices.add(GoldPriceVietnam(
          type: 'VN Gold',
          buy: baseBuy.toString(),
          sell: baseSell.toString(),
          updateTime: timestampStr,
        ));

        print('✅ Get Vietnam Gold Success: Mua=\$buyPrice, Bán=\$sellPrice');

        return BTMCApiResponse(
          prices: prices,
          city: 'Việt Nam',
          date: DateTime.now().toString().split(' ')[0],
          time: DateTime.now().toString().split(' ')[1].substring(0, 8),
        );
      }
      
      print('❌ Backend API không có dữ liệu giá vàng Việt Nam');
      return null;
      
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }

  /// Lấy giá bạc Việt Nam từ Backend API
  Future<BTMCApiResponse?> getVietnamSilverPrice() async {
    try {
      print('🔄 Đang gọi API giá bạc Việt Nam (Backend API)...');
      
      final apiService = ApiService();
      final response = await apiService.get('/prices/vn-all/silver/1w', authorized: true);
      
      if (response is List && response.isNotEmpty) {
        // Pick the absolute latest regardless of range if we want "current" price
        final latestData = response.last;
        final buyPrice = latestData['buyPrice']?.toString() ?? '0';
        final sellPrice = latestData['sellPrice']?.toString() ?? '0';
        final timestampStr = latestData['timestamp']?.toString() ?? '';

        final prices = <GoldPriceVietnam>[];
        final baseBuy = double.tryParse(buyPrice) ?? 0;
        final baseSell = double.tryParse(sellPrice) ?? 0;

        prices.add(GoldPriceVietnam(
          type: 'Bạc Nguyên Chất 99.99%',
          buy: baseBuy.toString(),
          sell: baseSell.toString(),
          updateTime: timestampStr,
        ));
        prices.add(GoldPriceVietnam(
          type: 'Bạc Trang Sức 925',
          buy: (baseBuy - 150000).toString(),
          sell: (baseSell - 200000).toString(),
          updateTime: timestampStr,
        ));
        prices.add(GoldPriceVietnam(
          type: 'Bạc Ý Cao Cấp',
          buy: (baseBuy + 50000).toString(),
          sell: (baseSell + 50000).toString(),
          updateTime: timestampStr,
        ));

        print('✅ Get Vietnam Silver Success: Mua=\$buyPrice, Bán=\$sellPrice (Có 3 Sản phẩm)');

        return BTMCApiResponse(
          prices: prices,
          city: 'Việt Nam',
          date: DateTime.now().toString().split(' ')[0],
          time: DateTime.now().toString().split(' ')[1].substring(0, 8),
        );
      }
      
      print('❌ Backend API không có dữ liệu giá bạc Việt Nam');
      return null;
      
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }

  /// Lấy giá vàng/bạc quốc tế từ Backend API
  Future<GoldPriceInternational?> getInternationalGoldPrice() async {
    try {
      print('🔄 Đang gọi Global Gold/Silver API (Backend API)...');
      
      final apiService = ApiService();
      
      double? liveGold;
      double? liveSilver;
      
      // Lấy Gold
      try {
        final goldRes = await apiService.get('/prices/global/gold/1d', authorized: true);
        if (goldRes is List && goldRes.isNotEmpty) {
          liveGold = _toDouble(goldRes.last['buyPrice']);
        }
      } catch (e) {
        print('⚠️ Lỗi lấy Global Gold: $e');
      }

      // Lấy Silver
      try {
        final silverRes = await apiService.get('/prices/global/silver/1d', authorized: true);
        if (silverRes is List && silverRes.isNotEmpty) {
          liveSilver = _toDouble(silverRes.last['buyPrice']);
        }
      } catch (e) {
        print('⚠️ Error fetching Global Silver: $e');
      }

      final goldPrice = liveGold ?? _lastInternational?.goldPrice;
      final silverPrice = liveSilver ?? _lastInternational?.silverPrice;

      if ((goldPrice ?? 0) <= 0 && (silverPrice ?? 0) <= 0) {
        print('⚠️ Could not fetch gold/silver data from API, using old cache if available');
        return _lastInternational;
      }

      final result = GoldPriceInternational(
        goldPrice: goldPrice ?? 0,
        silverPrice: silverPrice ?? 0,
        timestamp: DateTime.now().toIso8601String(),
        currency: 'USD',
      );

      print('💰 Gold: \${result.goldPrice}, Silver: \${result.silverPrice}');
      _lastInternational = result;
      return result;
    } catch (e) {
      print('❌ Exception Global API: $e');
      return _lastInternational;
    }
  }

  /// Lấy tất cả tỷ giá ngoại tệ từ Backend API
  Future<ExchangeRateResponse?> getExchangeRates() async {
    try {
      print('🔄 Fetching USD exchange rates from Backend API...');
      
      final apiService = ApiService();
      final response = await apiService.get('/prices/usd/1w', authorized: true);

      if (response is List && response.isNotEmpty) {
        final latestData = response.last;
        final buyValue = _toDouble(latestData['buyPrice'] ?? latestData['buy']);
        final sellValue = _toDouble(latestData['sellPrice'] ?? latestData['sell']);
        final transferValue = _toDouble(latestData['transferPrice'] ?? latestData['transfer']);
        
        if (sellValue > 0) {
          _usdToVnd = sellValue;
        }

        final rate = ExchangeRate(
          currencyCode: 'USD',
          currencyName: 'US Dollar',
          buy: buyValue.toStringAsFixed(2),
          transfer: transferValue.toStringAsFixed(2),
          sell: sellValue.toStringAsFixed(2),
        );

        final result = ExchangeRateResponse(
          rates: [rate],
          dateTime: DateTime.now().toIso8601String(),
          source: 'Backend API',
        );
        _lastExchangeRates = result;
        return result;
      }
    } catch (e) {
      print('⚠️ Backend API Exchange failed: $e');
    }

    return _lastExchangeRates;
  }

  /// Lấy lịch sử biến động giá từ Backend API (phục vụ cho biểu đồ)
  Future<List<dynamic>> getPriceHistory(String region, String asset, String range) async {
    try {
      print('🔄 Fetching price history for $region/$asset/$range...');
      final apiService = ApiService();
      final response = await apiService.get('/prices/$region/$asset/$range', authorized: true);
      if (response is List) {
        return response;
      }
    } catch (e) {
      print('⚠️ Lỗi lấy lịch sử $region/$asset/$range: $e');
    }
    return [];
  }

  /// Lấy lịch sử tỷ giá (biểu đồ ngoại tệ)
  Future<List<dynamic>> getCurrencyHistory(String currency, String range) async {
    try {
      print('🔄 Đang lấy lịch sử tỷ giá $currency/$range...');
      final apiService = ApiService();
      final response = await apiService.get('/prices/$currency/$range', authorized: true);
      if (response is List) {
        return response;
      }
    } catch (e) {
      print('⚠️ Lỗi lấy lịch sử tỷ giá $currency: $e');
    }
    return [];
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Backend goc co the tra sai don vi cho Gold (x10), frontend chuan hoa ve muc VND/luong.
  double _normalizeDomesticGoldVnd(double value) {
    if (value <= 0) return value;

    var normalized = value;
    while (normalized > 500000000) {
      normalized /= 10;
    }
    while (normalized < 1000000) {
      normalized *= 1000000;
    }
    return normalized;
  }

  /// Lấy tỷ giá USD/VND
  Future<double> getUsdToVndRate() async {
    await getExchangeRates();
    return _usdToVnd;
  }

  /// Lấy cả 2 giá đồng thời
  Future<Map<String, dynamic>> getAllPrices() async {
    // Cập nhật tỷ giá trước
    await getUsdToVndRate();
    
    final results = await Future.wait([
      getVietnamGoldPrice(),
      getInternationalGoldPrice(),
    ]);

    return {
      'vietnam': results[0],
      'international': results[1],
      'usdToVnd': _usdToVnd,
    };
  }

  /// Lấy tất cả: giá vàng VN, giá vàng quốc tế, và tỷ giá ngoại tệ
  Future<Map<String, dynamic>> getAllData() async {
    final results = await Future.wait([
      getVietnamGoldPrice(),
      getInternationalGoldPrice(),
      getExchangeRates(),
    ]);

    return {
      'vietnam': results[0],
      'international': results[1],
      'exchangeRates': results[2],
      'usdToVnd': _usdToVnd,
    };
  }
}
