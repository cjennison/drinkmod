import 'dart:developer' as developer;
import '../utils/map_utils.dart';
import 'hive_core.dart';

/// Service for managing user profile data and onboarding
class UserDataService {
  static UserDataService? _instance;
  static UserDataService get instance => _instance ??= UserDataService._();
  
  UserDataService._();
  
  final HiveCore _hiveCore = HiveCore.instance;
  
  /// Save user profile data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _hiveCore.ensureInitialized();
    
    await _hiveCore.userBox.put('profile', userData);
    developer.log('User data saved: $userData', name: 'UserDataService');
  }
  
  /// Get user profile data
  Map<String, dynamic>? getUserData() {
    if (!_hiveCore.isInitialized) return null;
    
    final data = _hiveCore.userBox.get('profile');
    return data != null ? MapUtils.deepConvertMap(data) : null;
  }
  
  /// Update specific user data fields
  Future<void> updateUserData(Map<String, dynamic> updates) async {
    await _hiveCore.ensureInitialized();
    
    final currentData = getUserData() ?? <String, dynamic>{};
    currentData.addAll(updates);
    
    await saveUserData(currentData);
    developer.log('User data updated: $updates', name: 'UserDataService');
  }
  
  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    final userData = getUserData();
    if (userData == null) return false;
    
    // Check for required fields
    final requiredFields = ['name', 'gender', 'schedule', 'drinkLimit', 'motivation'];
    
    for (final field in requiredFields) {
      if (!userData.containsKey(field) || 
          userData[field] == null || 
          (userData[field] is String && (userData[field] as String).isEmpty)) {
        return false;
      }
    }
    
    return userData['onboardingCompleted'] == true;
  }
  
  /// Mark onboarding as completed
  Future<void> completeOnboarding(Map<String, dynamic> userData) async {
    userData['onboardingCompleted'] = true;
    
    // Add account creation date if not already present
    if (!userData.containsKey('accountCreatedDate')) {
      userData['accountCreatedDate'] = DateTime.now().millisecondsSinceEpoch;
      developer.log('Account created date set: ${DateTime.now()}', name: 'UserDataService');
    }
    
    await saveUserData(userData);
    developer.log('Onboarding completed', name: 'UserDataService');
  }
  
  /// Get account creation date
  DateTime? getAccountCreatedDate() {
    final userData = getUserData();
    if (userData == null) return null;
    
    final timestamp = userData['accountCreatedDate'];
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    // Fallback: if no creation date stored, assume account is new (today)
    return DateTime.now();
  }

  /// Check if a date is before account creation (prevents logging drinks in the past)
  bool isDateBeforeAccountCreation(DateTime date) {
    final accountCreatedDate = getAccountCreatedDate();
    if (accountCreatedDate == null) return false;
    
    // Compare only the date parts (ignore time)
    final checkDate = DateTime(date.year, date.month, date.day);
    final creationDate = DateTime(accountCreatedDate.year, accountCreatedDate.month, accountCreatedDate.day);
    
    return checkDate.isBefore(creationDate);
  }

  /// Get formatted account creation date for display
  String getFormattedAccountCreationDate() {
    final accountCreatedDate = getAccountCreatedDate();
    if (accountCreatedDate == null) return 'recently';
    
    // Format as "July 15, 2025"
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[accountCreatedDate.month - 1]} ${accountCreatedDate.day}, ${accountCreatedDate.year}';
  }
}
