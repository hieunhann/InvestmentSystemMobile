import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/constants/app_strings.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';
import 'package:my_flutter_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';
import 'package:my_flutter_app/providers/market_data_provider.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
    await NotificationService.initialize();
  } catch (e) {
    print('⚠️ Firebase initialization error (maybe missing google-services.json): $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            BlocProvider(create: (_) => AuthCubit()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MarketDataProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
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
