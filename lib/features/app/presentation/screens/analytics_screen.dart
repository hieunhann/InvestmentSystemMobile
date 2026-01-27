import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';
import 'package:my_flutter_app/fake_data/fake_analytics_data.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/constants/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final vertical = (size.height * 0.02).clamp(12.0, 18.0);
    final nf = NumberFormat('#,##0', 'vi_VN');

    return Column(
      children: [
        AppHeader(
          title: 'Analytics',
          subtitle: 'Portfolio Performance',
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical),
              children: [
                // Tổng quan
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Portfolio Overview', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              label: 'Total Value',
                              value: '${nf.format(FakeAnalyticsData.totalValue)} VND',
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _StatItem(
                              label: 'Total Cost',
                              value: '${nf.format(FakeAnalyticsData.totalCost)} VND',
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              label: 'Profit',
                              value: '${nf.format(FakeAnalyticsData.totalProfit)} VND',
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _StatItem(
                              label: 'Profit %',
                              value: '+${FakeAnalyticsData.profitPercent}%',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Asset Allocation
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Asset Allocation', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                      SizedBox(height: 12.h),
                      ...FakeAnalyticsData.assetAllocation.map((asset) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: Color(asset.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                asset.type,
                                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${asset.percent}%',
                              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              nf.format(asset.value),
                              style: TextStyle(fontSize: 10.sp, color: Colors.black54),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Top Assets
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Performing Assets', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                      SizedBox(height: 12.h),
                      ...FakeAnalyticsData.topAssets.map((asset) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(asset.name, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700)),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${nf.format(asset.buyPrice)} → ${nf.format(asset.currentPrice)}',
                                    style: TextStyle(fontSize: 9.sp, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '+${nf.format(asset.profit)}',
                                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.green),
                                ),
                                Text(
                                  '+${asset.profitPercent}%',
                                  style: TextStyle(fontSize: 9.sp, color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Transactions Stats
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction Statistics', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              label: 'Total Transactions',
                              value: '${FakeAnalyticsData.totalTransactions}',
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _StatItem(
                              label: 'Buy / Sell',
                              value: '${FakeAnalyticsData.buyTransactions} / ${FakeAnalyticsData.sellTransactions}',
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.black54),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
