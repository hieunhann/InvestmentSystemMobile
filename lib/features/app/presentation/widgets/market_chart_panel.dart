import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// FE-matching ChartPanel — mirrors MarketInsightsPage.jsx → ChartPanel
/// Shows dual-axis area lines (cyan domestic, amber international) + bar section (premium/spread)
class MarketChartPanel extends StatefulWidget {
  final List<double> leftSeries;   // domestic prices (VND)
  final List<double> rightSeries;  // international prices (VND, converted)
  final List<double> bars;         // premium = domestic - international
  final List<DateTime> dates;
  final String leftLabel;
  final String rightLabel;
  final String barLabel;
  final bool isLoading;
  final String emptyText;
  final Widget? topWidget;

  const MarketChartPanel({
    super.key,
    required this.leftSeries,
    required this.rightSeries,
    required this.bars,
    required this.dates,
    required this.leftLabel,
    required this.rightLabel,
    required this.barLabel,
    this.isLoading = false,
    this.emptyText = 'No data available from API yet.',
    this.topWidget,
  });

  @override
  State<MarketChartPanel> createState() => _MarketChartPanelState();
}

class _MarketChartPanelState extends State<MarketChartPanel> {
  int? _hoverIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        height: 380,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final hasLeft = widget.leftSeries.any((v) => v.isFinite && v > 0);
    final total = [widget.leftSeries.length, widget.rightSeries.length, widget.bars.length, widget.dates.length]
        .reduce((a, b) => a > b ? a : b);

    if (total < 2 || !hasLeft) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: Text(widget.emptyText, style: const TextStyle(color: Colors.black38, fontSize: 13))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.topWidget != null) ...[
            widget.topWidget!,
            const SizedBox(height: 12),
          ],
          // Legend row — mirrors FE's legend (using Wrap to prevent overflow on small screens)
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              _LegendBubble(color: const Color(0xFF06B6D4), label: widget.leftLabel),
              if (widget.rightSeries.any((v) => v.isFinite && v > 0))
                _LegendBubble(color: const Color(0xFFF59E0B), label: widget.rightLabel),
            ],
          ),
          const SizedBox(height: 12),

          // Main chart area — tap to show tooltip
          GestureDetector(
            onTapDown: (d) => _onTouch(d.localPosition),
            onPanUpdate: (d) => _onTouch(d.localPosition),
            onPanEnd: (_) => setState(() => _hoverIndex = null),
            onTapCancel: () => setState(() => _hoverIndex = null),
            child: SizedBox(
              height: 320,
              child: CustomPaint(
                size: Size.infinite,
                painter: _ChartPanelPainter(
                  leftSeries: widget.leftSeries,
                  rightSeries: widget.rightSeries,
                  bars: widget.bars,
                  dates: widget.dates,
                  hoverIndex: _hoverIndex,
                  barLabel: widget.barLabel,
                  leftLabel: widget.leftLabel,
                ),
              ),
            ),
          ),

          // Tooltip
          if (_hoverIndex != null && _hoverIndex! < widget.leftSeries.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                ),
                child: Wrap(
                  spacing: 12,
                  children: [
                    if (_hoverIndex! < widget.dates.length)
                      Text(DateFormat('MMM d').format(widget.dates[_hoverIndex!]),
                          style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
                    if (widget.leftSeries[_hoverIndex!] > 0)
                      Text('${widget.leftLabel}: ${_compactFmt(widget.leftSeries[_hoverIndex!])}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF0891B2), fontWeight: FontWeight.w600)),
                    if (_hoverIndex! < widget.rightSeries.length && widget.rightSeries[_hoverIndex!] > 0)
                      Text('${widget.rightLabel}: ${_compactFmt(widget.rightSeries[_hoverIndex!])}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                    if (_hoverIndex! < widget.bars.length && widget.bars[_hoverIndex!].isFinite)
                      Text('${widget.barLabel}: ${_compactFmt(widget.bars[_hoverIndex!])}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onTouch(Offset pos) {
    final total = widget.leftSeries.length;
    if (total < 2) return;
    const leftPad = 60.0;
    final w = context.size?.width ?? 300;
    final idx = ((pos.dx - leftPad) / (w - leftPad - 12) * (total - 1)).round().clamp(0, total - 1);
    setState(() => _hoverIndex = idx);
  }
}

class _LegendBubble extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendBubble({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }
}

String _compactFmt(double v) {
  if (!v.isFinite) return '—';
  if (v.abs() >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
  if (v.abs() >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
  if (v.abs() >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
  return v.toStringAsFixed(0);
}

/// CustomPainter for the ChartPanel — dual Y-axis area chart + bar chart
class _ChartPanelPainter extends CustomPainter {
  final List<double> leftSeries;
  final List<double> rightSeries;
  final List<double> bars;
  final List<DateTime> dates;
  final int? hoverIndex;
  final String barLabel;
  final String leftLabel;

  _ChartPanelPainter({
    required this.leftSeries,
    required this.rightSeries,
    required this.bars,
    required this.dates,
    required this.barLabel,
    required this.leftLabel,
    this.hoverIndex,
  });

  static const _leftPad = 60.0;
  static const _rightPad = 60.0;
  static const _topPad = 8.0;
  static const _lineChartH = 180.0;
  static const _barGap = 32.0;
  static const _barH = 72.0;

  @override
  void paint(Canvas canvas, Size size) {
    final total = [leftSeries.length, rightSeries.length, bars.length].reduce((a, b) => a > b ? a : b);
    if (total < 2) return;

    final plotW = size.width - _leftPad - _rightPad;
    final lineBottom = _topPad + _lineChartH;
    final barTop = lineBottom + _barGap;
    final barBottom = barTop + _barH;

    final leftFinite = leftSeries.where((v) => v.isFinite && v > 0).toList();
    final rightFinite = rightSeries.where((v) => v.isFinite && v > 0).toList();

    // ── Value ranges ──
    double _pad(double min, double max) {
      final span = (max - min).abs();
      return span > 0 ? span * 0.12 : (min * 0.05).abs();
    }

    final lMin = leftFinite.isEmpty ? 0.0 : leftFinite.reduce((a, b) => a < b ? a : b);
    final lMax = leftFinite.isEmpty ? 1.0 : leftFinite.reduce((a, b) => a > b ? a : b);
    final lPad = _pad(lMin, lMax);
    final yLMin = lMin - lPad;
    final yLMax = lMax + lPad;
    final yLSpan = (yLMax - yLMin).abs();

    final rMin = rightFinite.isEmpty ? yLMin : rightFinite.reduce((a, b) => a < b ? a : b);
    final rMax = rightFinite.isEmpty ? yLMax : rightFinite.reduce((a, b) => a > b ? a : b);
    final rPad = _pad(rMin, rMax);
    final yRMin = rMin - rPad;
    final yRMax = rMax + rPad;
    final yRSpan = (yRMax - yRMin).abs();

    final barFinite = bars.where((v) => v.isFinite).toList();
    final barMin = barFinite.isEmpty ? 0.0 : [0.0, ...barFinite].reduce((a, b) => a < b ? a : b);
    final barMax = barFinite.isEmpty ? 1.0 : [0.0, ...barFinite].reduce((a, b) => a > b ? a : b);
    final barSpan = (barMax - barMin).abs();
    final effectiveBarSpan = barSpan > 0 ? barSpan : 1.0;

    // ── Scale helpers ──
    double scaleX(int i) => _leftPad + i * plotW / (total - 1);
    double scaleL(double v) => lineBottom - (v - yLMin) / (yLSpan > 0 ? yLSpan : 1) * _lineChartH;
    double scaleR(double v) => lineBottom - (v - yRMin) / (yRSpan > 0 ? yRSpan : 1) * _lineChartH;
    double zeroBar = barBottom - (0 - barMin) / effectiveBarSpan * _barH;
    double scaleBar(double v) => barBottom - (v - barMin) / effectiveBarSpan * _barH;

    final gridPaint = Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 1;
    final labelStyle = const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w500);

    // ── Grid lines + Y-axis labels ──
    for (int g = 0; g <= 4; g++) {
      final y = _topPad + g * _lineChartH / 4;
      canvas.drawLine(Offset(_leftPad, y), Offset(size.width - _rightPad, y), gridPaint);

      // Left label
      final lv = yLMax - (yLMax - yLMin) * g / 4;
      _drawText(canvas, _compactFmt(lv), Offset(_leftPad - 4, y), labelStyle, align: _TextAlign.right);

      // Right label (if rightSeries has data)
      if (rightFinite.isNotEmpty) {
        final rv = yRMax - (yRMax - yRMin) * g / 4;
        _drawText(canvas, _compactFmt(rv), Offset(size.width - _rightPad + 4, y), labelStyle, align: _TextAlign.left);
      }
    }

    // Border rect
    canvas.drawRect(
      Rect.fromLTWH(_leftPad, _topPad, plotW, _lineChartH),
      Paint()..color = const Color(0xFFE2E8F0)..style = PaintingStyle.stroke,
    );

    // ── Area fills ──
    if (leftFinite.isNotEmpty) {
      _drawArea(canvas, leftSeries, scaleX, scaleL, lineBottom, const Color(0xFF0EA5E9), 0.22, 0.02, _leftPad);
    }
    if (rightFinite.isNotEmpty) {
      _drawArea(canvas, rightSeries, scaleX, scaleR, lineBottom, const Color(0xFFF59E0B), 0.20, 0.02, _leftPad);
    }

    // ── Lines ──
    if (leftFinite.isNotEmpty) {
      _drawLine(canvas, leftSeries, scaleX, scaleL, const Color(0xFF06B6D4), 2.2);
    }
    if (rightFinite.isNotEmpty) {
      _drawLine(canvas, rightSeries, scaleX, scaleR, const Color(0xFFF59E0B), 2.2);
    }

    // ── Bar chart section ──
    // Bar label
    _drawText(canvas, barLabel, Offset(_leftPad, barTop - 16), labelStyle.copyWith(color: const Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.w600), align: _TextAlign.left);

    // Zero line
    canvas.drawLine(Offset(_leftPad, zeroBar), Offset(size.width - _rightPad, zeroBar), gridPaint);

    final barWidth = (plotW / total * 0.68).clamp(3.0, 20.0);
    for (int i = 0; i < bars.length; i++) {
      final v = bars[i];
      if (!v.isFinite) continue;
      final x = scaleX(i) - barWidth / 2;
      final y = v >= 0 ? scaleBar(v) : zeroBar;
      final h = (scaleBar(v) - zeroBar).abs().clamp(2.0, double.infinity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y < zeroBar ? y : zeroBar, barWidth, h), const Radius.circular(2)),
        Paint()..color = v >= 0 ? const Color(0xFFF87171) : const Color(0xFFFCA5A5),
      );
    }

    // ── Date labels (x-axis) ──
    if (dates.isNotEmpty) {
      final step = total > 7 ? (total / 7).ceil() : 1;
      for (int i = 0; i < total; i++) {
        if (i != 0 && i != total - 1 && i % step != 0) continue;
        if (i >= dates.length) continue;
        final label = DateFormat('MMM d').format(dates[i]);
        _drawText(canvas, label, Offset(scaleX(i), barBottom + 10), labelStyle, align: _TextAlign.center);
      }
    }

    // ── Hover vertical line ──
    if (hoverIndex != null && hoverIndex! < total) {
      final hx = scaleX(hoverIndex!);
      canvas.drawLine(
        Offset(hx, _topPad),
        Offset(hx, barBottom),
        Paint()..color = const Color(0xFF94A3B8).withOpacity(0.45)..strokeWidth = 1,
      );
    }
  }

  void _drawArea(Canvas canvas, List<double> series, double Function(int) sx, double Function(double) sy,
      double baseY, Color color, double top, double bot, double leftPad) {
    final first = series.indexWhere((v) => v.isFinite && v > 0);
    if (first < 0) return;
    int last = first;
    for (int i = series.length - 1; i >= first; i--) {
      if (series[i].isFinite && series[i] > 0) { last = i; break; }
    }

    final path = Path()..moveTo(sx(first), baseY);
    for (int i = first; i <= last; i++) {
      if (series[i].isFinite && series[i] > 0) path.lineTo(sx(i), sy(series[i]));
    }
    path..lineTo(sx(last), baseY)..close();

    canvas.drawPath(
      path,
      Paint()..style = PaintingStyle.fill
        ..shader = ui.Gradient.linear(
          Offset(0, _topPad), Offset(0, baseY),
          [color.withOpacity(top), color.withOpacity(bot)],
        ),
    );
  }

  void _drawLine(Canvas canvas, List<double> series, double Function(int) sx, double Function(double) sy, Color color, double width) {
    final path = Path();
    bool started = false;
    for (int i = 0; i < series.length; i++) {
      if (!series[i].isFinite || series[i] <= 0) continue;
      if (!started) { path.moveTo(sx(i), sy(series[i])); started = true; }
      else { path.lineTo(sx(i), sy(series[i])); }
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = width..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style, {required _TextAlign align}) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: ui.TextDirection.ltr)..layout();
    double dx = pos.dx;
    if (align == _TextAlign.right) dx -= tp.width;
    if (align == _TextAlign.center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ChartPanelPainter old) =>
      old.leftSeries != leftSeries || old.hoverIndex != hoverIndex;
}

enum _TextAlign { left, right, center }

/// ── Metric cards section (mirrors FE's metrics grid) ──
class MarketMetricCards extends StatelessWidget {
  final List<_MetricItem> metrics;

  const MarketMetricCards({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullW = constraints.maxWidth;
        final halfW = (fullW - 8) / 2; // Subtracting spacing

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: metrics.asMap().entries.map((e) {
            final i = e.key;
            final m = e.value;

            // Logic: group the last two if there are at least 4 metrics
            final isGrouped = metrics.length >= 4 && i >= metrics.length - 2;
            final width = isGrouped ? halfW : fullW;

            Color borderColor;
            Color bgColor;
            switch (i) {
              case 0: borderColor = const Color(0xFF6EE7B7); bgColor = const Color(0xFFF0FDF4); break;
              case 1: borderColor = const Color(0xFF7DD3FC); bgColor = const Color(0xFFF0F9FF); break;
              case 2: borderColor = const Color(0xFFFCA5A5); bgColor = const Color(0xFFFFF5F5); break;
              default: borderColor = const Color(0xFFE2E8F0); bgColor = Colors.white;
            }

            return Container(
              width: width,
              padding: EdgeInsets.symmetric(horizontal: isGrouped ? 12 : 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isGrouped
                  ? Column(
                    // Grouped (Small) layout
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 8,
                              letterSpacing: 1.0,
                              color: Colors.black54,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(m.value,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                letterSpacing: -0.5)),
                      ),
                    ],
                  )
                  : Row(
                    // Standard (Full-width) layout
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.label.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 9,
                                    letterSpacing: 1.2,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w800)),
                            if (m.subtext.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(m.subtext,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.black38,
                                        fontWeight: FontWeight.w500)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: Text(m.value,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                letterSpacing: -0.5)),
                      ),
                      if (m.change != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: (m.change! > 0
                                    ? const Color(0xFF059669)
                                    : m.change! < 0
                                        ? const Color(0xFFDC2626)
                                        : Colors.black45)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${m.change! >= 0 ? '+' : ''}${m.change!.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: m.change! > 0
                                  ? const Color(0xFF059669)
                                  : m.change! < 0
                                      ? const Color(0xFFDC2626)
                                      : Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MetricItem {
  final String label;
  final String value;
  final String subtext;
  final double? change;
  const _MetricItem({required this.label, required this.value, required this.subtext, this.change});
}

/// Factory to build metrics for each tab
List<_MetricItem> buildGoldMetrics({
  required double domesticSell,
  required double worldLocal,
  required double premium,
  required double exchangeRate,
  required double correlation,
  required double domesticChange,
  required double worldChange,
  required double premiumChange,
}) {
  String fmt(double v) => NumberFormat('#,##0', 'en_US').format(v.round());
  return [
    _MetricItem(label: 'SJC Gold', value: '${fmt(domesticSell)} VND', subtext: 'Primary domestic track in VND / Luong', change: domesticChange),
    _MetricItem(label: 'International Spot', value: '${fmt(worldLocal)} VND', subtext: 'Converted benchmark aligned to Luong', change: worldChange),
    _MetricItem(label: 'Spread', value: '${fmt(premium)} VND', subtext: 'Local premium over converted world benchmark', change: premiumChange),
    _MetricItem(label: 'USD/VND Rate', value: fmt(exchangeRate), subtext: 'Cross-rate used in all local conversions'),
    _MetricItem(label: 'Correlation (1M)', value: correlation.toStringAsFixed(2), subtext: 'Domestic vs converted international movement'),
  ];
}

List<_MetricItem> buildSilverMetrics({
  required double domesticSell,
  required double worldLocal,
  required double premium,
  required double exchangeRate,
  required double correlation,
  required double domesticChange,
  required double worldChange,
  required double premiumChange,
}) {
  String fmt(double v) => NumberFormat('#,##0', 'en_US').format(v.round());
  return [
    _MetricItem(label: 'Phu Quy Silver', value: '${fmt(domesticSell)} VND', subtext: 'Primary domestic track in VND / Kg', change: domesticChange),
    _MetricItem(label: 'International Spot', value: '${fmt(worldLocal)} VND', subtext: 'Converted benchmark aligned to Kg', change: worldChange),
    _MetricItem(label: 'Spread', value: '${fmt(premium)} VND', subtext: 'Local premium over converted world benchmark', change: premiumChange),
    _MetricItem(label: 'USD/VND Rate', value: fmt(exchangeRate), subtext: 'Cross-rate used in all local conversions'),
    _MetricItem(label: 'Correlation (1M)', value: correlation.toStringAsFixed(2), subtext: 'Domestic vs converted international movement'),
  ];
}

List<_MetricItem> buildForexMetrics({
  required double latestRate,
  required double weeklyChange,
  required double sessionRange,
  required double domesticChange,
}) {
  String fmt(double v) => NumberFormat('#,##0', 'en_US').format(v.round());
  return [
    _MetricItem(label: 'USD/VND Rate', value: fmt(latestRate), subtext: 'Tracked from local FX history', change: domesticChange),
    _MetricItem(label: 'Weekly Change', value: '${weeklyChange >= 0 ? '+' : ''}${weeklyChange.toStringAsFixed(2)}%', subtext: 'Short-term trend from current range', change: weeklyChange),
    _MetricItem(label: 'Session Range', value: '${fmt(sessionRange)} VND', subtext: 'High-low spread in selected range'),
    _MetricItem(label: 'Signal', value: domesticChange >= 0 ? 'USD Firm' : 'VND Firm', subtext: 'Derived from latest momentum'),
  ];
}
