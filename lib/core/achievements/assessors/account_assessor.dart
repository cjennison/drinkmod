import '../models/achievement_model.dart';
import 'base_assessor.dart';

/// Assessor for account-based achievements (time-based milestones)
class AccountAssessor extends BaseAssessor {
  @override
  Future<AssessmentResult> assess(String achievementId, {Map<String, dynamic>? context}) async {
    switch (achievementId) {
      case '1_day_down':
        return await _assess1DayDown();
      case '3_days_down':
        return await _assess3DaysDown();
      case '7_days_down':
        return await _assess7DaysDown();
      default:
        return const AssessmentResult.skip(reason: 'Unknown account achievement');
    }
  }

  /// Check if account has been active for 1 day
  Future<AssessmentResult> _assess1DayDown() async {
    final daysSince = await getDaysSinceAccountCreation();
    
    if (daysSince >= 1) {
      return AssessmentResult.grant(
        context: {
          'daysSinceCreation': daysSince,
          'creationDate': await getAccountCreationDate(),
        },
        reason: 'Account active for $daysSince days',
      );
    }
    
    return AssessmentResult.skip(
      context: {'daysSinceCreation': daysSince},
      reason: 'Account only active for $daysSince days',
    );
  }

  /// Check if account has been active for 3 days
  Future<AssessmentResult> _assess3DaysDown() async {
    final daysSince = await getDaysSinceAccountCreation();
    
    if (daysSince >= 3) {
      return AssessmentResult.grant(
        context: {
          'daysSinceCreation': daysSince,
          'creationDate': await getAccountCreationDate(),
        },
        reason: 'Account active for $daysSince days',
      );
    }
    
    return AssessmentResult.skip(
      context: {'daysSinceCreation': daysSince},
      reason: 'Account only active for $daysSince days',
    );
  }

  /// Check if account has been active for 7 days
  Future<AssessmentResult> _assess7DaysDown() async {
    final daysSince = await getDaysSinceAccountCreation();
    
    if (daysSince >= 7) {
      return AssessmentResult.grant(
        context: {
          'daysSinceCreation': daysSince,
          'creationDate': await getAccountCreationDate(),
        },
        reason: 'Account active for $daysSince days',
      );
    }
    
    return AssessmentResult.skip(
      context: {'daysSinceCreation': daysSince},
      reason: 'Account only active for $daysSince days',
    );
  }
}
