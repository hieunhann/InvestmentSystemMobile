import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/features/auth/bloc/auth_state.dart';

/// Fake auth cubit (no BE): any input => login success
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.initial());

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, message: null));
    await Future<void>.delayed(const Duration(milliseconds: 450));
    emit(state.copyWith(status: AuthStatus.authenticated, message: null));
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, message: null));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(status: AuthStatus.authenticated, message: null));
  }

  void reset() => emit(const AuthState.initial());
}

