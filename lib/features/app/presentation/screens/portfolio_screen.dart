import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/features/app/bloc/portfolio_cubit.dart';
import 'package:my_flutter_app/features/app/bloc/public_market_cubit.dart';
import 'package:my_flutter_app/features/app/presentation/screens/record_transaction_screen.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String _displayCurrency = 'USD';

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  double _convertAmount({
    required double amount,
    required String sourceCurrency,
    required String targetCurrency,
    required double usdToVnd,
  }) {
    final from = sourceCurrency.toUpperCase();
    final to = targetCurrency.toUpperCase();
    if (from == to || amount == 0) return amount;
    if (usdToVnd <= 0) return amount;

    if (from == 'USD' && to == 'VND') return amount * usdToVnd;
    if (from == 'VND' && to == 'USD') return amount / usdToVnd;
    return amount;
  }

  String _formatMoney(double value, String currency) {
    final symbol = currency == 'USD' ? '\$' : 'VND ';
    return '$symbol${NumberFormat(currency == 'USD' ? '#,##0.00' : '#,##0').format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final marketState = context.watch<PublicMarketCubit>().state;
    final username = authState.user?.orgName;
    final userId = authState.user?.id ?? '';
    final usdToVnd = marketState.usdToVnd;
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final vertical = (size.height * 0.02).clamp(12.0, 18.0);

    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        final holdings = state.holdings;
        final totalProfitLoss = holdings.fold<double>(0, (sum, item) {
          final map = item as Map<String, dynamic>;
          return sum + _convertAmount(
            amount: _toDouble(map['profitLoss']),
            sourceCurrency: (map['currencyCode'] ?? 'VND').toString(),
            targetCurrency: _displayCurrency,
            usdToVnd: usdToVnd,
          );
        });

        return Column(
          children: [
            AppHeader(
              title: 'Portfolio',
              subtitle: 'Manage your assets',
              username: username,
              trailing: IconButton(
                onPressed:
                    userId.isEmpty
                        ? null
                        : () => context.read<PortfolioCubit>().load(userId: userId),
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ),
            if (state.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<PortfolioCubit>().load(userId: userId),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      vertical,
                      horizontal,
                      vertical,
                    ),
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          _CurrencyToggle(
                            selected: _displayCurrency,
                            onChanged: (value) => setState(() => _displayCurrency = value),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Profit/Loss',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${totalProfitLoss >= 0 ? '+' : ''}${_formatMoney(totalProfitLoss.abs(), _displayCurrency)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color:
                                    totalProfitLoss >= 0
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${state.totalProfitLossPercentage >= 0 ? '+' : ''}${state.totalProfitLossPercentage.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color:
                                    state.totalProfitLossPercentage >= 0
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Holdings',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              final portfolioCubit =
                                  context.read<PortfolioCubit>();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => BlocProvider.value(
                                        value: portfolioCubit,
                                        child: const RecordTransactionScreen(),
                                      ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 24.w,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      if (state.holdings.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.wallet_outlined,
                                  size: 64.w,
                                  color: Colors.black12,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No holdings yet',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black38,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                TextButton(
                                  onPressed: () {
                                    final portfolioCubit =
                                        context.read<PortfolioCubit>();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => BlocProvider.value(
                                              value: portfolioCubit,
                                              child:
                                                  const RecordTransactionScreen(),
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Add your first transaction',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...holdings
                            .map(
                              (h) => _HoldingItem(
                                data: h,
                                userId: userId,
                                displayCurrency: _displayCurrency,
                                usdToVnd: usdToVnd,
                              ),
                            )
                            .toList(),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CurrencyToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CurrencyToggleButton(
            label: 'VND',
            isSelected: selected == 'VND',
            onTap: () => onChanged('VND'),
          ),
          SizedBox(width: 4.w),
          _CurrencyToggleButton(
            label: 'USD',
            isSelected: selected == 'USD',
            onTap: () => onChanged('USD'),
          ),
        ],
      ),
    );
  }
}

class _CurrencyToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primary : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _HoldingItem extends StatelessWidget {
  final dynamic data;
  final String userId;
  final String displayCurrency;
  final double usdToVnd;
  const _HoldingItem({
    required this.data,
    required this.userId,
    required this.displayCurrency,
    required this.usdToVnd,
  });

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  double _convertAmount(double amount, String sourceCurrency) {
    final from = sourceCurrency.toUpperCase();
    if (from == displayCurrency || amount == 0) return amount;
    if (usdToVnd <= 0) return amount;
    if (from == 'USD' && displayCurrency == 'VND') return amount * usdToVnd;
    if (from == 'VND' && displayCurrency == 'USD') return amount / usdToVnd;
    return amount;
  }

  String _formatMoney(double value) {
    if (displayCurrency == 'USD') {
      return '\$${NumberFormat('#,##0.00').format(value)}';
    }
    return 'VND ${NumberFormat('#,##0').format(value)}';
  }

  String _displayAssetName(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('gold')) return 'SJC Gold';
    if (v.contains('silver')) return 'Phu Quy Silver';
    return raw;
  }

  String _displayUnit(String raw) {
    final v = raw.toLowerCase();
    if (v == 'chỉ' || v == 'chi') return 'Chi';
    if (v == 'lượng' || v == 'luong' || v == 'tael') return 'Luong';
    if (v == 'kg') return 'Kg';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final rawName = data['assetName'] as String? ?? 'Asset';
    final name = _displayAssetName(rawName);
    final quantity = (data['quantity'] as num?)?.toDouble() ?? 0.0;
    final unit = _displayUnit(data['unitSymbol'] as String? ?? '');
    final sourceCurrency = (data['currencyCode'] ?? 'VND').toString();
    final avgCost =
      (data['entryPrice'] as num?)?.toDouble() ??
      (data['avgCost'] as num?)?.toDouble() ??
      (data['averageCost'] as num?)?.toDouble() ??
      (data['avgEntryPrice'] as num?)?.toDouble() ??
      0.0;
    final currentValue = _toDouble(data['marketValue']);
    final profitLoss = _toDouble(data['profitLoss']);
    final profitLossPercent =
        (data['profitLossPercentage'] as num?)?.toDouble() ?? 0.0;
    final displayAvgCost = _convertAmount(avgCost, sourceCurrency);
    final displayCurrentValue = _convertAmount(currentValue, sourceCurrency);
    final displayProfitLoss = _convertAmount(profitLoss, sourceCurrency);

    return Dismissible(
      key: Key((data['portfolioId'] ?? '${rawName}_${unit}_${quantity}').toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (userId.isEmpty) return;
        final asset = rawName.toLowerCase().contains('silver') ? 'Silver' : 'Gold';
        context.read<PortfolioCubit>().deleteAsset(userId: userId, assetName: asset);
      },
      child: GestureDetector(
        onTap: () {
          final portfolioCubit = context.read<PortfolioCubit>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => BlocProvider.value(
                    value: portfolioCubit,
                    child: RecordTransactionScreen(initialData: data),
                  ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: AppCard(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    rawName.toLowerCase().contains('gold')
                        ? Icons.stars
                        : Icons.circle,
                    color:
                        rawName.toLowerCase().contains('gold')
                            ? Colors.amber
                            : Colors.blueGrey,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${quantity.toStringAsFixed(2)} $unit',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Market Value: ${_formatMoney(displayCurrentValue)}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Avg. Cost',
                      style: TextStyle(fontSize: 9.sp, color: Colors.black54),
                    ),
                    Text(
                      _formatMoney(displayAvgCost),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${displayProfitLoss >= 0 ? '+' : ''}${_formatMoney(displayProfitLoss.abs())}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: displayProfitLoss >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      '${profitLossPercent >= 0 ? '+' : ''}${profitLossPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: profitLoss >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
