import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_cubit.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_state.dart';
import 'package:my_flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:my_flutter_app/features/auth/presentation/widgets/auth_card.dart';
import 'package:my_flutter_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:my_flutter_app/features/auth/presentation/widgets/social_icon_row.dart';
import 'package:my_flutter_app/features/app/presentation/main_shell.dart';
import 'package:my_flutter_app/widgets/custom_button.dart';
import 'package:my_flutter_app/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
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
          } else if (state.status == AuthStatus.failure && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
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
                        SizedBox(height: (size.height * 0.02).clamp(12.0, 18.0)),
                        Text(
                          'Create Your Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: (size.height * 0.03).clamp(16.0, 22.0)),
                        _Label(text: 'Full Name'),
                        SizedBox(height: (size.height * 0.008).clamp(6.0, 10.0)),
                        CustomTextField(
                          controller: _fullNameCtrl,
                          hintText: 'John Doe',
                          keyboardType: TextInputType.name,
                        ),
                        SizedBox(height: (size.height * 0.012).clamp(10.0, 14.0)),
                        _Label(text: 'Email'),
                        SizedBox(height: (size.height * 0.008).clamp(6.0, 10.0)),
                        CustomTextField(
                          controller: _emailCtrl,
                          hintText: 'john.doe@example.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: (size.height * 0.012).clamp(10.0, 14.0)),
                        _Label(text: 'Phone Number'),
                        SizedBox(height: (size.height * 0.008).clamp(6.0, 10.0)),
                        CustomTextField(
                          controller: _phoneCtrl,
                          hintText: '+1 234 567 8900',
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: (size.height * 0.012).clamp(10.0, 14.0)),
                        _Label(text: 'Password'),
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
                        SizedBox(height: (size.height * 0.018).clamp(12.0, 16.0)),
                        CustomButton(
                          text: 'Register Account',
                          height: (size.height * 0.05).clamp(40.0, 46.0),
                          isLoading: isLoading,
                          backgroundColor: AppColors.primary,
                          onPressed: () {
                            context.read<AuthCubit>().register(
                                  fullName: _fullNameCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  phoneNumber: _phoneCtrl.text.trim(),
                                  password: _passwordCtrl.text,
                                );
                          },
                        ),
                        SizedBox(height: (size.height * 0.018).clamp(12.0, 16.0)),
                        const SocialIconRow(),
                        SizedBox(height: (size.height * 0.02).clamp(14.0, 18.0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
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
                                'Login',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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

class _Label extends StatelessWidget {
  final String text;

  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: Colors.black87),
      ),
    );
  }
}

