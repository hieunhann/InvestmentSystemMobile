import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/models/exchange_rate.dart';
import 'package:my_flutter_app/models/gold_price_international.dart';
import 'package:my_flutter_app/models/gold_price_vietnam.dart';
import 'package:my_flutter_app/services/gold_price_service.dart';

@immutable
class PublicMarketState {
  final bool isLoading;

  // Per-API errors (null = no error / not attempted)
  final String? vietnamError;
  final String? internationalError;
  final String? exchangeError;

  /// Used for trend chart (derived from API over time, in-memory only)
  final List<MarketSnapshot> history;
  final List<MarketSnapshot> silverHistory;
  final List<MarketSnapshot> currencyHistory;

  /// Lựa chọn thời gian của user cho biểu đồ
  final String selectedRange;

  final BTMCApiResponse? vietnam;
  final BTMCApiResponse? vietnamSilver;
  final GoldPriceInternational? international;
  final ExchangeRateResponse? exchangeRates;
  final double usdToVnd;

  const PublicMarketState({
    required this.isLoading,
    required this.vietnamError,
    required this.internationalError,
    required this.exchangeError,
    required this.vietnam,
    required this.vietnamSilver,
    required this.international,
    required this.exchangeRates,
    required this.usdToVnd,
    required this.history,
    required this.silverHistory,
    required this.currencyHistory,
    required this.selectedRange,
  });

  const PublicMarketState.initial()
    : this(
        isLoading: true,
        vietnamError: null,
        internationalError: null,
        exchangeError: null,
        vietnam: null,
        vietnamSilver: null,
        international: null,
        exchangeRates: null,
        usdToVnd: 0,
        history: const [],
        silverHistory: const [],
        currencyHistory: const [],
        selectedRange: '1m',
      );

  PublicMarketState copyWith({
    bool? isLoading,
    String? vietnamError,
    String? internationalError,
    String? exchangeError,
    BTMCApiResponse? vietnam,
    BTMCApiResponse? vietnamSilver,
    GoldPriceInternational? international,
    ExchangeRateResponse? exchangeRates,
    double? usdToVnd,
    List<MarketSnapshot>? history,
    List<MarketSnapshot>? silverHistory,
    List<MarketSnapshot>? currencyHistory,
    String? selectedRange,
  }) {
    return PublicMarketState(
      isLoading: isLoading ?? this.isLoading,
      vietnamError: vietnamError,
      internationalError: internationalError,
      exchangeError: exchangeError,
      vietnam: vietnam ?? this.vietnam,
      vietnamSilver: vietnamSilver ?? this.vietnamSilver,
      international: international ?? this.international,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      usdToVnd: usdToVnd ?? this.usdToVnd,
      history: history ?? this.history,
      silverHistory: silverHistory ?? this.silverHistory,
      currencyHistory: currencyHistory ?? this.currencyHistory,
      selectedRange: selectedRange ?? this.selectedRange,
    );
  }
}

@immutable
class MarketSnapshot {
  final DateTime at;
  final double? domesticSell;
  final double? worldGoldUsd;
  final double? worldPriceVnd; // Normalized value for chart

  const MarketSnapshot({
    required this.at,
    this.domesticSell,
    this.worldGoldUsd,
    this.worldPriceVnd,
  });
}

class PublicMarketCubit extends Cubit<PublicMarketState> {
  final GoldPriceService _service;

  PublicMarketCubit(this._service) : super(const PublicMarketState.initial()) {
    load();
  }

  Future<void> load({String? range}) async {
    final currentRange = range ?? state.selectedRange;
    emit(
      state.copyWith(
        isLoading: true,
        selectedRange: currentRange,
        vietnamError: null,
        internationalError: null,
        exchangeError: null,
      ),
    );

    BTMCApiResponse? vietnam;
    BTMCApiResponse? vietnamSilver;
    GoldPriceInternational? international;
    ExchangeRateResponse? exchange;
    double usdToVnd = 0;

    String? vnErr;
    String? intlErr;
    String? exErr;

    // 1. Lấy giá vàng & bạc Việt Nam (last 1d for current prices)
    try {
      final futures = await Future.wait([
        _service.getVietnamGoldPrice(),
        _service.getVietnamSilverPrice(),
      ]);
      vietnam = futures[0];
      vietnamSilver = futures[1];
      if (vietnam == null && vietnamSilver == null)
        vnErr = 'Vietnam API returned no data.';
    } catch (e) {
      vnErr = e.toString();
    }

    // 2. Lấy giá vàng quốc tế (last 1d for current prices)
    try {
      international = await _service.getInternationalGoldPrice();
      if (international == null)
        intlErr = 'International metal API returned no data.';
    } catch (e) {
      intlErr = e.toString();
    }

    // 3. Lấy tỷ giá
    try {
      exchange = await _service.getExchangeRates();
      if (exchange == null || exchange.rates.isEmpty) {
        exErr = 'Exchange rate API returned no data.';
      } else {
        try {
          usdToVnd =
              exchange.rates
                  .firstWhere((r) => r.currencyCode == 'USD')
                  .sellValue;
        } catch (_) {
          usdToVnd = exchange.rates.first.sellValue;
        }
      }
    } catch (e) {
      exErr = e.toString();
    }

    // 4. Lấy lịch sử biến động giá (cho biểu đồ)
    List<MarketSnapshot> newHistory = [];
    List<MarketSnapshot> newSilverHistory = [];
    List<MarketSnapshot> newCurrencyHistory = [];
    try {
      final vnHistoryInfo = await _service.getPriceHistory(
        'vn-all',
        'gold',
        currentRange,
      );
      final glHistoryInfo = await _service.getPriceHistory(
        'global',
        'gold',
        currentRange,
      );

      final vnSilverHistoryInfo = await _service.getPriceHistory(
        'vn-all',
        'silver',
        currentRange,
      );
      final glSilverHistoryInfo = await _service.getPriceHistory(
        'global',
        'silver',
        currentRange,
      );

      final currencyHistoryInfo = await _service.getCurrencyHistory(
        'USD',
        currentRange,
      );

      // Map to store aligned data by date string
      final Map<String, MarketSnapshot> alignedGold = {};
      final Map<String, MarketSnapshot> alignedSilver = {};
      final Map<String, double> historicalRates = {};

      String getDateKey(dynamic item) {
        final ts =
            item['timestamp'] ?? item['updateDate'] ?? item['update_date'];
        final date = DateTime.tryParse(ts?.toString() ?? '');
        if (date == null) return '';
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      DateTime getDateTime(dynamic item) {
        final ts =
            item['timestamp'] ?? item['updateDate'] ?? item['update_date'];
        return DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();
      }

      // Process Currency first for rate lookup
      for (final item in currencyHistoryInfo) {
        final key = getDateKey(item);
        if (key.isEmpty) continue;
        final val = item['sellPrice'] ?? item['sell'] ?? item['sell_price'];
        final sell = double.tryParse(val?.toString() ?? '');
        if (sell != null && sell > 0) {
          historicalRates[key] = sell;
          newCurrencyHistory.add(
            MarketSnapshot(
              at: getDateTime(item),
              domesticSell: sell,
              worldGoldUsd: null,
            ),
          );
        }
      }
      newCurrencyHistory.sort((a, b) => a.at.compareTo(b.at));

      // Process Vietnam Gold
      for (final item in vnHistoryInfo) {
        final key = getDateKey(item);
        if (key.isEmpty) continue;
        final val = item['sellPrice'] ?? item['sell'] ?? item['sell_price'];
        final sell = double.tryParse(val?.toString() ?? '');
        if (sell != null && sell > 0) {
          final normalizedSell = _normalizeDomesticGoldSell(sell);
          alignedGold[key] = MarketSnapshot(
            at: getDateTime(item),
            domesticSell: normalizedSell,
          );
        }
      }

      // Process Global Gold
      for (final item in glHistoryInfo) {
        final key = getDateKey(item);
        if (key.isEmpty) continue;
        final val =
            item['buyPrice'] ??
            item['buy'] ??
            item['price'] ??
            item['buy_price'];
        final priceUsd = double.tryParse(val?.toString() ?? '');
        if (priceUsd != null && priceUsd > 0) {
          final existing = alignedGold[key];

          // Calculate normalized VND price (Ounce)
          final rate = historicalRates[key] ?? usdToVnd;
          final normalizedVnd =
              rate > 0 ? (priceUsd * rate) / 1000000 : null;

          alignedGold[key] = MarketSnapshot(
            at: existing?.at ?? getDateTime(item),
            domesticSell: existing?.domesticSell,
            worldGoldUsd: priceUsd,
            worldPriceVnd: normalizedVnd,
          );
        }
      }

      // Process Vietnam Silver
      for (final item in vnSilverHistoryInfo) {
        final key = getDateKey(item);
        if (key.isEmpty) continue;
        final val = item['sellPrice'] ?? item['sell'] ?? item['sell_price'];
        final sell = double.tryParse(val?.toString() ?? '');
        if (sell != null && sell > 0) {
          alignedSilver[key] = MarketSnapshot(
            at: getDateTime(item),
            domesticSell: sell,
          );
        }
      }

      // Process Global Silver
      for (final item in glSilverHistoryInfo) {
        final key = getDateKey(item);
        if (key.isEmpty) continue;
        final val = item['buyPrice'] ?? item['buy'] ?? item['buy_price'];
        final priceUsd = double.tryParse(val?.toString() ?? '');
        if (priceUsd != null && priceUsd > 0) {
          final existing = alignedSilver[key];

          // Calculate normalized VND price (Ounce)
          final rate = historicalRates[key] ?? usdToVnd;
          final normalizedVnd =
              rate > 0 ? (priceUsd * rate) / 1000000 : null;

          alignedSilver[key] = MarketSnapshot(
            at: existing?.at ?? getDateTime(item),
            domesticSell: existing?.domesticSell,
            worldGoldUsd: priceUsd,
            worldPriceVnd: normalizedVnd,
          );
        }
      }

      // Convert Maps to Sorted Lists
      newHistory =
          alignedGold.values.toList()..sort((a, b) => a.at.compareTo(b.at));
      newSilverHistory =
          alignedSilver.values.toList()..sort((a, b) => a.at.compareTo(b.at));
    } catch (e) {
      print('History fetch error: $e');
    }

    // Fallback if APIs fail
    if (newHistory.isEmpty && state.history.isEmpty) {
      final sjc = _pickGoldBaseLike(vietnam);
      final worldVnd =
          international != null && usdToVnd > 0
              ? (international.goldPrice * usdToVnd) / 1000000
              : null;
      final snap = MarketSnapshot(
        at: DateTime.now(),
        domesticSell: sjc?.sellPrice,
        worldGoldUsd: international?.goldPrice,
        worldPriceVnd: worldVnd,
      );
      if (snap.domesticSell != null || snap.worldGoldUsd != null)
        newHistory.add(snap);
    } else if (newHistory.isEmpty) {
      newHistory = state.history;
    }

    if (newSilverHistory.isEmpty && state.silverHistory.isEmpty) {
      final vnSilverBase = _pickSilverBaseLike(vietnamSilver);
      final worldVnd =
          international != null && usdToVnd > 0
              ? (international.silverPrice * usdToVnd) / 1000000
              : null;
      final snap = MarketSnapshot(
        at: DateTime.now(),
        domesticSell: vnSilverBase?.sellPrice,
        worldGoldUsd: international?.silverPrice,
        worldPriceVnd: worldVnd,
      );
      if (snap.domesticSell != null || snap.worldGoldUsd != null)
        newSilverHistory.add(snap);
    } else if (newSilverHistory.isEmpty) {
      newSilverHistory = state.silverHistory;
    }

    if (newCurrencyHistory.isEmpty && state.currencyHistory.isEmpty) {
      if (usdToVnd > 0) {
        newCurrencyHistory.add(
          MarketSnapshot(
            at: DateTime.now(),
            domesticSell: usdToVnd,
            worldGoldUsd: null,
          ),
        );
      }
    } else if (newCurrencyHistory.isEmpty) {
      newCurrencyHistory = state.currencyHistory;
    }

    emit(
      state.copyWith(
        isLoading: false,
        vietnamError: vnErr,
        internationalError: intlErr,
        exchangeError: exErr,
        vietnam: vietnam,
        vietnamSilver: vietnamSilver,
        international: international,
        exchangeRates: exchange,
        usdToVnd: usdToVnd,
        history: newHistory,
        silverHistory: newSilverHistory,
        currencyHistory: newCurrencyHistory,
      ),
    );
  }

  GoldPriceVietnam? _pickGoldBaseLike(BTMCApiResponse? vn) {
    if (vn == null || vn.prices.isEmpty) return null;
    try {
      return vn.prices.firstWhere((p) => p.type.toUpperCase().contains('SJC'));
    } catch (_) {
      return vn.prices.first;
    }
  }

  GoldPriceVietnam? _pickSilverBaseLike(BTMCApiResponse? vn) {
    if (vn == null || vn.prices.isEmpty) return null;
    return vn.prices.first;
  }

  // Frontend-side guard: backend goc co the tra gia Gold sai don vi (x10).
  double _normalizeDomesticGoldSell(double value) {
    var normalized = value;
    while (normalized > 500000000) {
      normalized /= 10;
    }
    while (normalized > 0 && normalized < 1000000) {
      normalized *= 1000000;
    }
    return normalized;
  }
}
