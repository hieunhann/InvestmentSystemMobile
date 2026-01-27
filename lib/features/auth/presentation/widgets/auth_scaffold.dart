import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  final String? topLeftLabel;
  final Widget child;

  const AuthScaffold({super.key, this.topLeftLabel, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Stack(
        children: [
          if (topLeftLabel != null)
            Positioned(
              left: 18.w,
              top: MediaQuery.of(context).padding.top + 14.h,
              child: Text(
                topLeftLabel!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

