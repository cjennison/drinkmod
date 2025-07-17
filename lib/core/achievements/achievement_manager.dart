import 'dart:developer' as developer;
import 'package:flutter/material.dart';

import '../services/hive_core.dart';
import 'achievement_registry.dart';
import 'models/achievement_model.dart';
import 'assessors/account_assessor.dart';
import 'assessors/goal_assessor.dart';
import 'ui/achievement_modal.dart';

/// Main achievement management service
class AchievementManager {
  static AchievementManager? _instance;
  static AchievementManager get instance => _instance ??= AchievementManager._();
  
  AchievementManager._();
  
  final HiveCore _hiveCore = HiveCore.instance;
  
  // Global navigation key for showing modals
  static GlobalKey<NavigatorState>? navigatorKey;
  
  // Assessors for different achievement categories
  final AccountAssessor _accountAssessor = AccountAssessor();
  final GoalAssessor _goalAssessor = GoalAssessor();

  /// Check and potentially grant an achievement
  /// Usage: await AchievementManager.instance.checkAchievement('1_day_down');
  Future<bool> checkAchievement(String achievementId, {Map<String, dynamic>? context, bool showModal = true}) async {
    print('🏆 AchievementManager: Checking achievement "$achievementId"');
    
    try {
      // Check if already granted
      if (await hasGrantedAchievement(achievementId)) {
        print('⚠️ AchievementManager: Achievement "$achievementId" already granted');
        developer.log('Achievement $achievementId already granted', name: 'AchievementManager');
        return false;
      }

      // Get achievement definition
      final achievement = AchievementRegistry.getAchievement(achievementId);
      if (achievement == null) {
        print('❌ AchievementManager: Achievement "$achievementId" not found in registry');
        developer.log('Achievement $achievementId not found in registry', name: 'AchievementManager');
        return false;
      }

      // Check prerequisites
      final grantedIds = await getGrantedAchievementIds();
      if (!AchievementRegistry.canUnlock(achievementId, grantedIds)) {
        print('🔒 AchievementManager: Achievement "$achievementId" prerequisites not met');
        developer.log('Achievement $achievementId prerequisites not met', name: 'AchievementManager');
        return false;
      }

      print('🔍 AchievementManager: Assessing achievement "$achievementId"');
      
      // Assess achievement
      final result = await _assessAchievement(achievementId, context: context);
      
      print('📊 AchievementManager: Assessment result for "$achievementId": ${result.shouldGrant ? "GRANT" : "SKIP"}');
      print('📝 AchievementManager: Reason: ${result.reason}');
      
      if (result.shouldGrant) {
        // Grant the achievement
        await _grantAchievement(achievement, result.context);
        
        print('✅ AchievementManager: Achievement "${achievement.name}" granted successfully!');
        
        // Show modal if requested
        if (showModal) {
          print('🎉 AchievementManager: Showing achievement modal for "${achievement.name}"');
          await _showAchievementModal(achievement);
        }
        
        developer.log('Achievement granted: ${achievement.name}', name: 'AchievementManager');
        return true;
      } else {
        print('⏭️ AchievementManager: Achievement "$achievementId" not granted: ${result.reason}');
        developer.log('Achievement not granted: ${result.reason}', name: 'AchievementManager');
        return false;
      }
    } catch (e) {
      print('💥 AchievementManager: Error checking achievement "$achievementId": $e');
      developer.log('Error checking achievement $achievementId: $e', name: 'AchievementManager');
      return false;
    }
  }

  /// Check multiple achievements at once
  Future<List<String>> checkMultipleAchievements(List<String> achievementIds, {Map<String, dynamic>? context, bool showModals = true}) async {
    final granted = <String>[];
    
    for (final id in achievementIds) {
      final wasGranted = await checkAchievement(id, context: context, showModal: showModals);
      if (wasGranted) {
        granted.add(id);
      }
    }
    
    return granted;
  }

  /// Get all granted achievements
  Future<List<GrantedAchievement>> getGrantedAchievements() async {
    await _hiveCore.ensureInitialized();
    
    final grantedData = _hiveCore.achievementsBox.values.toList();
    print('📦 AchievementManager: Found ${grantedData.length} stored achievements');
    
    final granted = <GrantedAchievement>[];
    
    for (final data in grantedData) {
      print('🔍 AchievementManager: Processing achievement data: $data');
      final achievementId = data['achievementId'] as String;
      final achievement = AchievementRegistry.getAchievement(achievementId);
      
      if (achievement != null) {
        granted.add(GrantedAchievement.fromJson(
          Map<String, dynamic>.from(data),
          achievement,
        ));
        print('✅ AchievementManager: Successfully loaded achievement: ${achievement.name}');
      } else {
        print('❌ AchievementManager: Achievement not found in registry: $achievementId');
      }
    }
    
    // Sort by granted date (most recent first)
    granted.sort((a, b) => b.grantedAt.compareTo(a.grantedAt));
    
    print('🏆 AchievementManager: Returning ${granted.length} granted achievements');
    return granted;
  }

  /// Get recently granted achievements
  Future<List<GrantedAchievement>> getRecentAchievements({int limit = 5}) async {
    final all = await getGrantedAchievements();
    return all.take(limit).toList();
  }

  /// Check if specific achievement is granted
  Future<bool> hasGrantedAchievement(String achievementId) async {
    final granted = await getGrantedAchievementIds();
    return granted.contains(achievementId);
  }

  /// Get list of granted achievement IDs
  Future<List<String>> getGrantedAchievementIds() async {
    final granted = await getGrantedAchievements();
    return granted.map((g) => g.achievement.id).toList();
  }

  /// Get achievement statistics
  Future<Map<String, dynamic>> getAchievementStats() async {
    final granted = await getGrantedAchievements();
    final total = AchievementRegistry.getTotalCount();
    
    final byCategory = <AchievementCategory, int>{};
    for (final category in AchievementCategory.values) {
      byCategory[category] = granted.where((g) => g.achievement.category == category).length;
    }
    
    return {
      'total': total,
      'granted': granted.length,
      'percentage': total > 0 ? (granted.length / total * 100).round() : 0,
      'byCategory': byCategory,
      'recent': (await getRecentAchievements()).length,
      'firstGranted': granted.isNotEmpty ? granted.last.grantedAt.toIso8601String() : null,
      'lastGranted': granted.isNotEmpty ? granted.first.grantedAt.toIso8601String() : null,
    };
  }

  /// Clear all achievements (for testing)
  Future<void> clearAllAchievements() async {
    await _hiveCore.ensureInitialized();
    await _hiveCore.achievementsBox.clear();
    developer.log('All achievements cleared', name: 'AchievementManager');
  }

  // PRIVATE METHODS

  /// Assess achievement using appropriate assessor
  Future<AssessmentResult> _assessAchievement(String achievementId, {Map<String, dynamic>? context}) async {
    final achievement = AchievementRegistry.getAchievement(achievementId);
    if (achievement == null) {
      return const AssessmentResult.skip(reason: 'Achievement not found');
    }

    switch (achievement.category) {
      case AchievementCategory.account:
        return await _accountAssessor.assess(achievementId, context: context);
      case AchievementCategory.goals:
        return await _goalAssessor.assess(achievementId, context: context);
      default:
        return const AssessmentResult.skip(reason: 'No assessor for category');
    }
  }

  /// Grant achievement to user
  Future<void> _grantAchievement(Achievement achievement, Map<String, dynamic> context) async {
    await _hiveCore.ensureInitialized();
    
    final grantedId = 'granted_${DateTime.now().millisecondsSinceEpoch}';
    final grantedData = {
      'id': grantedId,
      'achievementId': achievement.id,
      'grantedAt': DateTime.now().toIso8601String(),
      'metadata': context,
    };
    
    print('💾 AchievementManager: Storing achievement data: $grantedData');
    await _hiveCore.achievementsBox.put(grantedId, grantedData);
    print('✅ AchievementManager: Achievement stored successfully');
    
    // Verify storage
    final stored = _hiveCore.achievementsBox.get(grantedId);
    print('🔍 AchievementManager: Verification - stored data: $stored');
  }

  /// Show achievement modal
  Future<void> _showAchievementModal(Achievement achievement) async {
    final context = navigatorKey?.currentContext;
    if (context != null) {
      try {
        await AchievementModal.show(context, achievement);
      } catch (e) {
        developer.log('Error showing achievement modal: $e', name: 'AchievementManager');
      }
    } else {
      // Fallback: just log the achievement
      developer.log('🏆 Achievement Unlocked: ${achievement.name}', name: 'AchievementManager');
    }
  }
}
