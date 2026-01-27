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

  final BTMCApiResponse? vietnam;
  final GoldPriceInternational? international;
  final ExchangeRateResponse? exchangeRates;
  final double usdToVnd;

  /// Used for trend chart (derived from API over time, in-memory only)
  final List<MarketSnapshot> history;

  const PublicMarketState({
    required this.isLoading,
    required this.vietnamError,
    required this.internationalError,
    required this.exchangeError,
    required this.vietnam,
    required this.international,
    required this.exchangeRates,
    required this.usdToVnd,
    required this.history,
  });

  const PublicMarketState.initial()
      : this(
          isLoading: true,
          vietnamError: null,
          internationalError: null,
          exchangeError: null,
          vietnam: null,
          international: null,
          exchangeRates: null,
          usdToVnd: 0,
          history: const [],
        );

  PublicMarketState copyWith({
    bool? isLoading,
    String? vietnamError,
    String? internationalError,
    String? exchangeError,
    BTMCApiResponse? vietnam,
    GoldPriceInternational? international,
    ExchangeRateResponse? exchangeRates,
    double? usdToVnd,
    List<MarketSnapshot>? history,
  }) {
    return PublicMarketState(
      isLoading: isLoading ?? this.isLoading,
      vietnamError: vietnamError,
      internationalError: internationalError,
      exchangeError: exchangeError,
      vietnam: vietnam ?? this.vietnam,
      international: international ?? this.international,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      usdToVnd: usdToVnd ?? this.usdToVnd,
      history: history ?? this.history,
    );
  }
}

@immutable
class MarketSnapshot {
  final DateTime at;
  final double? domesticSell;
  final double? worldGoldUsd;

  const MarketSnapshot({required this.at, this.domesticSell, this.worldGoldUsd});
}

class PublicMarketCubit extends Cubit<PublicMarketState> {
  final GoldPriceService _service;

  PublicMarketCubit(this._service) : super(const PublicMarketState.initial()) {
    load();
  }

  Future<void> load() async {
    emit(
      state.copyWith(
        isLoading: true,
        vietnamError: null,
        internationalError: null,
        exchangeError: null,
      ),
    );

    BTMCApiResponse? vietnam;
    GoldPriceInternational? international;
    ExchangeRateResponse? exchange;
    double usdToVnd = 0;

    String? vnErr;
    String? intlErr;
    String? exErr;

    try {
      vietnam = await _service.getVietnamGoldPrice();
      if (vietnam == null) vnErr = 'Vietnam gold API returned no data.';
    } catch (e) {
      vnErr = e.toString();
    }

    try {
      international = await _service.getInternationalGoldPrice();
      if (international == null) intlErr = 'International metal API returned no data.';
    } catch (e) {
      intlErr = e.toString();
    }

    try {
      exchange = await _service.getExchangeRates();
      if (exchange == null) {
        exErr = 'Exchange rate API returned no data.';
      } else {
        usdToVnd = exchange.rates
            .firstWhere((r) => r.currencyCode == 'USD', orElse: () => exchange!.rates.first)
            .sellValue;
      }
    } catch (e) {
      exErr = e.toString();
    }

    // Add a snapshot for chart only when we have at least one signal
    final sjc = _pickSjcLike(vietnam);
    final snap = MarketSnapshot(
      at: DateTime.now(),
      domesticSell: sjc?.sellPrice,
      worldGoldUsd: international?.goldPrice,
    );
    final hasAny = snap.domesticSell != null || snap.worldGoldUsd != null;
    final nextHistory = hasAny ? [...state.history, snap] : state.history;
    final trimmed = nextHistory.length <= 12 ? nextHistory : nextHistory.sublist(nextHistory.length - 12);

    emit(
      state.copyWith(
        isLoading: false,
        vietnamError: vnErr,
        internationalError: intlErr,
        exchangeError: exErr,
        vietnam: vietnam,
        international: international,
        exchangeRates: exchange,
        usdToVnd: usdToVnd,
        history: trimmed,
      ),
    );
  }

  GoldPriceVietnam? _pickSjcLike(BTMCApiResponse? vn) {
    if (vn == null || vn.prices.isEmpty) return null;
    try {
      return vn.prices.firstWhere((p) => p.type.toUpperCase().contains('SJC'));
    } catch (_) {
      return vn.prices.first;
    }
  }
}

