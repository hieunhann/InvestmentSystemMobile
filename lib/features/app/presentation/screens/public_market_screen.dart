import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/constants/news_data.dart';
import 'package:my_flutter_app/models/news_article.dart';
import 'package:my_flutter_app/features/app/bloc/public_market_cubit.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/market_buy_sell_chart.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/market_chart_panel.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';
import 'dart:math';


class _MarketPrice {
  final String type;
  final double buyPrice;
  final double sellPrice;
  final String location;

  const _MarketPrice({
    required this.type,
    required this.buyPrice,
    required this.sellPrice,
    required this.location,
  });
}

class PublicMarketScreen extends StatefulWidget {
  const PublicMarketScreen({super.key});

  @override
  State<PublicMarketScreen> createState() => _PublicMarketScreenState();
}

class _PublicMarketScreenState extends State<PublicMarketScreen> {
  int _tabIndex = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketState = context.watch<PublicMarketCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final username = authState.user?.orgName;
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final vertical = (size.height * 0.02).clamp(12.0, 18.0);

    final vietnamPrices =
        marketState.vietnam != null && marketState.vietnam!.prices.isNotEmpty
            ? marketState.vietnam!.prices
                .map(
                  (p) => _MarketPrice(
                    type: p.type,
                    buyPrice: p.buyPrice,
                    sellPrice: p.sellPrice,
                    location: 'VN',
                  ),
                )
                .toList()
            : <_MarketPrice>[];

    final sjc =
        vietnamPrices.isEmpty
            ? null
            : vietnamPrices.firstWhere(
              (p) => p.type.toUpperCase().contains('SJC'),
              orElse: () => vietnamPrices.first,
            );

    final vietnamSilverPrices =
        marketState.vietnamSilver != null &&
                marketState.vietnamSilver!.prices.isNotEmpty
            ? marketState.vietnamSilver!.prices
                .map(
                  (p) => _MarketPrice(
                    type: p.type,
                    buyPrice: p.buyPrice,
                    sellPrice: p.sellPrice,
                    location: 'VN',
                  ),
                )
                .toList()
            : <_MarketPrice>[];

    final vnSilverBase =
        vietnamSilverPrices.isEmpty ? null : vietnamSilverPrices.first;

    final usdToVnd = marketState.usdToVnd;
    final worldGoldVnd =
        usdToVnd > 0
            ? (marketState.international?.goldPricePerTaelInVND(usdToVnd) ??
                0.0)
            : 0.0;
    final worldSilverVnd =
        usdToVnd > 0
            ? (marketState.international?.silverPricePerKgInVND(usdToVnd) ??
                0.0)
            : 0.0;

    // Unified Gold Series
    final List<double> goldDBuy = [];
    final List<double> goldDSell = [];
    final List<double> goldW = [];
    double? lastGDS;
    double? lastGWV; // Use pre-calculated VND value

    // Calculate current spread to estimate buy prices
    final currentSpread = (sjc?.sellPrice ?? 0) - (sjc?.buyPrice ?? 0);

    for (var e in marketState.history) {
      if (e.domesticSell != null && e.domesticSell! > 0)
        lastGDS = e.domesticSell;
      if (e.worldPriceVnd != null && e.worldPriceVnd! > 0)
        lastGWV = e.worldPriceVnd;

      if (lastGDS != null) {
        goldDSell.add(lastGDS / 1000000);
        goldDBuy.add((lastGDS - currentSpread) / 1000000);
      }
      if (lastGWV != null) goldW.add(lastGWV);

      if (lastGDS != null && lastGWV == null) goldW.add(0.0);
      if (lastGWV != null && lastGDS == null) {
        goldDSell.add(0.0);
        goldDBuy.add(0.0);
      }
    }

    final chartDomesticBuy = _safeSeries(goldDBuy);
    final chartDomesticSell = _safeSeries(goldDSell);
    final chartWorld = _safeSeries(goldW);

    // Unified Silver Series
    final List<double> silverDBuy = [];
    final List<double> silverDSell = [];
    final List<double> silverW = [];
    double? lastSDS;
    double? lastSWV;

    // Calculate current spread to estimate buy prices
    final currentSilverSpread =
        (vnSilverBase?.sellPrice ?? 0) - (vnSilverBase?.buyPrice ?? 0);

    for (var e in marketState.silverHistory) {
      if (e.domesticSell != null && e.domesticSell! > 0)
        lastSDS = e.domesticSell;
      if (e.worldPriceVnd != null && e.worldPriceVnd! > 0)
        lastSWV = e.worldPriceVnd;

      if (lastSDS != null) {
        silverDSell.add(lastSDS / 1000000);
        silverDBuy.add((lastSDS - currentSilverSpread) / 1000000);
      }
      if (lastSWV != null) silverW.add(lastSWV);

      if (lastSDS != null && lastSWV == null) silverW.add(0.0);
      if (lastSWV != null && lastSDS == null) {
        silverDSell.add(0.0);
        silverDBuy.add(0.0);
      }
    }

    final chartDomesticSilverBuy = _safeSeries(silverDBuy);
    final chartDomesticSilverSell = _safeSeries(silverDSell);
    final chartWorldSilver = _safeSeries(silverW);

    // GOLD METRICS LOGIC (FE: useMarketInsights.js)
    final domesticPriceChange = _getDelta(chartDomesticSell);
    final worldPriceChange = _getDelta(chartWorld);

    // Premium logic: premium = domesticSell - worldLocalVnd
    final List<double> goldPremiumSeries = [];
    for (var e in marketState.history) {
      if (e.domesticSell != null && e.worldPriceVnd != null) {
        goldPremiumSeries.add(e.domesticSell! - (e.worldPriceVnd! * 1000000));
      }
    }
    final latestGoldPremium = (sjc?.sellPrice ?? 0) - worldGoldVnd;
    final goldPremiumChange = _getDelta(goldPremiumSeries);

    // Correlation (1M)
    final List<double> goldDSellHistory = marketState.history.where((e) => e.domesticSell != null).map((e) => e.domesticSell!).toList();
    final List<double> goldWHistory = marketState.history.where((e) => e.worldPriceVnd != null).map((e) => e.worldPriceVnd! * 1000000).toList();
    final goldCorrelation = _calcCorrelation(goldDSellHistory, goldWHistory);

    // SILVER METRICS LOGIC
    final domesticSilverPriceChange = _getDelta(chartDomesticSilverSell);
    final worldSilverPriceChange = _getDelta(chartWorldSilver);

    final List<double> silverPremiumSeries = [];
    for (var e in marketState.silverHistory) {
      if (e.domesticSell != null && e.worldPriceVnd != null) {
        silverPremiumSeries.add(e.domesticSell! - (e.worldPriceVnd! * 1000000));
      }
    }
    final latestSilverPremium = (vnSilverBase?.sellPrice ?? 0) - worldSilverVnd;
    final silverPremiumChange = _getDelta(silverPremiumSeries);

    final List<double> silverDSellHistory = marketState.silverHistory.where((e) => e.domesticSell != null).map((e) => e.domesticSell!).toList();
    final List<double> silverWHistory = marketState.silverHistory.where((e) => e.worldPriceVnd != null).map((e) => e.worldPriceVnd! * 1000000).toList();
    final silverCorrelation = _calcCorrelation(silverDSellHistory, silverWHistory);

    final currencyHistoryList =
        marketState.currencyHistory
            .where((e) => e.domesticSell != null)
            .map((e) => e.domesticSell!)
            .toList();
    final chartCurrency = _safeSeries(currencyHistoryList);
    final currencyPriceChange =
        chartCurrency.length >= 2
            ? ((chartCurrency.last - chartCurrency[chartCurrency.length - 2]) /
                    chartCurrency[chartCurrency.length - 2]) *
                100
            : 0.0;

    return Column(
      children: [
        AppHeader(
          title: 'Market',
          username: username,
          bottom: _MarketTabs(
            currentIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<PublicMarketCubit>().load();
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                vertical,
                horizontal,
                vertical,
              ),
              children: [
                if (_tabIndex == 0) ...[
                  // Gold Tab
                  const Text('MARKET INSIGHT BOARD', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.black54, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Gold: Domestic SJC vs. International Spot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 12),
                  MarketMetricCards(
                    metrics: buildGoldMetrics(
                      domesticSell: sjc?.sellPrice ?? 0,
                      worldLocal: worldGoldVnd,
                      premium: latestGoldPremium,
                      exchangeRate: usdToVnd,
                      correlation: goldCorrelation,
                      domesticChange: domesticPriceChange,
                      worldChange: worldPriceChange,
                      premiumChange: goldPremiumChange,
                    ),
                  ),
                  MarketChartPanel(
                    topWidget: _RangeToggles(
                      selected: marketState.selectedRange,
                      onChanged: (val) => context.read<PublicMarketCubit>().load(range: val),
                    ),
                    leftSeries: chartDomesticBuy, // Using buy price for tracking line roughly
                    rightSeries: chartWorld,
                    bars: List.generate(chartDomesticBuy.length, (i) {
                      if (i < chartWorld.length && chartWorld[i] > 0) return chartDomesticBuy[i] - chartWorld[i];
                      return 0.0;
                    }),
                    dates: marketState.history.map((s) => s.at).toList(),
                    leftLabel: 'SJC Gold (VND/luong)',
                    rightLabel: 'Spot Gold (VND/luong, converted)',
                    barLabel: 'Domestic Premium (VND/Luong)',
                    isLoading: marketState.isLoading,
                    emptyText: 'No API history points available yet.',
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('Live Buy / Sell Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            _RangeToggles(
                              selected: marketState.selectedRange,
                              onChanged: (val) => context.read<PublicMarketCubit>().load(range: val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        MarketBuySellChart(
                          buySeries: chartDomesticBuy,
                          sellSeries: chartDomesticSell,
                          dates: marketState.history.map((s) => s.at).toList(),
                          label: 'SJC Gold Buy / Sell Live',
                          unitLabel: 'VND',
                        ),
                      ],
                    ),
                  ),
                ] else if (_tabIndex == 1) ...[
                  // Silver Tab
                  const Text('MARKET INSIGHT BOARD', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.black54, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Silver: Phu Quy Domestic vs. International Spot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 12),
                  MarketMetricCards(
                    metrics: buildSilverMetrics(
                      domesticSell: vnSilverBase?.sellPrice ?? 0,
                      worldLocal: worldSilverVnd,
                      premium: latestSilverPremium,
                      exchangeRate: usdToVnd,
                      correlation: silverCorrelation,
                      domesticChange: domesticSilverPriceChange,
                      worldChange: worldSilverPriceChange,
                      premiumChange: silverPremiumChange,
                    ),
                  ),
                  MarketChartPanel(
                    topWidget: _RangeToggles(
                      selected: marketState.selectedRange,
                      onChanged: (val) => context.read<PublicMarketCubit>().load(range: val),
                    ),
                    leftSeries: chartDomesticSilverBuy,
                    rightSeries: chartWorldSilver,
                    bars: List.generate(chartDomesticSilverBuy.length, (i) {
                      if (i < chartWorldSilver.length && chartWorldSilver[i] > 0) return chartDomesticSilverBuy[i] - chartWorldSilver[i];
                      return 0.0;
                    }),
                    dates: marketState.silverHistory.map((s) => s.at).toList(),
                    leftLabel: 'Phu Quy Silver (VND/kg)',
                    rightLabel: 'Spot Silver (VND/kg, converted)',
                    barLabel: 'Domestic Premium (VND/Kg)',
                    isLoading: marketState.isLoading,
                    emptyText: 'No silver history points available yet.',
                  ),
                  const SizedBox(height: 16),
                  if (vnSilverBase != null || worldSilverVnd > 0) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text('Live Buy / Sell Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              _RangeToggles(
                                selected: marketState.selectedRange,
                                onChanged: (val) => context.read<PublicMarketCubit>().load(range: val),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          MarketBuySellChart(
                            buySeries: chartDomesticSilverBuy,
                            sellSeries: chartDomesticSilverSell,
                            dates: marketState.silverHistory.map((s) => s.at).toList(),
                            label: 'Phu Quy Silver Buy / Sell Live',
                            unitLabel: 'VND',
                            isLoading: marketState.isLoading,
                            emptyText: 'No silver price history from API yet.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else if (_tabIndex == 2) ...[
                  // Foreign Currency Tab
                  if (usdToVnd > 0) ...[
                    const Text('MARKET INSIGHT BOARD', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.black54, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('FX: USD/VND Trend Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                    const SizedBox(height: 16),
                    MarketMetricCards(
                      metrics: buildForexMetrics(
                        latestRate: usdToVnd,
                        weeklyChange: currencyPriceChange,
                        sessionRange: chartCurrency.isNotEmpty ? (chartCurrency.reduce((a, b) => a > b ? a : b) - chartCurrency.where((c) => c > 0).reduce((a, b) => a < b ? a : b)) : 0.0,
                        domesticChange: currencyPriceChange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MarketChartPanel(
                      topWidget: _RangeToggles(
                        selected: marketState.selectedRange,
                        onChanged: (val) => context.read<PublicMarketCubit>().load(range: val),
                      ),
                      leftSeries: chartCurrency,
                      rightSeries: const [],
                      bars: List.generate(chartCurrency.length, (i) => i.toDouble()), // Mock bars for FX momentum
                      dates: marketState.currencyHistory.map((s) => s.at).toList(),
                      leftLabel: 'USD/VND',
                      rightLabel: '',
                      barLabel: 'FX Momentum (%)',
                      isLoading: marketState.isLoading,
                      emptyText: 'No API FX history available yet.',
                    ),
                    SizedBox(height: 16.h),
                    if (chartCurrency.isNotEmpty && chartCurrency.any((e) => e > 0)) ...[
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Live Buy / Sell Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                _RangeToggles(
                                  selected: marketState.selectedRange,
                                  onChanged: (val) => context.read<PublicMarketCubit>().load(range: val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            MarketBuySellChart(
                              buySeries: chartCurrency,
                              sellSeries: const [],
                              dates: marketState.currencyHistory.map((s) => s.at).toList(),
                              label: 'USD/VND Live Price Structure',
                              unitLabel: 'VND',
                              isLoading: marketState.isLoading,
                              emptyText: 'No FX history from API yet.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ],
                  _CurrencyConverter(usdToVnd: usdToVnd),
                  SizedBox(height: 12.h),
                ] else if (_tabIndex == 3) ...[
                  // â”€â”€ News & Insights tab (FE: News.jsx) â”€â”€
                  const _MarketNewsSection(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _getDelta(List<double> series) {
    if (series.length < 2) return 0.0;
    final curr = series.last;
    final prev = series[series.length - 2];
    if (prev == 0) return 0.0;
    return ((curr - prev) / prev) * 100;
  }

  double _calcCorrelation(List<double> s1, List<double> s2) {
    final n = min(s1.length, s2.length);
    if (n < 2) return 0.0;

    double sum1 = 0, sum2 = 0, sum1Sq = 0, sum2Sq = 0, sumP = 0;
    for (int i = 0; i < n; i++) {
      final x = s1[s1.length - n + i];
      final y = s2[s2.length - n + i];
      sum1 += x;
      sum2 += y;
      sum1Sq += x * x;
      sum2Sq += y * y;
      sumP += x * y;
    }

    final num = double.parse((n * sumP - sum1 * sum2).toStringAsFixed(10));
    final den = sqrt((n * sum1Sq - sum1 * sum1) * (n * sum2Sq - sum2 * sum2));

    if (den == 0) return 0.0;
    return num / den;
  }
}

class _MarketTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _MarketTabs({required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderTab(
          label: 'Gold',
          isActive: currentIndex == 0,
          onTap: () => onChanged(0),
        ),
        _HeaderTab(
          label: 'Silver',
          isActive: currentIndex == 1,
          onTap: () => onChanged(1),
        ),
        _HeaderTab(
          label: 'FX',
          isActive: currentIndex == 2,
          onTap: () => onChanged(2),
        ),
        _HeaderTab(
          label: 'News',
          isActive: currentIndex == 3,
          onTap: () => onChanged(3),
        ),
      ],
    );
  }
}

class _HeaderTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _HeaderTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(right: 14.w, top: 10.h, bottom: 8.h),
        decoration: BoxDecoration(
          border:
              isActive
                  ? Border(bottom: BorderSide(color: Colors.white, width: 3))
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white.withOpacity(isActive ? 1 : 0.7),
          ),
        ),
      ),
    );
  }
}


List<double> _safeSeries(List<double> raw) {
  if (raw.length >= 2) return raw;
  if (raw.length == 1) return [raw.first, raw.first];
  return const [0.0, 0.0];
}

class _CurrencyConverter extends StatefulWidget {
  final double usdToVnd;

  const _CurrencyConverter({required this.usdToVnd});

  @override
  State<_CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<_CurrencyConverter> {
  final _controller = TextEditingController();
  bool _isVndToUsd = true; // true = VND â†’ USD, false = USD â†’ VND
  double _result = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _convert() {
    final rawText = _controller.text.replaceAll('.', '').replaceAll(',', '');
    final input = double.tryParse(rawText) ?? 0;
    if (widget.usdToVnd <= 0) {
      setState(() => _result = 0);
      return;
    }

    setState(() {
      if (_isVndToUsd) {
        // VND â†’ USD (input omits 3 zeros, multiply by 1000 to get actual value)
        final actualVnd = input * 1000;
        _result = actualVnd / widget.usdToVnd;
      } else {
        // USD â†’ VND
        _result = input * widget.usdToVnd;
      }
    });
  }

  void _swap() {
    setState(() {
      _isVndToUsd = !_isVndToUsd;
      _result = 0;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0.00', 'en_US');
    final fromCurrency = _isVndToUsd ? 'VND' : 'USD';
    final toCurrency = _isVndToUsd ? 'USD' : 'VND';
    final hintText = _isVndToUsd ? 'EX: 10.000 = 10 Millions VND' : 'EX: 1000';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Currency Converter',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: _swap,
                icon: Icon(
                  Icons.swap_horiz,
                  color: AppColors.primary,
                  size: 24.w,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'From $fromCurrency${_isVndToUsd ? ' (Unit: thousand)' : ''}',
            style: TextStyle(fontSize: 10.sp, color: Colors.black54),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorInputFormatter(),
            ],
            onChanged: (_) => _convert(),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 11.sp, color: Colors.black38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
            ),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To $toCurrency',
                  style: TextStyle(fontSize: 10.sp, color: Colors.black54),
                ),
                SizedBox(height: 6.h),
                Text(
                  _result == 0 ? '--' : nf.format(_result),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Clear all old separators
    final rawText = newValue.text.replaceAll(',', '');

    // Add comma separator every 3 digits from right to left
    final buffer = StringBuffer();
    for (int i = 0; i < rawText.length; i++) {
      if (i > 0 && (rawText.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(rawText[i]);
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _RangeToggles extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _RangeToggles({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ranges = [
      {'label': '1 Week', 'val': '1w'},
      {'label': '1 Month', 'val': '1m'},
      {'label': '6 Months', 'val': '6m'},
      {'label': '1 Year', 'val': '1y'},
    ];

    return Row(
      children:
          ranges.map((r) {
            final isActive = selected == r['val'];
            return GestureDetector(
              onTap: () => onChanged(r['val']!),
              child: Container(
                margin: EdgeInsets.only(right: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFF0FBFF) : Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isActive ? const Color(0xFF06B6D4) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  r['label']!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? const Color(0xFF0369A1) : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}



/// News & Market Insights Section â€” mirrors FE's News.jsx
class _MarketNewsSection extends StatefulWidget {
  const _MarketNewsSection();

  @override
  State<_MarketNewsSection> createState() => _MarketNewsSectionState();
}

class _MarketNewsSectionState extends State<_MarketNewsSection> {
  String _selectedCategory = "All";
  String _search = "";
  int _page = 0;
  static const _pageSize = 8;

  List<NewsArticle> get _filtered {
    return newsData.where((a) {
      final catMatch = _selectedCategory == "All" || a.category == _selectedCategory;
      final q = _search.toLowerCase();
      final textMatch = q.isEmpty || a.title.toLowerCase().contains(q) || a.summary.toLowerCase().contains(q);
      return catMatch && textMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final paged = filtered.skip(_page * _pageSize).take(_pageSize).toList();
    final totalPages = (filtered.length / _pageSize).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text("Market News & Insights", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800)),
        SizedBox(height: 4.h),
        Text("Latest news from Reuters and Investing.com on Gold, Silver, Exchange Rates & Oil", style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
        SizedBox(height: 16.h),
        Container(
          height: 44.h,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFDDD6CC)), borderRadius: BorderRadius.circular(10.r)),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(children: [
            const Icon(Icons.search, size: 18, color: Colors.black38),
            SizedBox(width: 8.w),
            Expanded(child: TextField(
              onChanged: (v) => setState(() { _search = v; _page = 0; }),
              decoration: InputDecoration(border: InputBorder.none, hintText: "Search news...", hintStyle: TextStyle(fontSize: 13.sp, color: Colors.black38), isCollapsed: true),
              style: TextStyle(fontSize: 13.sp),
            )),
          ]),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: newsCategories.map((cat) {
            final active = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() { _selectedCategory = cat; _page = 0; }),
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF2C1F0E) : Colors.white,
                  border: Border.all(color: active ? const Color(0xFF2C1F0E) : const Color(0xFFDDD6CC)),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(cat, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: active ? Colors.white : Colors.black87)),
              ),
            );
          }).toList()),
        ),
        SizedBox(height: 16.h),
        if (paged.isEmpty)
          Padding(padding: EdgeInsets.symmetric(vertical: 32.h), child: Center(child: Text("No articles found.", style: TextStyle(fontSize: 13.sp, color: Colors.black45))))
        else
          ...paged.map((a) => _NewsCard(article: a)),
        if (totalPages > 1) ...[
          SizedBox(height: 8.h),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: _page > 0 ? () => setState(() => _page--) : null, icon: const Icon(Icons.chevron_left)),
            Text("${_page + 1} / $totalPages", style: TextStyle(fontSize: 13.sp)),
            IconButton(onPressed: _page < totalPages - 1 ? () => setState(() => _page++) : null, icon: const Icon(Icons.chevron_right)),
          ]),
        ],
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  const _NewsCard({required this.article});

  static const _catBg = {"Gold": Color(0xFFFEF9C3), "Silver": Color(0xFFF1F5F9), "Exchange Rate": Color(0xFFEFF6FF), "Oil": Color(0xFFFEF3C7)};
  static const _catFg = {"Gold": Color(0xFF854D0E), "Silver": Color(0xFF334155), "Exchange Rate": Color(0xFF1E40AF), "Oil": Color(0xFF92400E)};

  @override
  Widget build(BuildContext context) {
    final bg = _catBg[article.category] ?? const Color(0xFFF8F8F6);
    final fg = _catFg[article.category] ?? Colors.black87;
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(article.link, maxLines: 2, overflow: TextOverflow.ellipsis))),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFEEE8DF)), borderRadius: BorderRadius.circular(14.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
            child: Container(
              height: 100.h,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFF4A3B2A).withOpacity(0.85), const Color(0xFF2C1F0E).withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Center(child: Text(article.category == "Gold" ? "â—ˆ" : article.category == "Silver" ? "â—‡" : article.category == "Oil" ? "â›½" : "\$", style: const TextStyle(fontSize: 40, color: Colors.white70))),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6.r)), child: Text(article.category, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: fg))),
                const Spacer(),
                Text(article.date, style: TextStyle(fontSize: 10.sp, color: Colors.black38)),
                if (article.readTime != null) Text(" Â· ${article.readTime}", style: TextStyle(fontSize: 10.sp, color: Colors.black38)),
              ]),
              SizedBox(height: 8.h),
              Text(article.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.black, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 6.h),
              Text(article.summary, style: TextStyle(fontSize: 12.sp, color: Colors.black54, height: 1.6), maxLines: 3, overflow: TextOverflow.ellipsis),
              SizedBox(height: 10.h),
              Row(children: [
                Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6.r)), child: Text(article.source, style: TextStyle(fontSize: 10.sp, color: Colors.black54, fontWeight: FontWeight.w600))),
                SizedBox(width: 8.w),
                Expanded(child: Text("by ${article.author}", style: TextStyle(fontSize: 10.sp, color: Colors.black38), overflow: TextOverflow.ellipsis)),
                Text("Read â†’", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2C1F0E))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
