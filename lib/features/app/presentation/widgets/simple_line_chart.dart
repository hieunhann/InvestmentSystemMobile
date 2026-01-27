import 'package:flutter/material.dart';
import 'package:my_flutter_app/constants/app_colors.dart';

class SimpleLineChart extends StatelessWidget {
  final List<double> seriesA;
  final List<double> seriesB;

  const SimpleLineChart({super.key, required this.seriesA, required this.seriesB});

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
    final bg = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    _drawSeries(canvas, size, seriesA, AppColors.secondary);
    _drawSeries(canvas, size, seriesB, const Color(0xFFB0BEC5));
  }

  void _drawSeries(Canvas canvas, Size size, List<double> data, Color color) {
    if (data.isEmpty) return;
    final minV = data.reduce((a, b) => a < b ? a : b);
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1));
      final norm = (data[i] - minV) / range;
      final y = size.height * (1 - norm);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.seriesA != seriesA || oldDelegate.seriesB != seriesB;
  }
}

