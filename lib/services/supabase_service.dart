import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/config/supabase_config.dart';
import 'package:my_flutter_app/models/supabase_exchange_rate.dart';
import 'package:my_flutter_app/models/supabase_market_price.dart';

/// Service để lấy dữ liệu giá vàng và tỷ giá từ Supabase
/// Data được scrape từ:
/// - Vietcombank (Forex)
/// - CafeF (Gold - Vietnam)
/// - Kitco (Gold & Silver - Global)
class SupabaseService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Lấy tỷ giá ngoại tệ mới nhất (tất cả currencies)
  Future<List<SupabaseExchangeRate>> getLatestExchangeRates({int limit = 100}) async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}${SupabaseConfig.exchangeRatesEndpoint}'
        '?select=*&order=timestamp.desc&limit=$limit',
      );

      final response = await http
          .get(url, headers: SupabaseConfig.headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => SupabaseExchangeRate.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch exchange rates: $e');
    }
  }

  /// Lấy tỷ giá của một loại tiền tệ cụ thể
  Future<SupabaseExchangeRate?> getExchangeRateByCurrency(String currencyCode) async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}${SupabaseConfig.exchangeRatesEndpoint}'
        '?select=*&currency_code=eq.$currencyCode&order=timestamp.desc&limit=1',
      );

      final response = await http
          .get(url, headers: SupabaseConfig.headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return SupabaseExchangeRate.fromJson(data.first);
        }
        return null;
      } else {
        throw Exception('Failed to load exchange rate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch exchange rate for $currencyCode: $e');
    }
  }

  /// Lấy lịch sử tỷ giá trong khoảng thời gian
  Future<List<SupabaseExchangeRate>> getExchangeRateHistory({
    required String currencyCode,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final end = endDate ?? DateTime.now();
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}${SupabaseConfig.exchangeRatesEndpoint}'
        '?select=*&currency_code=eq.$currencyCode'
        '&timestamp=gte.${startDate.toIso8601String()}'
        '&timestamp=lte.${end.toIso8601String()}'
        '&order=timestamp.desc',
      );

      final response = await http
          .get(url, headers: SupabaseConfig.headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => SupabaseExchangeRate.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load exchange rate history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch exchange rate history: $e');
    }
  }

  /// Lấy giá vàng SJC mới nhất (tất cả khu vực Việt Nam)
  Future<List<SupabaseMarketPrice>> getVietnamGoldPrices() async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}${SupabaseConfig.marketPriceEndpoint}'
        '?select=*'
        '&asset_id=eq.${SupabaseMarketPrice.ASSET_GOLD}'
        '&source_id=eq.${SupabaseMarketPrice.SOURCE_CAFEF}'
        '&order=timestamp.desc,region_id.asc',
      );

      final response = await http
          .get(url, headers: SupabaseConfig.headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => SupabaseMarketPrice.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load Vietnam gold prices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch Vietnam gold prices: $e');
    }
  }

  /// Lấy giá vàng của một khu vực cụ thể
  Future<SupabaseMarketPrice?> getGoldPriceByRegion(int regionId) async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}${SupabaseConfig.marketPriceEndpoint}'
        '?select=*'
        '&asset_id=eq.${SupabaseMarketPrice.ASSET_GOLD}'
        '&source_id=eq.${SupabaseMarketPrice.SOURCE_CAFEF}'
        '&region_id=eq.$regionId'
        '&order=timestamp.desc&limit=1',
      );

      final response = await http
          .get(url, headers: SupabaseConfig.headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return SupabaseMarketPrice.fromJson(data.first);
        }
        return null;
      } else {
        throw Exception('Failed to load gold price: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch gold price for region $regionId: $e');
    }
  }

  /// Lấy giá vàng quốc tế (Kitco)
  Future<SupabaseMarketPrice?> getGlobalGoldPrice() async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}${SupabaseConfig.marketPriceEndpoint}'
        '?select=*'
        '&asset_id=eq.${SupabaseMarketPrice.ASSET_GOLD}'
        '&source_id=eq.${SupabaseMarketPrice.SOURCE_KITCO}'
        '&region_id=eq.${SupabaseMarketPrice.REGION_GLOBAL}'
        '&order=timestamp.desc&limit=1',
      );

      final response = await http
          .get(url, headers: SupabaseConfig.headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return SupabaseMarketPrice.fromJson(data.first);
        }
        return null;
      } else {
        throw Exception('Failed to load global gold price: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch global gold price: $e');
    }
  }

  /// Lấy giá bạc quốc tế (Kitco)
  Future<SupabaseMarketPrice?> getGlobalSilverPrice() async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}${SupabaseConfig.marketPriceEndpoint}'
        '?select=*'
        '&asset_id=eq.${SupabaseMarketPrice.ASSET_SILVER}'
        '&source_id=eq.${SupabaseMarketPrice.SOURCE_KITCO}'
        '&region_id=eq.${SupabaseMarketPrice.REGION_GLOBAL}'
        '&order=timestamp.desc&limit=1',
      );

      final response = await http
          .get(url, headers: SupabaseConfig.headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return SupabaseMarketPrice.fromJson(data.first);
        }
        return null;
      } else {
        throw Exception('Failed to load global silver price: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch global silver price: $e');
    }
  }

  /// Lấy tất cả giá vàng và bạc quốc tế
  Future<List<SupabaseMarketPrice>> getGlobalMetalPrices() async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}${SupabaseConfig.marketPriceEndpoint}'
        '?select=*'
        '&source_id=eq.${SupabaseMarketPrice.SOURCE_KITCO}'
        '&region_id=eq.${SupabaseMarketPrice.REGION_GLOBAL}'
        '&order=timestamp.desc,asset_id.asc',
      );

      final response = await http
          .get(url, headers: SupabaseConfig.headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => SupabaseMarketPrice.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load global metal prices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch global metal prices: $e');
    }
  }

  /// Lấy lịch sử giá vàng trong khoảng thời gian
  Future<List<SupabaseMarketPrice>> getGoldPriceHistory({
    required int regionId,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final end = endDate ?? DateTime.now();
      final url = Uri.parse(
        '${SupabaseConfig.supabaseUrl}${SupabaseConfig.marketPriceEndpoint}'
        '?select=*'
        '&asset_id=eq.${SupabaseMarketPrice.ASSET_GOLD}'
        '&region_id=eq.$regionId'
        '&timestamp=gte.${startDate.toIso8601String()}'
        '&timestamp=lte.${end.toIso8601String()}'
        '&order=timestamp.desc',
      );

      final response = await http
          .get(url, headers: SupabaseConfig.headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => SupabaseMarketPrice.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load gold price history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch gold price history: $e');
    }
  }
}
