import 'package:flutter/material.dart';
import 'package:my_flutter_app/services/user_service.dart';
import 'package:my_flutter_app/models/auth_models.dart';

/// Provider quản lý User Profile state
class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _profile != null;

  /// Lấy profile của user hiện tại
  Future<void> fetchProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _profile = await _userService.getProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải profile: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Cập nhật profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final request = UpdateProfileRequest(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
      );

      _profile = await _userService.updateProfile(request);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Cập nhật profile thất bại: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Đổi mật khẩu
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Đổi mật khẩu thất bại: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Xóa account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _userService.deleteAccount();
      _profile = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Xóa tài khoản thất bại: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Clear profile khi logout
  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
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
