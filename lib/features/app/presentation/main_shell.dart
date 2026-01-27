import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/app/bloc/public_market_cubit.dart';
import 'package:my_flutter_app/features/app/presentation/screens/account_screen.dart';
import 'package:my_flutter_app/features/app/presentation/screens/analytics_screen.dart';
import 'package:my_flutter_app/features/app/presentation/screens/news_screen.dart';
import 'package:my_flutter_app/features/app/presentation/screens/portfolio_screen.dart';
import 'package:my_flutter_app/features/app/presentation/screens/public_market_screen.dart';
import 'package:my_flutter_app/services/gold_price_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublicMarketCubit(GoldPriceService()),
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: _index,
            children: const [
              PublicMarketScreen(),
              PortfolioScreen(),
              AnalyticsScreen(),
              NewsScreen(),
              AccountScreen(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryVariant,
          unselectedItemColor: Colors.black54,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.wallet_outlined), label: 'Portfolio'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'News'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
          ],
        ),
      ),
    );
  }
}

