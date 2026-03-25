import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// FE-matching BuySellChart — mirrors MarketInsightsPage.jsx → BuySellChart
/// Shows Buy (blue) + Sell (red) lines with interactive tooltip on tap/hover.
class MarketBuySellChart extends StatefulWidget {
  final List<double> buySeries;
  final List<double> sellSeries;
  final List<DateTime> dates;
  final String label;
  final String unitLabel; // "VND" | "USD"
  final bool isLoading;
  final String emptyText;

  const MarketBuySellChart({
    super.key,
    required this.buySeries,
    required this.sellSeries,
    required this.dates,
    required this.label,
    this.unitLabel = 'VND',
    this.isLoading = false,
    this.emptyText = 'No data available.',
  });

  @override
  State<MarketBuySellChart> createState() => _MarketBuySellChartState();
}

class _MarketBuySellChartState extends State<MarketBuySellChart> {
  int? _hoverIndex;

  static String _fmtValue(double v, String unitLabel) {
    if (unitLabel == 'USD') return NumberFormat('0.00').format(v);
    return NumberFormat('#,##0', 'en_US').format(v.round());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final combined = [...widget.buySeries, ...widget.sellSeries]
        .where((v) => v.isFinite && v > 0)
        .toList();
    if (combined.isEmpty || widget.buySeries.isEmpty) {
      return SizedBox(
        height: 260,
        child: Center(child: Text(widget.emptyText, style: const TextStyle(color: Colors.black38))),
      );
    }

    final lastBuy = widget.buySeries.lastWhere((v) => v.isFinite && v > 0, orElse: () => 0);
    final lastSell = widget.sellSeries.isEmpty
        ? 0.0
        : widget.sellSeries.lastWhere((v) => v.isFinite && v > 0, orElse: () => 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header — mirrors FE's "Buy / Sell Price Chart" section
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BUY / SELL PRICE CHART',
                style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.black45, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ],
          ),
        ),

        // Price badges
        Row(
          children: [
            _PriceBadge(label: 'Buy', value: _fmtValue(lastBuy, widget.unitLabel), unit: widget.unitLabel, color: const Color(0xFF2563EB), bg: const Color(0xFFEFF6FF), border: const Color(0xFFBFDBFE)),
            const SizedBox(width: 10),
            if (lastSell > 0)
              _PriceBadge(label: 'Sell', value: _fmtValue(lastSell, widget.unitLabel), unit: widget.unitLabel, color: const Color(0xFFDC2626), bg: const Color(0xFFFEF2F2), border: const Color(0xFFFECACA)),
          ],
        ),
        const SizedBox(height: 12),

        // Chart
        GestureDetector(
          onTapDown: (details) => _onTouch(details.localPosition),
          onPanUpdate: (details) => _onTouch(details.localPosition),
          onPanEnd: (_) => setState(() => _hoverIndex = null),
          onTapCancel: () => setState(() => _hoverIndex = null),
          child: SizedBox(
            height: 200,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BuySellPainter(
                buySeries: widget.buySeries,
                sellSeries: widget.sellSeries,
                dates: widget.dates,
                unitLabel: widget.unitLabel,
                hoverIndex: _hoverIndex,
              ),
            ),
          ),
        ),

        // Tooltip row
        if (_hoverIndex != null && _hoverIndex! < widget.buySeries.length)
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_hoverIndex! < widget.dates.length)
                    Text(
                      DateFormat('MMM d').format(widget.dates[_hoverIndex!]),
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(width: 10),
                  const Text('●', style: TextStyle(fontSize: 10, color: Color(0xFF2563EB))),
                  const SizedBox(width: 4),
                  Text('Buy: ${_fmtValue(widget.buySeries[_hoverIndex!], widget.unitLabel)}', style: const TextStyle(fontSize: 11, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                  if (_hoverIndex! < widget.sellSeries.length && widget.sellSeries[_hoverIndex!] > 0) ...[
                    const SizedBox(width: 10),
                    const Text('●', style: TextStyle(fontSize: 10, color: Color(0xFFDC2626))),
                    const SizedBox(width: 4),
                    Text('Sell: ${_fmtValue(widget.sellSeries[_hoverIndex!], widget.unitLabel)}', style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C), fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),

        // Legend — mirrors FE
        Row(
          children: [
            Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('Buy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(width: 16),
            if (lastSell > 0) ...[
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('Sell', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ],
        ),
      ],
    );
  }

  void _onTouch(Offset pos) {
    final total = widget.buySeries.length;
    if (total < 2) return;
    const leftPad = 0.0;
    // approximate (will be refined by painter)
    final w = context.size?.width ?? 300;
    final idx = ((pos.dx - leftPad) / (w - leftPad) * (total - 1)).round().clamp(0, total - 1);
    setState(() {
      _hoverIndex = idx;
    });
  }
}

class _PriceBadge extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final Color bg;
  final Color border;

  const _PriceBadge({required this.label, required this.value, required this.unit, required this.color, required this.bg, required this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text('$value $unit', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
        ],
      ),
    );
  }
}

/// CustomPainter for the Buy/Sell chart
class _BuySellPainter extends CustomPainter {
  final List<double> buySeries;
  final List<double> sellSeries;
  final List<DateTime> dates;
  final String unitLabel;
  final int? hoverIndex;

  _BuySellPainter({
    required this.buySeries,
    required this.sellSeries,
    required this.dates,
    required this.unitLabel,
    this.hoverIndex,
  });

  static const _leftPad = 52.0;
  static const _rightPad = 12.0;
  static const _topPad = 8.0;
  static const _bottomPad = 28.0;
  static const _buyColor = Color(0xFF2563EB);
  static const _sellColor = Color(0xFFDC2626);
  static const _gridColor = Color(0xFFE2E8F0);

  @override
  void paint(Canvas canvas, Size size) {
    final total = buySeries.length;
    if (total < 2) return;

    final combined = [...buySeries, ...sellSeries].where((v) => v.isFinite && v > 0).toList();
    if (combined.isEmpty) return;

    final minV = combined.reduce((a, b) => a < b ? a : b);
    final maxV = combined.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV).abs();
    final pad = span > 0 ? span * 0.12 : (minV * 0.05).abs();
    final yMin = minV - pad;
    final yMax = maxV + pad;
    final ySpan = (yMax - yMin).abs();
    if (ySpan == 0) return;

    final plotW = size.width - _leftPad - _rightPad;
    final plotH = size.height - _topPad - _bottomPad;

    double scaleX(int i) => _leftPad + i * plotW / (total - 1);
    double scaleY(double v) => _topPad + plotH - (v - yMin) / ySpan * plotH;

    // Grid lines + Y labels
    final gridPaint = Paint()..color = _gridColor..strokeWidth = 1;
    final labelStyle = TextStyle(fontSize: 9, color: Colors.black38, fontWeight: FontWeight.w500);

    for (int g = 0; g <= 4; g++) {
      final v = yMin + ySpan * g / 4;
      final y = scaleY(v);
      canvas.drawLine(Offset(_leftPad, y), Offset(size.width - _rightPad, y), gridPaint);

      // Y-axis label
      final label = unitLabel == 'USD' ? v.toStringAsFixed(2) : _compactFmt(v);
      final tp = TextPainter(text: TextSpan(text: label, style: labelStyle), textDirection: ui.TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(_leftPad - tp.width - 4, y - tp.height / 2));
    }

    // Axes
    final axisPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1;
    canvas.drawLine(Offset(_leftPad, _topPad), Offset(_leftPad, _topPad + plotH), axisPaint);
    canvas.drawLine(Offset(_leftPad, _topPad + plotH), Offset(size.width - _rightPad, _topPad + plotH), axisPaint);

    // Draw series
    void drawLine(List<double> series, Color color) {
      final path = Path();
      bool started = false;
      for (int i = 0; i < series.length; i++) {
        if (!series[i].isFinite || series[i] <= 0) continue;
        final x = scaleX(i);
        final y = scaleY(series[i]);
        if (!started) { path.moveTo(x, y); started = true; } else { path.lineTo(x, y); }
      }
      canvas.drawPath(path, Paint()..color = color..strokeWidth = 2.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

      // Dots (only if few points)
      if (series.length <= 30) {
        for (int i = 0; i < series.length; i++) {
          if (!series[i].isFinite || series[i] <= 0) continue;
          canvas.drawCircle(Offset(scaleX(i), scaleY(series[i])), 3.2, Paint()..color = color..style = PaintingStyle.fill);
        }
      }
    }

    drawLine(buySeries, _buyColor);
    if (sellSeries.isNotEmpty) drawLine(sellSeries, _sellColor);

    // Last value dots (highlighted)
    final lastBuyIdx = buySeries.lastIndexWhere((v) => v.isFinite && v > 0);
    if (lastBuyIdx >= 0) {
      canvas.drawCircle(Offset(scaleX(lastBuyIdx), scaleY(buySeries[lastBuyIdx])), 5, Paint()..color = _buyColor);
    }
    if (sellSeries.isNotEmpty) {
      final lastSellIdx = sellSeries.lastIndexWhere((v) => v.isFinite && v > 0);
      if (lastSellIdx >= 0) {
        canvas.drawCircle(Offset(scaleX(lastSellIdx), scaleY(sellSeries[lastSellIdx])), 5, Paint()..color = _sellColor);
      }
    }

    // Hover line
    if (hoverIndex != null && hoverIndex! < total) {
      final hx = scaleX(hoverIndex!);
      canvas.drawLine(
        Offset(hx, _topPad),
        Offset(hx, _topPad + plotH),
        Paint()..color = const Color(0xFF94A3B8).withOpacity(0.45)..strokeWidth = 1..style = PaintingStyle.stroke
          ..shader = null,
      );
    }

    // X-axis date labels (max 6)
    if (dates.isNotEmpty) {
      final step = total > 6 ? (total / 6).ceil() : 1;
      for (int i = 0; i < total; i++) {
        if (i != 0 && i != total - 1 && i % step != 0) continue;
        if (i >= dates.length) continue;
        final label = DateFormat('MMM d').format(dates[i]);
        final tp = TextPainter(text: TextSpan(text: label, style: labelStyle), textDirection: ui.TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(scaleX(i) - tp.width / 2, _topPad + plotH + 8));
      }
    }
  }

  static String _compactFmt(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(covariant _BuySellPainter old) =>
      old.buySeries != buySeries || old.sellSeries != sellSeries || old.hoverIndex != hoverIndex;
}
