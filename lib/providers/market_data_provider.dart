import 'package:flutter/material.dart';
import 'package:my_flutter_app/services/supabase_service.dart';
import 'package:my_flutter_app/models/supabase_exchange_rate.dart';
import 'package:my_flutter_app/models/supabase_market_price.dart';

/// Provider quản lý Market Data state (Exchange Rates, Gold/Silver Prices)
class MarketDataProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  // Exchange Rates
  List<SupabaseExchangeRate> _exchangeRates = [];
  bool _isLoadingExchangeRates = false;
  String? _exchangeRatesError;

  // Vietnam Gold Prices
  List<SupabaseMarketPrice> _vietnamGoldPrices = [];
  bool _isLoadingVietnamGold = false;
  String? _vietnamGoldError;

  // Global Metal Prices
  SupabaseMarketPrice? _globalGoldPrice;
  SupabaseMarketPrice? _globalSilverPrice;
  bool _isLoadingGlobalMetals = false;
  String? _globalMetalsError;

  // Getters
  List<SupabaseExchangeRate> get exchangeRates => _exchangeRates;
  bool get isLoadingExchangeRates => _isLoadingExchangeRates;
  String? get exchangeRatesError => _exchangeRatesError;

  List<SupabaseMarketPrice> get vietnamGoldPrices => _vietnamGoldPrices;
  bool get isLoadingVietnamGold => _isLoadingVietnamGold;
  String? get vietnamGoldError => _vietnamGoldError;

  SupabaseMarketPrice? get globalGoldPrice => _globalGoldPrice;
  SupabaseMarketPrice? get globalSilverPrice => _globalSilverPrice;
  bool get isLoadingGlobalMetals => _isLoadingGlobalMetals;
  String? get globalMetalsError => _globalMetalsError;

  /// Load tất cả data khi app khởi động
  Future<void> loadAllMarketData() async {
    await Future.wait([
      fetchExchangeRates(),
      fetchVietnamGoldPrices(),
      fetchGlobalMetalPrices(),
    ]);
  }

  /// Lấy tỷ giá ngoại tệ
  Future<void> fetchExchangeRates() async {
    _isLoadingExchangeRates = true;
    _exchangeRatesError = null;
    notifyListeners();

    try {
      _exchangeRates = await _supabaseService.getLatestExchangeRates(limit: 20);
      _exchangeRatesError = null;
    } catch (e) {
      _exchangeRatesError = 'Không thể tải tỷ giá: $e';
      print(_exchangeRatesError);
    } finally {
      _isLoadingExchangeRates = false;
      notifyListeners();
    }
  }

  /// Tìm tỷ giá theo currency code
  SupabaseExchangeRate? getExchangeRateByCurrency(String currencyCode) {
    try {
      return _exchangeRates.firstWhere(
        (rate) => rate.currencyCode == currencyCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// Lấy giá vàng SJC Việt Nam (tất cả khu vực)
  Future<void> fetchVietnamGoldPrices() async {
    _isLoadingVietnamGold = true;
    _vietnamGoldError = null;
    notifyListeners();

    try {
      _vietnamGoldPrices = await _supabaseService.getVietnamGoldPrices();
      _vietnamGoldError = null;
    } catch (e) {
      _vietnamGoldError = 'Không thể tải giá vàng VN: $e';
      print(_vietnamGoldError);
    } finally {
      _isLoadingVietnamGold = false;
      notifyListeners();
    }
  }

  /// Tìm giá vàng theo region ID
  SupabaseMarketPrice? getGoldPriceByRegion(int regionId) {
    try {
      return _vietnamGoldPrices.firstWhere(
        (price) => price.regionId == regionId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Lấy giá vàng HCM (region_id = 2)
  SupabaseMarketPrice? get goldPriceHCM => getGoldPriceByRegion(2);

  /// Lấy giá vàng Hà Nội (region_id = 1)
  SupabaseMarketPrice? get goldPriceHanoi => getGoldPriceByRegion(1);

  /// Lấy giá vàng và bạc quốc tế (Kitco)
  Future<void> fetchGlobalMetalPrices() async {
    _isLoadingGlobalMetals = true;
    _globalMetalsError = null;
    notifyListeners();

    try {
      final prices = await _supabaseService.getGlobalMetalPrices();
      
      for (var price in prices) {
        if (price.isGold) {
          _globalGoldPrice = price;
        } else if (price.isSilver) {
          _globalSilverPrice = price;
        }
      }
      
      _globalMetalsError = null;
    } catch (e) {
      _globalMetalsError = 'Không thể tải giá kim loại quốc tế: $e';
      print(_globalMetalsError);
    } finally {
      _isLoadingGlobalMetals = false;
      notifyListeners();
    }
  }

  /// Refresh tất cả data
  Future<void> refreshAll() async {
    await loadAllMarketData();
  }

  /// Clear tất cả errors
  void clearErrors() {
    _exchangeRatesError = null;
    _vietnamGoldError = null;
    _globalMetalsError = null;
    notifyListeners();
  }
}
