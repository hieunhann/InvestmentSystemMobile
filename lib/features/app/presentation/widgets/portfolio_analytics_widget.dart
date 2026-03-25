import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/features/app/bloc/portfolio_cubit.dart';
import 'package:my_flutter_app/models/portfolio_report.dart';
import 'package:intl/intl.dart';

/// Replicates the FE's PortfolioAnalytics component — AI-generated report display.
class PortfolioAnalyticsWidget extends StatefulWidget {
  final String userId;
  const PortfolioAnalyticsWidget({super.key, required this.userId});

  @override
  State<PortfolioAnalyticsWidget> createState() => _PortfolioAnalyticsWidgetState();
}

class _PortfolioAnalyticsWidgetState extends State<PortfolioAnalyticsWidget> {
  // Which trading signal is expanded
  int? _expandedSignalIndex;

  @override
  void initState() {
    super.initState();
    // Auto-load last report on first view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PortfolioCubit>().loadReport(userId: widget.userId);
      }
    });
  }

  // --- Helpers ---
  static const _assetColor = {
    'Gold': Color(0xFFFFDA91),
    'Silver': Color(0xFF9FA4AB),
    'USD': Color(0xFF3D3D3D),
  };
  static const _assetIcon = {
    'Gold': '◈',
    'Silver': '◇',
    'USD': '\$',
  };

  Color _badgeColor(String type) {
    switch (type) {
      case 'BUY':  return const Color(0xFF16A34A);
      case 'SELL': return const Color(0xFFDC2626);
      case 'HIGH': return const Color(0xFFDC2626);
      case 'HOLD': return const Color(0xFFD97706);
      default:     return const Color(0xFF64748B);
    }
  }

  Color _badgeBg(String type) {
    switch (type) {
      case 'BUY':  return const Color(0xFFDCFCE7);
      case 'SELL': return const Color(0xFFFEE2E2);
      case 'HIGH': return const Color(0xFFFEE2E2);
      case 'HOLD': return const Color(0xFFFEF3C7);
      default:     return const Color(0xFFF1F5F9);
    }
  }

  String _fmtVND(double v) =>
      NumberFormat('#,##0', 'en_US').format(v.round()) + ' VND';

  String _fmtPct(double v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';

  Widget _badge(String label, String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _badgeBg(type),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: _badgeColor(type),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  // --- Empty state ---
  Widget _emptyState(PortfolioState state) {
    return Column(
      children: [
        SizedBox(height: 32.h),
        Text(
          'Portfolio Analytics',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 24.h),
        const Text('📊', style: TextStyle(fontSize: 52)),
        SizedBox(height: 16.h),
        Text(
          'No analysis report yet',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 280.w,
          child: Text(
            'Click below to let AI analyse your portfolio and generate a full report.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.black54, height: 1.6),
          ),
        ),
        if (state.analyzeError == 'no_portfolio') ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Text(
              'No portfolio found. Please add holdings first.',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF991B1B)),
            ),
          ),
        ],
        if (state.analyzeError == 'generic') ...[
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Text(
              'Something went wrong. Please try again.',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF991B1B)),
            ),
          ),
        ],
        SizedBox(height: 20.h),
        _generateButton(state),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _generateButton(PortfolioState state) {
    return ElevatedButton.icon(
      onPressed: state.isAnalyzing
          ? null
          : () => context.read<PortfolioCubit>().generateAnalysis(userId: widget.userId),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C1F0E),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      icon: state.isAnalyzing
          ? SizedBox(
              width: 14.w, height: 14.w,
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Text('✦', style: TextStyle(fontSize: 14)),
      label: Text(
        state.isAnalyzing ? 'Generating…' : 'Generate new AI Analysis',
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
      ),
    );
  }

  // --- Summary cards row ---
  Widget _summaryGrid(PortfolioReport d) {
    final cards = [
      ('PORTFOLIO VALUE', _fmtVND(d.portfolioValueVnd), 'total value in VND', null),
      ('TOTAL RETURN', _fmtPct(d.totalReturnPct), 'since inception',
          d.totalReturnPct >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
      ('BEST PERFORMER', '${_assetIcon[d.bestPerformer] ?? ''} ${d.bestPerformer}',
          'top return asset', const Color(0xFFD97706)),
      ('DIVERSIFICATION', '${(d.diversificationScore * 100).toStringAsFixed(0)}/100',
          'Low — concentrated', const Color(0xFFD97706)),
      ('ALERTS', '${d.alerts.length}', 'active risk flags', const Color(0xFFF59E0B)),
    ];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: cards.map((c) {
        return SizedBox(
          width: (MediaQuery.sizeOf(context).width - 72.w) / 2,
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEEE8DF)),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.$1, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.black)),
                SizedBox(height: 4.h),
                Text(c.$2, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: c.$4 ?? const Color(0xFF2C1F0E))),
                SizedBox(height: 2.h),
                Text(c.$3, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF99A1AF))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Alerts ---
  Widget _alertBanner(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        border: Border.all(color: const Color(0xFFFED7AA)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          const Text('⚠', style: TextStyle(fontSize: 18, color: Color(0xFFF59E0B))),
          SizedBox(width: 10.w),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF92400E), fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // --- Recommendation cards ---
  Widget _recoCard(TradeRecommendation r) {
    final icon = _assetIcon[r.asset] ?? '?';
    final color = _assetColor[r.asset] ?? Colors.grey;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEE8DF)),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: TextStyle(fontSize: 18, color: color)),
              SizedBox(width: 8.w),
              Text(r.asset, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
              const Spacer(),
              _badge(r.action, r.action),
            ],
          ),
          SizedBox(height: 8.h),
          _badge('Urgency: ${r.urgency}', r.urgency),
          SizedBox(height: 8.h),
          Text(r.rationale, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9B8B7A))),
          SizedBox(height: 8.h),
          Text('Conviction', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9B8B7A))),
          SizedBox(height: 4.h),
          _ConvictionBar(value: r.conviction),
          if (r.sizeHint.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(r.sizeHint, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9B8B7A), fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  // --- Allocation donut placeholder ---
  Widget _allocationSection(PortfolioReport d) {
    return Column(
      children: d.allocation.map((a) {
        final color = _assetColor[a.asset] ?? Colors.grey;
        final pct = (a.weight * 100).toStringAsFixed(1);
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                  SizedBox(width: 8.w),
                  Text(a.asset, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('$pct%', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                ],
              ),
              SizedBox(height: 4.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: a.weight,
                  backgroundColor: const Color(0xFFE8E0D0),
                  color: color,
                  minHeight: 6,
                ),
              ),
              SizedBox(height: 2.h),
              Text('${a.quantity} ${a.unitSymbol}', style: TextStyle(fontSize: 11.sp, color: Colors.black45)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Performance table ---
  Widget _performanceTable(PortfolioReport d) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16.w,
        headingRowHeight: 36.h,
        dataRowMinHeight: 40.h,
        dataRowMaxHeight: 48.h,
        headingTextStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: const Color(0xFF9B8B7A)),
        dataTextStyle: TextStyle(fontSize: 11.sp),
        columns: const [
          DataColumn(label: Text('Asset')),
          DataColumn(label: Text('Entry'), numeric: true),
          DataColumn(label: Text('Current'), numeric: true),
          DataColumn(label: Text('P&L'), numeric: true),
          DataColumn(label: Text('Return'), numeric: true),
        ],
        rows: d.performance.map((p) {
          final pnlColor = p.profitLoss >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
          return DataRow(
            color: WidgetStateProperty.resolveWith<Color?>(
              (s) => p.asset == d.bestPerformer ? const Color(0xFFFFFBEB) : null,
            ),
            cells: [
              DataCell(Text(p.asset, style: const TextStyle(fontWeight: FontWeight.w700))),
              DataCell(Text(NumberFormat('#,##0', 'en_US').format(p.entryPrice.round()))),
              DataCell(Text(NumberFormat('#,##0', 'en_US').format(p.currentPrice.round()))),
              DataCell(Text(_fmtVND(p.profitLoss), style: TextStyle(color: pnlColor, fontWeight: FontWeight.w700))),
              DataCell(Text(_fmtPct(p.returnPct), style: TextStyle(color: pnlColor, fontWeight: FontWeight.w800))),
            ],
          );
        }).toList(),
      ),
    );
  }

  // --- Trading signals ---
  Widget _tradingSignals(PortfolioReport d) {
    return Column(
      children: List.generate(d.tradingSignals.length, (i) {
        final s = d.tradingSignals[i];
        final expanded = _expandedSignalIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _expandedSignalIndex = expanded ? null : i),
          child: Container(
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEE8DF)),
              borderRadius: BorderRadius.circular(12.r),
              color: const Color(0xFFFAFAF8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Text(_assetIcon[s.asset] ?? '?', style: const TextStyle(fontSize: 18)),
                      SizedBox(width: 10.w),
                      Text(s.asset, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8.w),
                      _badge(s.signal, s.signal),
                      const Spacer(),
                      Icon(expanded ? Icons.expand_less : Icons.expand_more, size: 20),
                    ],
                  ),
                ),
                if (expanded && s.explanation.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEEE8DF)),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(s.explanation, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4A3B2A), height: 1.7)),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- Full ready state ---
  Widget _readyState(PortfolioState state, PortfolioReport d) {
    final lastUpdated = d.generatedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(d.generatedAt!.toLocal())
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Portfolio Analytics', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                  if (lastUpdated.isNotEmpty)
                    Text('Last updated: $lastUpdated', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF99A1AF))),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _generateButton(state),
          ],
        ),
        SizedBox(height: 20.h),

        // Alerts
        ...d.alerts.map(_alertBanner),

        // Summary grid
        _summaryGrid(d),
        SizedBox(height: 16.h),

        // Recommendation summary
        _sectionCard(
          title: 'Recommendation Summary',
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text('✓ ${d.recommendationSummary}',
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF166534), fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 14.h),
              ...d.tradeRecommendations.map(_recoCard),
            ],
          ),
        ),

        // Asset allocation
        if (d.allocation.isNotEmpty)
          _sectionCard(title: 'Asset Allocation', child: _allocationSection(d)),

        // Performance table
        if (d.performance.isNotEmpty)
          _sectionCard(title: 'Performance by Asset', child: _performanceTable(d)),

        // Trading signals
        if (d.tradingSignals.isNotEmpty)
          _sectionCard(title: 'Trading Signals', child: _tradingSignals(d)),

        // AI Explanation
        if ((d.explanation ?? '').isNotEmpty)
          _sectionCard(
            title: 'AI Explanation',
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAF8),
                border: Border.all(color: const Color(0xFFEEE8DF)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(d.explanation!, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4A3B2A), height: 1.7)),
            ),
          ),

        SizedBox(height: 32.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        // Loading initial report
        if (!state.reportLoaded) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Column(
              children: [
                Text('Portfolio Analytics', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 16.h),
                const CircularProgressIndicator(),
                SizedBox(height: 12.h),
                Text('Loading your latest report…', style: TextStyle(fontSize: 13.sp, color: Colors.black45)),
              ],
            ),
          );
        }

        if (state.report == null) {
          return _emptyState(state);
        }

        return _readyState(state, state.report!);
      },
    );
  }
}

class _ConvictionBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  const _ConvictionBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    final color = pct > 70 ? const Color(0xFF22C55E) : pct > 50 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE8E0D0),
              color: color,
              minHeight: 5,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text('$pct%', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B5E4A))),
      ],
    );
  }
}
