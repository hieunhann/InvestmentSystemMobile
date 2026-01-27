import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/models/user.dart';

/// API Service for handling HTTP requests
class ApiService {
  // Base URL - thay đổi theo API của bạn
  static const String baseUrl = 'https://api.example.com';

  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(url, headers: _getHeaders(), body: jsonEncode(data))
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(url, headers: _getHeaders(), body: jsonEncode(data))
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(url, headers: _getHeaders())
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get headers
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Thêm authorization token nếu cần
      // 'Authorization': 'Bearer $token',
    };
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) {
          return null;
        }
        return jsonDecode(response.body);
      case 400:
        throw Exception('Bad request: ${response.body}');
      case 401:
        throw Exception('Unauthorized: ${response.body}');
      case 403:
        throw Exception('Forbidden: ${response.body}');
      case 404:
        throw Exception('Not found: ${response.body}');
      case 500:
        throw Exception('Server error: ${response.body}');
      default:
        throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
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
