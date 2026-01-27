import 'package:flutter/foundation.dart';

enum AuthStatus { initial, loading, authenticated, failure }

@immutable
class AuthState {
  final AuthStatus status;
  final String? message;

  const AuthState({required this.status, this.message});

  const AuthState.initial() : this(status: AuthStatus.initial);

  AuthState copyWith({AuthStatus? status, String? message}) {
    return AuthState(status: status ?? this.status, message: message);
  }
}

