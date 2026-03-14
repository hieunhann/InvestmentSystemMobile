import 'package:my_flutter_app/services/api_service.dart';
import 'package:my_flutter_app/models/auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service xử lý Authentication (Register, Login, Logout)
class AuthService {
  final ApiService _apiService = ApiService();
  
  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';

  /// Đăng ký user mới
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        request.toJson(),
        authorized: false,
      );

      return RegisterResponse.fromJson(response);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Đăng nhập
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        request.toJson(),
        authorized: false,
      );

      final loginResponse = LoginResponse.fromJson(response);

      // Lưu token vào ApiService
      ApiService.setAccessToken(loginResponse.token);

      // Lưu thông tin user vào SharedPreferences
      await _saveLoginData(loginResponse);

      return loginResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    // Clear token from ApiService
    ApiService.setAccessToken(null);

    // Clear saved data
    await _clearLoginData();
  }

  /// Kiểm tra user đã login chưa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Lấy token đã lưu
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Restore session từ saved data
  Future<LoginResponse?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    
    if (token == null) return null;

    final userId = prefs.getString(_userIdKey);
    final username = prefs.getString(_usernameKey);
    final email = prefs.getString(_emailKey);

    if (userId == null || username == null || email == null) {
      return null;
    }

    // Restore token to ApiService
    ApiService.setAccessToken(token);

    return LoginResponse(
      token: token,
      type: 'Bearer',
      userId: userId,
      username: username,
      email: email,
      roles: [], // Roles will be fetched from profile API
    );
  }

  /// Save login data to SharedPreferences
  Future<void> _saveLoginData(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, response.token);
    await prefs.setString(_userIdKey, response.userId ?? '');
    await prefs.setString(_usernameKey, response.username);
    await prefs.setString(_emailKey, response.email);
  }

  /// Clear login data from SharedPreferences
  Future<void> _clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
  }
}
