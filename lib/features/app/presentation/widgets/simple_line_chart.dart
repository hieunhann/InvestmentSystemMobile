import 'package:flutter/material.dart';

class SimpleLineChart extends StatelessWidget {
  final List<double> seriesA;
  final List<double> seriesB;

  const SimpleLineChart({
    super.key,
    required this.seriesA,
    required this.seriesB,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.6,
      child: CustomPaint(
        painter: _LineChartPainter(seriesA: seriesA, seriesB: seriesB),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> seriesA;
  final List<double> seriesB;

  _LineChartPainter({required this.seriesA, required this.seriesB});

  @override
  void paint(Canvas canvas, Size size) {
    final bg =
        Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.08)
          ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Calculate common range for both series
    double minV = double.infinity;
    double maxV = double.negativeInfinity;

    void updateRange(List<double> data) {
      if (data.isEmpty) return;
      for (final v in data) {
        if (v < minV) minV = v;
        if (v > maxV) maxV = v;
      }
    }

    updateRange(seriesA);
    updateRange(seriesB);

    if (minV == double.infinity) {
      minV = 0.0;
      maxV = 1.0;
    }

    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    _drawSeries(
      canvas,
      size,
      seriesA,
      const Color(0xFF1976D2),
      minV,
      range,
    ); // Blue for Buy
    _drawSeries(
      canvas,
      size,
      seriesB,
      const Color(0xFFE53935),
      minV,
      range,
    ); // Red for Sell
  }

  void _drawSeries(
    Canvas canvas,
    Size size,
    List<double> data,
    Color color,
    double minV,
    double range,
  ) {
    if (data.isEmpty) return;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = size.width * (data.length > 1 ? (i / (data.length - 1)) : 0.5);
      final norm = (data[i] - minV) / range;
      final y = size.height * (1 - norm);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    // Draw dots and labels on each point
    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Only show labels for some points to avoid overlap
    final maxLabels = 7; // Maximum number of labels to show
    final step = data.length > maxLabels ? (data.length / maxLabels).ceil() : 1;

    // Don't show dots/labels for long time ranges (like 1 year with 365 points)
    // Show dots for 1W, 1M (<=30 points)
    // Show labels for 1W, 1M, 6M (<=200 points) - about 6 labels for 6M
    final shouldShowDots = data.length <= 30;
    final shouldShowLabels = data.length <= 200;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Draw dot for all points (skip if too many points)
      if (shouldShowDots) {
        canvas.drawCircle(point, 2.5, dotPaint);
      }

      // Only show label for selected points (first, last, and evenly spaced)
      final shouldShowLabel = i == 0 || i == points.length - 1 || i % step == 0;

      if (shouldShowLabel && shouldShowLabels) {
        // Draw label with background
        final textSpan = TextSpan(
          text: data[i].toStringAsFixed(1),
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Alternate label position (above/below) to reduce overlap
        final isAbove = i % 2 == 0;
        final labelOffset = Offset(
          point.dx - textPainter.width / 2,
          isAbove ? point.dy - textPainter.height - 8 : point.dy + 8,
        );

        // Draw background for text
        final bgRect = Rect.fromLTWH(
          labelOffset.dx - 2,
          labelOffset.dy - 1,
          textPainter.width + 4,
          textPainter.height + 2,
        );
        final bgPaint =
            Paint()
              ..color = Colors.white.withOpacity(0.85)
              ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, const Radius.circular(3)),
          bgPaint,
        );

        textPainter.paint(canvas, labelOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.seriesA != seriesA || oldDelegate.seriesB != seriesB;
  }
}
