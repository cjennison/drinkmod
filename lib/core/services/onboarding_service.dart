import 'dart:developer' as developer;
import 'hive_database_service.dart';

/// Service to manage onboarding completion status and user data
class OnboardingService {
  static final HiveDatabaseService _hiveService = HiveDatabaseService.instance;

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      await _hiveService.initialize();
      return _hiveService.isOnboardingCompleted();
    } catch (e) {
      developer.log('Error checking onboarding completion: $e', name: 'OnboardingService');
      return false;
    }
  }

  /// Mark onboarding as completed and save user data
  static Future<void> completeOnboarding(Map<String, dynamic> userData) async {
    try {
      await _hiveService.initialize();
      await _hiveService.completeOnboarding(userData);
    } catch (e) {
      developer.log('Error completing onboarding: $e', name: 'OnboardingService');
    }
  }

  /// Get saved user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      await _hiveService.initialize();
      return _hiveService.getUserData();
    } catch (e) {
      developer.log('Error getting user data: $e', name: 'OnboardingService');
      return null;
    }
  }

  /// Update specific user data fields
  static Future<void> updateUserData(Map<String, dynamic> updates) async {
    try {
      await _hiveService.initialize();
      await _hiveService.updateUserData(updates);
    } catch (e) {
      developer.log('Error updating user data: $e', name: 'OnboardingService');
    }
  }

  /// Clear onboarding data (for testing purposes)
  static Future<void> clearOnboardingData() async {
    try {
      await _hiveService.initialize();
      await _hiveService.clearAllData();
    } catch (e) {
      developer.log('Error clearing onboarding data: $e', name: 'OnboardingService');
    }
  }

  /// Debug method to log current onboarding state
  static Future<void> debugOnboardingState() async {
    try {
      await _hiveService.initialize();
      final isCompleted = _hiveService.isOnboardingCompleted();
      final userData = _hiveService.getUserData();
      
      developer.log('=== ONBOARDING DEBUG STATE ===', name: 'OnboardingService');
      developer.log('Completion flag: $isCompleted', name: 'OnboardingService');
      developer.log('User data: $userData', name: 'OnboardingService');
      developer.log('==============================', name: 'OnboardingService');
    } catch (e) {
      developer.log('Error debugging onboarding state: $e', name: 'OnboardingService');
    }
  }
}
