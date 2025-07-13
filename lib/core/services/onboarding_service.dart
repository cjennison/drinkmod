import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding completion status and user data
class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _userDataKey = 'user_data';

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      print('Error checking onboarding completion: $e');
      return false;
    }
  }

  /// Mark onboarding as completed and save user data
  static Future<void> completeOnboarding(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
      await prefs.setString(_userDataKey, jsonEncode(userData));
      print('Onboarding completed with data: $userData');
    } catch (e) {
      print('Error completing onboarding: $e');
    }
  }

  /// Get saved user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Clear onboarding data (for testing purposes)
  static Future<void> clearOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);
      await prefs.remove(_userDataKey);
      print('Onboarding data cleared');
    } catch (e) {
      print('Error clearing onboarding data: $e');
    }
  }
}
