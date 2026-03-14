import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';
import 'package:my_flutter_app/models/backend_user.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_card.dart';
import 'package:my_flutter_app/features/app/presentation/widgets/app_header.dart';
import 'package:my_flutter_app/services/auth_api_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future<BackendUser> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = AuthApiService().getCurrentUser();
  }

  Future<void> _refreshProfile() async {
    final next = AuthApiService().getCurrentUser();
    setState(() => _profileFuture = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final username = authState.user?.orgName;
    final size = MediaQuery.sizeOf(context);
    final horizontal = (size.width * 0.05).clamp(16.0, 22.0);
    final vertical = (size.height * 0.02).clamp(12.0, 18.0);

    return Column(
      children: [
        AppHeader(
          title: 'Account',
          username: username,
          bottom: Center(
            child: FutureBuilder<BackendUser>(
              future: _profileFuture,
              builder: (context, snapshot) {
                final username = snapshot.data?.orgName ?? '...';
                return Text(
                  username,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshProfile,
            child: FutureBuilder<BackendUser>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      vertical,
                      horizontal,
                      vertical,
                    ),
                    children: const [
                      AppCard(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      vertical,
                      horizontal,
                      vertical,
                    ),
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cannot load account profile',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              snapshot.error.toString().replaceFirst(
                                'Exception: ',
                                '',
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextButton(
                              onPressed: _refreshProfile,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                final user = snapshot.data;
                if (user == null) {
                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      vertical,
                      horizontal,
                      vertical,
                    ),
                    children: const [AppCard(child: Text('No profile data.'))],
                  );
                }

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    vertical,
                    horizontal,
                    vertical,
                  ),
                  children: [
                    AppCard(
                      child: _ProfileRow(
                        label: 'Organization',
                        value: user.orgName,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    AppCard(
                      child: _ProfileRow(label: 'Email', value: user.email),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
        SizedBox(height: 4.h),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
