import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:my_flutter_app/features/auth/presentation/screens/register_screen.dart';
import 'package:my_flutter_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:my_flutter_app/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      topLeftLabel: 'Welcome',
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: MediaQuery.of(context).padding.top,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            _LogoMark(),
            SizedBox(height: 18.h),
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const Spacer(flex: 3),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Sign up',
                    isOutlined: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: CustomButton(
                    text: 'Login',
                    backgroundColor: AppColors.secondary,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 26.h),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
      ),
      child: Center(
        child: Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

