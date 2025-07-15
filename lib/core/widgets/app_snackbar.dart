import 'package:flutter/material.dart';

/// Utility class for creating consistent snackbars that don't block bottom navigation
class AppSnackBar {
  
  /// Create a floating snackbar that doesn't block bottom navigation
  static SnackBar create({
    required String message,
    Color? backgroundColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    return SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(
        bottom: 100, // Fixed height to clear bottom nav
        left: 16,
        right: 16,
      ),
      duration: duration ?? const Duration(seconds: 2),
      action: action,
    );
  }
  
  /// Show a success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      create(
        message: message,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Show an error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      create(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Show a warning snackbar
  static void showWarning(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      create(
        message: message,
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: action,
      ),
    );
  }
  
  /// Show an info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      create(
        message: message,
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
