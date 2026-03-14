import 'package:my_flutter_app/models/backend_user.dart';
import 'package:my_flutter_app/services/api_service.dart';

class LoginResult {
  final String token;
  final BackendUser user;

  const LoginResult({required this.token, required this.user});
}

class AuthApiService {
  final ApiService _apiService;

  AuthApiService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<LoginResult> login({required String contactEmail, required String password}) async {
    final data = await _apiService.post('/auth/login', {
      'contactEmail': contactEmail,
      'password': password,
    });

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid login response.');
    }

    final token = data['accessToken']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('Login succeeded but token is missing.');
    }

    ApiService.setAccessToken(token);
    return LoginResult(
      token: token,
      user: BackendUser.fromJson(data['user'] ?? data),
    );
  }

  Future<BackendUser> register({
    required String orgName,
    required String contactEmail,
    required String password,
  }) async {
    final data = await _apiService.post('/auth/register', {
      'orgName': orgName,
      'contactEmail': contactEmail,
      'password': password,
    });

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid register response.');
    }

    return BackendUser.fromJson(data);
  }

  Future<BackendUser> getCurrentUser() async {
    final data = await _apiService.get('/me', authorized: true);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid user profile response.');
    }

    return BackendUser.fromJson(data);
  }
}
