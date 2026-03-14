import 'package:flutter/foundation.dart';
import 'package:my_flutter_app/models/backend_user.dart';

enum AuthStatus { initial, loading, authenticated, failure }

@immutable
class AuthState {
  final AuthStatus status;
  final String? message;
  final BackendUser? user;
  final String? token;

  const AuthState({
    required this.status,
    this.message,
    this.user,
    this.token,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    BackendUser? user,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message,
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

