import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/app/bloc/public_market_cubit.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/simple_line_chart.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';

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
  String _goldPriceType = 'domestic'; // 'domestic' or 'world'
  String _silverPriceType = 'domestic'; // 'domestic' or 'world'

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
    final worldGoldUsd = marketState.international?.goldPrice ?? 0.0;
    final worldSilverUsd = marketState.international?.silverPrice ?? 0.0;
    final worldGoldVnd =
        usdToVnd > 0
            ? (marketState.international?.goldPricePerOzInVND(usdToVnd) ?? 0.0)
            : 0.0;
    final worldSilverVnd =
        usdToVnd > 0
            ? (marketState.international?.silverPricePerOzInVND(usdToVnd) ??
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

    final domesticPriceChange =
        chartDomesticSell.length >= 2
            ? ((chartDomesticSell.last -
                        chartDomesticSell[chartDomesticSell.length - 2]) /
                    chartDomesticSell[chartDomesticSell.length - 2]) *
                100
            : 0.0;
    final worldPriceChange =
        chartWorld.length >= 2
            ? ((chartWorld.last - chartWorld[chartWorld.length - 2]) /
                    chartWorld[chartWorld.length - 2]) *
                100
            : 0.0;

    final domesticSilverPriceChange =
        chartDomesticSilverSell.length >= 2
            ? ((chartDomesticSilverSell.last -
                        chartDomesticSilverSell[chartDomesticSilverSell.length -
                            2]) /
                    chartDomesticSilverSell[chartDomesticSilverSell.length -
                        2]) *
                100
            : 0.0;
    final worldSilverPriceChange =
        chartWorldSilver.length >= 2
            ? ((chartWorldSilver.last -
                        chartWorldSilver[chartWorldSilver.length - 2]) /
                    chartWorldSilver[chartWorldSilver.length - 2]) *
                100
            : 0.0;

    final spreadGap = ((sjc?.sellPrice ?? 0) - worldGoldVnd).abs();
    final spreadRisk =
        spreadGap > 1500000 ? 'High' : (spreadGap > 500000 ? 'Medium' : 'Low');

    final silverSpreadGap =
        ((vnSilverBase?.sellPrice ?? 0) - worldSilverVnd).abs();
    final silverSpreadRisk = silverSpreadGap > 1000000 ? 'High' : 'Low';

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
                  _DomesticCard(
                    domesticSellPrice: sjc?.sellPrice ?? 0,
                    domesticBuyPrice: sjc?.buyPrice ?? 0,
                    domesticPriceChange: domesticPriceChange,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _WorldCard(
                          metalType: 'gold',
                          usdPrice: worldGoldUsd,
                          vndPrice: worldGoldVnd,
                          worldPriceChange: worldPriceChange,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _SpreadCard(gap: spreadGap, risk: spreadRisk),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price Trend',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            _RangeToggles(
                              selected: marketState.selectedRange,
                              onChanged: (val) {
                                context.read<PublicMarketCubit>().load(
                                  range: val,
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        _PriceTypeToggle(
                          selectedType: _goldPriceType,
                          onChanged: (type) {
                            setState(() {
                              _goldPriceType = type;
                            });
                          },
                        ),
                        SizedBox(height: 12.h),
                        SimpleLineChart(
                          seriesA:
                              _goldPriceType == 'domestic'
                                  ? chartDomesticBuy
                                  : chartWorld,
                          seriesB:
                              _goldPriceType == 'domestic'
                                  ? chartDomesticSell
                                  : const [],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendDot(
                              color: const Color(0xFF1976D2),
                              label:
                                  _goldPriceType == 'domestic'
                                      ? 'Buy Price'
                                      : 'International',
                            ),
                            if (_goldPriceType == 'domestic') ...[
                              SizedBox(width: 16.w),
                              _LegendDot(
                                color: const Color(0xFFE53935),
                                label: 'Sell Price',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SmallTab(label: 'Product', isActive: true),
                            _SmallTab(label: 'Buy', isActive: false),
                            _SmallTab(label: 'Sell', isActive: false),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        if (vietnamPrices.isEmpty)
                          Text(
                            'No market rows from API.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black54,
                            ),
                          )
                        else
                          ...vietnamPrices.map(
                            (p) => _VietnamProductRow(price: p),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                ] else if (_tabIndex == 1) ...[
                  // Silver Tab
                  _DomesticCard(
                    domesticSellPrice: vnSilverBase?.sellPrice ?? 0,
                    domesticBuyPrice: vnSilverBase?.buyPrice ?? 0,
                    domesticPriceChange: domesticSilverPriceChange,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _WorldCard(
                          metalType: 'silver',
                          usdPrice: worldSilverUsd,
                          vndPrice: worldSilverVnd,
                          worldPriceChange: worldSilverPriceChange,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _SpreadCard(
                          gap: silverSpreadGap,
                          risk: silverSpreadRisk,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (vnSilverBase != null || worldSilverVnd > 0) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Price Trend',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              _RangeToggles(
                                selected: marketState.selectedRange,
                                onChanged: (val) {
                                  context.read<PublicMarketCubit>().load(
                                    range: val,
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          _PriceTypeToggle(
                            selectedType: _silverPriceType,
                            onChanged: (type) {
                              setState(() {
                                _silverPriceType = type;
                              });
                            },
                          ),
                          SizedBox(height: 12.h),
                          SimpleLineChart(
                            seriesA:
                                _silverPriceType == 'domestic'
                                    ? chartDomesticSilverBuy
                                    : chartWorldSilver,
                            seriesB:
                                _silverPriceType == 'domestic'
                                    ? chartDomesticSilverSell
                                    : const [],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LegendDot(
                                color: const Color(0xFF1976D2),
                                label:
                                    _silverPriceType == 'domestic'
                                        ? 'Buy Price'
                                        : 'International',
                              ),
                              if (_silverPriceType == 'domestic') ...[
                                SizedBox(width: 16.w),
                                _LegendDot(
                                  color: const Color(0xFFE53935),
                                  label: 'Sell Price',
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SmallTab(label: 'Product', isActive: true),
                            _SmallTab(label: 'Buy', isActive: false),
                            _SmallTab(label: 'Sell', isActive: false),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        if (vietnamSilverPrices.isEmpty)
                          Text(
                            'No market rows from API.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black54,
                            ),
                          )
                        else
                          ...vietnamSilverPrices.map(
                            (p) => _VietnamProductRow(price: p),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                ] else ...[
                  // Foreign Currency Tab
                  if (usdToVnd > 0) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exchange Rate',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                '1 USD = ${NumberFormat('#,##0.00').format(usdToVnd)} VND',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              if (!currencyPriceChange.isNaN)
                                Text(
                                  '${currencyPriceChange >= 0 ? '↑ +' : '↓ '}${currencyPriceChange.abs().toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        currencyPriceChange >= 0
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (chartCurrency.isNotEmpty &&
                        chartCurrency.any((e) => e > 0)) ...[
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'USD Trend',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                _RangeToggles(
                                  selected: marketState.selectedRange,
                                  onChanged: (val) {
                                    context.read<PublicMarketCubit>().load(
                                      range: val,
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            SimpleLineChart(
                              seriesA: chartCurrency,
                              seriesB: const [], // USD only has one series
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ],
                  _CurrencyConverter(usdToVnd: usdToVnd),
                  SizedBox(height: 12.h),
                ],
              ],
            ),
          ),
        ),
      ],
    );
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
          label: 'Foreign Currency',
          isActive: currentIndex == 2,
          onTap: () => onChanged(2),
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

class _DomesticCard extends StatelessWidget {
  final double domesticSellPrice;
  final double domesticBuyPrice;
  final double domesticPriceChange;

  const _DomesticCard({
    required this.domesticSellPrice,
    required this.domesticBuyPrice,
    required this.domesticPriceChange,
  });

  String _formatVND(double value) {
    final str = value.toInt().toString();
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regex, (match) => '${match[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Domestic Price',
            style: TextStyle(fontSize: 10.sp, color: Colors.black54),
          ),
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: '${_formatVND(domesticSellPrice)} VND'),
                TextSpan(
                  text: '  / Ounce',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                'Buy:',
                style: TextStyle(fontSize: 10.sp, color: Colors.black54),
              ),
              SizedBox(width: 6.w),
              Text(
                '${_formatVND(domesticBuyPrice)} VND',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                'Change',
                style: TextStyle(fontSize: 10.sp, color: Colors.black54),
              ),
              SizedBox(width: 6.w),
              Text(
                '${domesticPriceChange >= 0 ? '↑' : '↓'} ${domesticPriceChange.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  final String metalType;
  final double usdPrice;
  final double vndPrice;
  final double worldPriceChange;

  const _WorldCard({
    this.metalType = 'gold',
    required this.usdPrice,
    required this.vndPrice,
    required this.worldPriceChange,
  });

  String _formatVND(double value) {
    final str = value.toInt().toString();
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regex, (match) => '${match[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final label = metalType == 'silver' ? 'Silver Price' : 'Gold Price';
    final usd = usdPrice;
    final vnd = vndPrice;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: '${usd.toStringAsFixed(2)} USD'),
                TextSpan(
                  text: ' / Ounce',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                'Approx:',
                style: TextStyle(fontSize: 10.sp, color: Colors.black45),
              ),
              SizedBox(width: 4.w),
              Text(
                '${_formatVND(vnd)} VND',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                'Change',
                style: TextStyle(fontSize: 10.sp, color: Colors.black54),
              ),
              SizedBox(width: 4.w),
              Text(
                '${worldPriceChange >= 0 ? '↑ +' : '↓ '}${worldPriceChange.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpreadCard extends StatelessWidget {
  final double gap;
  final String risk;

  const _SpreadCard({required this.gap, required this.risk});

  String _formatVND(double value) {
    final str = value.toInt().toString();
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regex, (match) => '${match[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPREAD GAP',
                  style: TextStyle(fontSize: 10.sp, color: Colors.black54),
                ),
                SizedBox(height: 6.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(text: '${_formatVND(gap)} VND'),
                      TextSpan(
                        text: ' / Ounce',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Higher than average,\npotential risk',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.black45,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    risk,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.black54)),
      ],
    );
  }
}

class _SmallTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _SmallTab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
        color: isActive ? Colors.black87 : Colors.black45,
      ),
    );
  }
}

class _VietnamProductRow extends StatelessWidget {
  final _MarketPrice price;

  const _VietnamProductRow({required this.price});

  String _formatVND(double value) {
    final str = value.toInt().toString();
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regex, (match) => '${match[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final buy = price.buyPrice;
    final sell = price.sellPrice;
    final spread = (sell - buy).abs();
    final spreadColor =
        spread <= 500000
            ? const Color(0xFF2E7D32)
            : (spread <= 1500000
                ? AppColors.primaryVariant
                : const Color(0xFFE53935));

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.stars,
              size: 16.w,
              color: AppColors.primaryVariant,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price.type,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  price.location,
                  style: TextStyle(fontSize: 9.sp, color: Colors.black45),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatVND(buy)} VND',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(
                    'Spread',
                    style: TextStyle(fontSize: 9.sp, color: Colors.black45),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _formatVND(spread),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: spreadColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 10.w),
          Text(
            '${_formatVND(sell)} VND',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTypeToggle extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _PriceTypeToggle({required this.selectedType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Domestic',
              isSelected: selectedType == 'domestic',
              onTap: () => onChanged('domestic'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _ToggleButton(
              label: 'International',
              isSelected: selectedType == 'world',
              onTap: () => onChanged('world'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : Colors.black54,
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
  bool _isVndToUsd = true; // true = VND → USD, false = USD → VND
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
        // VND → USD (input omits 3 zeros, multiply by 1000 to get actual value)
        final actualVnd = input * 1000;
        _result = actualVnd / widget.usdToVnd;
      } else {
        // USD → VND
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
      {'label': '1W', 'val': '1w'},
      {'label': '1M', 'val': '1m'},
      {'label': '1Y', 'val': '1y'},
    ];

    return Row(
      children:
          ranges.map((r) {
            final isActive = selected == r['val'];
            return GestureDetector(
              onTap: () => onChanged(r['val']!),
              child: Container(
                margin: EdgeInsets.only(left: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.black12,
                  ),
                ),
                child: Text(
                  r['label']!,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : Colors.black45,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
