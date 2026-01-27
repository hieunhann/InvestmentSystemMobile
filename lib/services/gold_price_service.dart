import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:my_flutter_app/models/gold_price_vietnam.dart';
import 'package:my_flutter_app/models/gold_price_international.dart';
import 'package:my_flutter_app/models/exchange_rate.dart';

class GoldPriceService {
  // API URLs
  static const String _btmcApiUrl = 
      'http://api.btmc.vn/api/BTMCAPI/getpricebtmc?key=3kd8ub1llcg9t45hnoh8hmn7t5kc2v';
  
  static const String _vietcombankApiUrl =
      'https://portal.vietcombank.com.vn/Usercontrols/TVPortal.TyGia/pXML.aspx?b=10';
  
  // ❌ DISABLED: PNJ API không hoạt động
  // static const String _pnjApiUrl =
  //     'https://api.pnj.io/pnjcomvn/v1/gold-price';
  
  // ⚠️ NOT USED: MetalPriceAPI - Requires paid API key ($19/month)
  // static const String _metalPriceApiUrl = 
  //     'https://api.metalpriceapi.com/v1/latest';
  // static const String _metalPriceApiKey = 'YOUR_API_KEY';
  
  // Tỷ giá USD/VND (sẽ được cập nhật từ Vietcombank API)
  static double _usdToVnd = 24000.0;

  /// Lấy giá vàng Việt Nam từ BTMC (JSON format) với backup API
  Future<BTMCApiResponse?> getVietnamGoldPrice() async {
    try {
      print('🔄 Đang gọi API giá vàng Việt Nam...');
      
      // Thử API 1: BTMC (JSON format mới)
      try {
        print('📡 API 1: BTMC...');
        final response = await http.get(
          Uri.parse(_btmcApiUrl),
          headers: {
            'Accept': 'application/json, application/xml, */*',
            'User-Agent': 'Mozilla/5.0',
          },
        ).timeout(const Duration(seconds: 15));

        print('📡 BTMC Status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          // BTMC API trả về JSON với format đặc biệt
          final jsonData = json.decode(utf8.decode(response.bodyBytes));
          print('✅ BTMC JSON parsed thành công');
          
          if (jsonData is Map && jsonData.containsKey('DataList')) {
            final dataList = jsonData['DataList'];
            
            if (dataList is Map && dataList.containsKey('Data')) {
              final data = dataList['Data'] as List;
              print('📊 Số loại vàng: ${data.length}');

              if (data.isNotEmpty) {
                final prices = <GoldPriceVietnam>[];
                
                // Parse từng item với format @key_N
                for (var i = 0; i < data.length; i++) {
                  final item = data[i];
                  final rowNum = (i + 1).toString();
                  
                  // Fields có pattern @key_N với N là số thứ tự
                  final name = item['@n_$rowNum'] ?? '';
                  final buyPrice = item['@pb_$rowNum'] ?? '0';
                  final sellPrice = item['@ps_$rowNum'] ?? '0';
                  final updatedAt = item['@d_$rowNum'] ?? '';
                  
                  if (name.isNotEmpty) {
                    // Giữ nguyên giá VND (không chia cho 1 triệu)
                    // VD: "17230000" -> lưu là "17230000"
                    prices.add(GoldPriceVietnam(
                      type: name,
                      buy: buyPrice,
                      sell: sellPrice,
                      updateTime: updatedAt,
                    ));
                    
                    if (i < 3) {
                      final buyInMillion = (double.tryParse(buyPrice) ?? 0) / 1000000;
                      final sellInMillion = (double.tryParse(sellPrice) ?? 0) / 1000000;
                      print('💰 $name: Mua=${buyInMillion.toStringAsFixed(2)} triệu, Bán=${sellInMillion.toStringAsFixed(2)} triệu');
                    }
                  }
                }

                return BTMCApiResponse(
                  prices: prices,
                  city: 'Việt Nam',
                  date: DateTime.now().toString().split(' ')[0],
                  time: DateTime.now().toString().split(' ')[1].substring(0, 8),
                );
              }
            }
          }
        }
      } catch (btmcError) {
        print('⚠️ BTMC API lỗi: $btmcError');
      }

      // ❌ DISABLED: PNJ API - Domain không hoạt động (DNS Failed)
      // ❌ DISABLED: SJC API - Connection issues

      // Nếu tất cả API đều lỗi, trả về null
      print('❌ Tất cả API giá vàng Việt Nam đều không khả dụng');
      return null;
      
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }

  /// Lấy giá vàng quốc tế từ Metal Price API
  /// Dùng API miễn phí không cần key
  Future<GoldPriceInternational?> getInternationalGoldPrice() async {
    try {
      print('🔄 Đang gọi Gold API...');
      
      // Dùng API miễn phí không cần key
      const url = 'https://api.gold-api.com/price/XAU';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('📡 Gold API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Gold API data: $jsonData');
        
        // API trả về giá vàng và bạc
        final goldPrice = (jsonData['price'] ?? 0.0).toDouble();
        
        // Gọi API bạc riêng
        final silverResponse = await http.get(
          Uri.parse('https://api.gold-api.com/price/XAG'),
        ).timeout(const Duration(seconds: 10));
        
        final silverData = json.decode(silverResponse.body);
        final silverPrice = (silverData['price'] ?? 0.0).toDouble();
        
        print('💰 Gold: \$$goldPrice, Silver: \$$silverPrice');
        
        return GoldPriceInternational(
          goldPrice: goldPrice,
          silverPrice: silverPrice,
          timestamp: DateTime.now().toString(),
          currency: 'USD',
        );
      } else {
        print('❌ Error Gold API: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception Gold API: $e');
      return null;
    }
  }

  /// Lấy tỷ giá USD/VND từ Vietcombank
  Future<double> getUsdToVndRate() async {
    try {
      print('🔄 Đang lấy tỷ giá USD/VND từ Vietcombank...');
      
      final response = await http.get(
        Uri.parse(_vietcombankApiUrl),
        headers: {
          'Accept': 'application/xml, text/xml, */*',
          'User-Agent': 'Mozilla/5.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
        final exRates = document.findAllElements('Exrate').toList();
        
        // Tìm USD
        final usdRate = exRates.firstWhere(
          (rate) => rate.getAttribute('CurrencyCode') == 'USD',
          orElse: () => exRates.first,
        );
        
        final sellRate = usdRate.getAttribute('Sell')?.replaceAll(',', '') ?? '24000';
        final rate = double.tryParse(sellRate) ?? 24000.0;
        
        print('💱 Tỷ giá USD/VND: $rate');
        _usdToVnd = rate;
        return rate;
      }
    } catch (e) {
      print('⚠️ Lỗi lấy tỷ giá: $e');
    }
    
    return _usdToVnd;
  }

  /// Lấy tất cả tỷ giá ngoại tệ từ Vietcombank
  Future<ExchangeRateResponse?> getExchangeRates() async {
    try {
      print('🔄 Đang lấy tỷ giá ngoại tệ từ Vietcombank...');
      
      final response = await http.get(
        Uri.parse(_vietcombankApiUrl),
        headers: {
          'Accept': 'application/xml, text/xml, */*',
          'User-Agent': 'Mozilla/5.0',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 Vietcombank Exchange Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
        print('✅ Vietcombank Exchange XML parsed thành công');
        
        final exRates = document.findAllElements('Exrate').toList();
        final dateTime = document.findAllElements('DateTime').firstOrNull?.innerText ?? 
                        DateTime.now().toString();
        
        print('📊 Số loại ngoại tệ: ${exRates.length}');
        
        final rates = exRates.map((rate) {
          final code = rate.getAttribute('CurrencyCode') ?? '';
          final name = rate.getAttribute('CurrencyName') ?? '';
          print('💱 $code - $name');
          return ExchangeRate.fromXml(rate);
        }).toList();

        // Cập nhật USD/VND
        final usdRate = rates.firstWhere(
          (rate) => rate.currencyCode == 'USD',
          orElse: () => rates.first,
        );
        if (usdRate.sellValue > 0) {
          _usdToVnd = usdRate.sellValue;
        }

        return ExchangeRateResponse(
          rates: rates,
          dateTime: dateTime,
          source: 'Vietcombank',
        );
      }
    } catch (e) {
      print('❌ Exception Vietcombank Exchange: $e');
    }
    
    return null;
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
