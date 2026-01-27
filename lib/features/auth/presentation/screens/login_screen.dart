import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_state.dart';
import 'package:my_flutter_app/features/auth/presentation/screens/register_screen.dart';
import 'package:my_flutter_app/features/auth/presentation/widgets/auth_card.dart';
import 'package:my_flutter_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:my_flutter_app/features/auth/presentation/widgets/social_icon_row.dart';
import 'package:my_flutter_app/features/app/presentation/main_shell.dart';
import 'package:my_flutter_app/widgets/custom_button.dart';
import 'package:my_flutter_app/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShell()),
              (_) => false,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          final size = MediaQuery.sizeOf(context);
          final horizontalPadding = (size.width * 0.06).clamp(18.0, 28.0);
          final topSpacing = MediaQuery.of(context).padding.top + (size.height * 0.03).clamp(20.0, 40.0);
          final bottomSpacing = MediaQuery.of(context).padding.bottom + (size.height * 0.02).clamp(10.0, 20.0);

          return SizedBox.expand(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topSpacing,
                horizontalPadding,
                bottomSpacing,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - topSpacing - bottomSpacing),
                child: Center(
                  child: AuthCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: (size.height * 0.03).clamp(14.0, 24.0).h),
                        Text(
                          'GoldInsight',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: (size.height * 0.04).clamp(18.0, 34.0)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email',
                            style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                          ),
                        ),
                        SizedBox(height: (size.height * 0.008).clamp(6.0, 10.0)),
                        CustomTextField(
                          controller: _emailCtrl,
                          hintText: 'your.email@example.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: (size.height * 0.018).clamp(10.0, 16.0)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Password',
                            style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                          ),
                        ),
                        SizedBox(height: (size.height * 0.008).clamp(6.0, 10.0)),
                        CustomTextField(
                          controller: _passwordCtrl,
                          hintText: 'Enter your password',
                          obscureText: _obscure,
                          suffixIcon:
                              _obscure ? Icons.visibility_off : Icons.visibility,
                          onSuffixIconPressed: () {
                            setState(() => _obscure = !_obscure);
                          },
                        ),
                        SizedBox(height: (size.height * 0.004).clamp(4.0, 8.0)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(10, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(fontSize: 11.sp),
                            ),
                          ),
                        ),
                        SizedBox(height: (size.height * 0.012).clamp(10.0, 14.0)),
                        SizedBox(
                          width: (size.width * 0.36).clamp(130.0, 170.0),
                          child: CustomButton(
                            text: 'Login',
                            height: (size.height * 0.045).clamp(36.0, 44.0),
                            isLoading: isLoading,
                            backgroundColor: AppColors.primary,
                            onPressed: () {
                              context.read<AuthCubit>().login(
                                    email: _emailCtrl.text.trim(),
                                    password: _passwordCtrl.text,
                                  );
                            },
                          ),
                        ),
                        SizedBox(height: (size.height * 0.02).clamp(14.0, 20.0)),
                        const SocialIconRow(),
                        SizedBox(height: (size.height * 0.02).clamp(14.0, 20.0)),
                        Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                        ),
                        SizedBox(height: (size.height * 0.008).clamp(6.0, 10.0)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(10, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

