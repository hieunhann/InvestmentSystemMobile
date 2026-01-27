import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final vertical = (size.height * 0.02).clamp(12.0, 18.0);

    return Column(
      children: [
        AppHeader(
          title: 'Welcome,',
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
          bottom: Center(
            child: Text(
              'Account',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.sp),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical),
            children: const [
              AppCard(
                child: Text('Account UI placeholder (no BE yet).'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

