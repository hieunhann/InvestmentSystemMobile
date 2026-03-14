import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_state.dart';
import 'package:my_flutter_app/services/api_service.dart';
import 'package:my_flutter_app/services/auth_api_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthApiService _authApiService;

  AuthCubit({AuthApiService? authApiService})
      : _authApiService = authApiService ?? AuthApiService(),
        super(const AuthState.initial());

  Future<void> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty || password.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: 'Email and password are required.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, message: null));
    try {
      final result = await _authApiService.login(
        contactEmail: normalizedEmail,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          message: null,
          user: result.user,
          token: result.token,
        ),
      );
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (errorMessage.contains('activated')) {
        errorMessage = 'Tài khoản chưa được kích hoạt. Vui lòng kiểm tra email của bạn.';
      }
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: errorMessage,
        ),
      );
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: 'Organization name, email and password are required.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, message: null));
    try {
      await _authApiService.register(
        orgName: fullName,
        contactEmail: email,
        password: password,
      );

      // Thông báo người dùng cần kích hoạt tài khoản
      emit(
        state.copyWith(
          status: AuthStatus.initial,
          message: 'Đăng ký thành công! Vui lòng kiểm tra email để kích hoạt tài khoản trước khi đăng nhập.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void logout() {
    ApiService.setAccessToken(null);
    emit(const AuthState.initial());
  }

  void reset() => emit(state.copyWith(status: AuthStatus.initial, message: null));
}

