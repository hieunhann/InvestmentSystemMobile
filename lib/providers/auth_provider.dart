import 'package:flutter/material.dart';
import 'package:my_flutter_app/services/auth_service.dart';
import 'package:my_flutter_app/models/auth_models.dart';

/// Provider quản lý Authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  LoginResponse? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  LoginResponse? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  /// Restore session khi app khởi động
  Future<void> restoreSession() async {
    _setLoading(true);
    try {
      final user = await _authService.restoreSession();
      if (user != null) {
        _currentUser = user;
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to restore session: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng ký user mới
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final request = RegisterRequest(
        username: username,
        contactEmail: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      final response = await _authService.register(request);
      print('Registration successful: ${response.message}');
      
      // Auto login after registration
      return await login(username: username, password: password);
    } catch (e) {
      _errorMessage = 'Đăng ký thất bại: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Đăng nhập
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final request = LoginRequest(
        contactEmail: username, // AuthProvider uses 'username' variable for email input
        password: password,
      );

      final response = await _authService.login(request);
      _currentUser = response;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Đăng nhập thất bại: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Kiểm tra user đã login chưa
  Future<bool> checkLoginStatus() async {
    return await _authService.isLoggedIn();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
