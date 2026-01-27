import 'package:flutter/material.dart';
import 'package:my_flutter_app/constants/app_colors.dart';
import 'package:my_flutter_app/constants/app_strings.dart';

/// Utility class for showing snackbars
class SnackBarUtils {
  SnackBarUtils._(); // Private constructor

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.success, Icons.check_circle);
  }

  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.error, Icons.error);
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.info, Icons.info);
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.warning, Icons.warning);
  }

  /// Internal method to show snackbar
  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: AppStrings.close,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
