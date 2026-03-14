import 'package:my_flutter_app/services/api_service.dart';
import 'package:my_flutter_app/models/auth_models.dart';

/// Service xử lý User Profile operations
class UserService {
  final ApiService _apiService = ApiService();

  /// Lấy thông tin profile của user hiện tại
  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiService.get(
        '/api/users/profile',
        authorized: true,
      );

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  /// Cập nhật profile
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiService.put(
        '/api/users/profile',
        request.toJson(),
        authorized: true,
      );

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Đổi mật khẩu
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.put(
        '/api/users/change-password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        authorized: true,
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  /// Xóa account (soft delete)
  Future<void> deleteAccount() async {
    try {
      await _apiService.delete(
        '/api/users/profile',
        authorized: true,
      );
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
