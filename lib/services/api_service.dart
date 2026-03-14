import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/models/user.dart';

/// API Service for handling HTTP requests
class ApiService {
  ApiService();

  // Override bằng: flutter run --dart-define=API_BASE_URL=http://<host>:8080
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // Mặc định: desktop/web dùng localhost, Android emulator dùng 10.0.2.2
  static final String baseUrl = _envBaseUrl.isNotEmpty
      ? _envBaseUrl
      : (kIsWeb ||
              (defaultTargetPlatform == TargetPlatform.windows) ||
              (defaultTargetPlatform == TargetPlatform.macOS)
          ? 'http://localhost:8080'
          : 'http://10.0.2.2:8080');

  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 30);

  static String? _accessToken;

  static void setAccessToken(String? token) {
    _accessToken = token;
  }

  static String? get accessToken => _accessToken;

  /// GET request
  Future<dynamic> get(String endpoint, {bool authorized = false}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .get(url, headers: _getHeaders(authorized: authorized))
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool authorized = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            url,
            headers: _getHeaders(authorized: authorized),
            body: jsonEncode(data),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool authorized = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            url,
            headers: _getHeaders(authorized: authorized),
            body: jsonEncode(data),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint, {bool authorized = false}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(url, headers: _getHeaders(authorized: authorized))
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get headers
  Map<String, String> _getHeaders({required bool authorized}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authorized && _accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded.containsKey('success')) {
        final success = decoded['success'] == true;
        if (!success) {
          final message = decoded['message']?.toString() ?? 'Request failed.';
          throw Exception(message);
        }
        return decoded['data'] ?? decoded;
      }

      return decoded;
    }

    final body = response.body;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
    } catch (_) {
      // Keep raw body fallback below.
    }

    throw Exception('HTTP ${response.statusCode}: $body');
  }

  /// Handle errors
  Exception _handleError(dynamic error) {
    if (error is Exception) {
      return error;
    }
    return Exception('Unexpected error: $error');
  }

  // Example: Get users
  Future<List<User>> getUsers() async {
    try {
      final response = await get('/users');
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // Example: Get user by ID
  Future<User> getUserById(String id) async {
    try {
      final response = await get('/users/$id');
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  // Example: Create user
  Future<User> createUser(User user) async {
    try {
      final response = await post('/users', user.toJson());
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Example: Update user
  Future<User> updateUser(String id, User user) async {
    try {
      final response = await put('/users/$id', user.toJson());
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Example: Delete user
  Future<void> deleteUser(String id) async {
    try {
      await delete('/users/$id');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
