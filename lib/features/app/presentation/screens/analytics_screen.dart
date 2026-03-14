import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/app/bloc/analytics_cubit.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final username = authState.user?.orgName;
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final vertical = (size.height * 0.02).clamp(12.0, 18.0);

    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        return Column(
          children: [
            AppHeader(
              title: 'Analytics',
              subtitle: 'Asset Insights',
              username: username,
              trailing: IconButton(
                onPressed: () => context.read<AnalyticsCubit>().load(),
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ),
            Expanded(
              child:
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null
                      ? Center(child: Text('Error: ${state.error}'))
                      : ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          vertical,
                          horizontal,
                          vertical,
                        ),
                        children: [
                          _buildAllocationCard(state.allocation),
                          SizedBox(height: 16.h),
                          _buildInsightsCard(state.allocation),
                        ],
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllocationCard(Map<String, double> allocation) {
    if (allocation.isEmpty) {
      return AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Text(
              'No asset data available.',
              style: TextStyle(fontSize: 12.sp, color: Colors.black54),
            ),
          ),
        ),
      );
    }

    final List<PieChartSectionData> sections = [];
    final List<String> keys = allocation.keys.toList();
    final List<Color> colors = [
      AppColors.primaryVariant,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
    ];

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final value = allocation[key]!;
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: value,
          title: '${value.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Allocation',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: List.generate(keys.length, (i) {
              String displayKey = keys[i];

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    displayKey,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(Map<String, double> allocation) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Insights',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),
          _insightRow(
            'Risk Profile',
            allocation.containsKey('Gold') ? 'Conservative' : 'Moderate',
          ),
          _insightRow(
            'Diversification',
            allocation.length > 1 ? 'Healthy' : 'Low',
          ),
          _insightRow(
            'Primary Asset',
            allocation.isEmpty
                ? 'N/A'
                : (allocation.entries
                    .reduce((a, b) => a.value > b.value ? a : b)
                    .key),
          ),
        ],
      ),
    );
  }

  Widget _insightRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
          Text(
            value,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
