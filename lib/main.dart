import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/constants/app_strings.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';
import 'package:my_flutter_app/features/auth/presentation/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng ScreenUtilInit để khởi tạo responsive design
    return ScreenUtilInit(
      // Design size (kích thước thiết kế chuẩn - thường là iPhone 11 Pro)
      designSize: const Size(375, 812),
      // Tự động scale text theo kích thước màn hình
      minTextAdapt: true,
      // Split screen mode support
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (_) => AuthCubit(),
          child: MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.surface,
              ),
              scaffoldBackgroundColor: AppColors.appBackground,
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            ),
            home: child,
          ),
        );
      },
      child: const WelcomeScreen(),
    );
  }
}
