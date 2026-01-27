import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardWidth = (size.width * 0.88).clamp(280.0, 420.0);

    return Container(
      width: cardWidth,
      padding: EdgeInsets.symmetric(
        horizontal: (size.width * 0.05).clamp(16.0, 22.0),
        vertical: (size.height * 0.03).clamp(18.0, 28.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: child,
    );
  }
}

