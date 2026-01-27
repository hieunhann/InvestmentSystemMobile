import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';

class DonutChart extends StatelessWidget {
  final int goldPct;
  final int silverPct;
  final int currencyPct;

  const DonutChart({
    super.key,
    required this.goldPct,
    required this.silverPct,
    required this.currencyPct,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140.w,
      height: 140.w,
      child: CustomPaint(
        painter: _DonutPainter(
          goldPct: goldPct,
          silverPct: silverPct,
          currencyPct: currencyPct,
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int goldPct;
  final int silverPct;
  final int currencyPct;

  _DonutPainter({
    required this.goldPct,
    required this.silverPct,
    required this.currencyPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;
    final stroke = radius * 0.25;

    final basePaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.72),
      0,
      6.283185307179586,
      false,
      basePaint,
    );

    double start = -1.5707963267948966; // -pi/2
    _drawSlice(canvas, center, radius * 0.72, stroke, goldPct, AppColors.primary, start);
    start += _toSweep(goldPct);
    _drawSlice(canvas, center, radius * 0.72, stroke, silverPct, const Color(0xFF9E9E9E), start);
    start += _toSweep(silverPct);
    _drawSlice(canvas, center, radius * 0.72, stroke, currencyPct, AppColors.secondary, start);
  }

  void _drawSlice(
    Canvas canvas,
    Offset center,
    double radius,
    double stroke,
    int pct,
    Color color,
    double start,
  ) {
    final sweep = _toSweep(pct);
    if (sweep <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, paint);
  }

  double _toSweep(int pct) => (pct.clamp(0, 100) / 100) * 6.283185307179586;

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.goldPct != goldPct ||
        oldDelegate.silverPct != silverPct ||
        oldDelegate.currencyPct != currencyPct;
  }
}

