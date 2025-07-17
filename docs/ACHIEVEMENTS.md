# Achievement System Documentation

## Overview
The Drinkmod app now has a complete achievement system that rewards users for reaching milestones in their journey to manage their drinking habits.

## Architecture

### Core Components

1. **Achievement Model** (`achievement_model.dart`)
   - Defines the data structures for achievements and granted achievements
   - Includes JSON serialization for Hive storage
   - Categories: account, goal, milestone, streak

2. **Achievement Registry** (`achievement_registry.dart`)
   - Central definition of all available achievements
   - Currently includes 6 initial achievements:
     - First Goal: Creating your first goal
     - 1 Day Down: Account active for 1 day
     - 3 Days Down: Account active for 3 days  
     - 7 Days Down: Account active for 7 days
     - First Goal Completed: Completing a goal at 100%
     - First Goal Finished: Finishing a goal (any percentage)

3. **Assessment System**
   - **Base Assessor**: Common functionality for all assessors
   - **Account Assessor**: Evaluates account milestone achievements
   - **Goal Assessor**: Evaluates goal-related achievements
   - Modular design allows easy addition of new achievement types

4. **Achievement Manager** (`achievement_manager.dart`)
   - Main orchestration service
   - Handles assessment, granting, and storage
   - Manages modal notifications
   - Provides statistics and querying

5. **UI Components**
   - **Achievement Modal**: Animated notification when achievements are granted
   - **Achievement Badge**: Individual achievement display
   - **Achievements List View**: Full browser showing both unlocked and locked achievements
   - **Achievements Section**: Integration widget for progress screen

## Integration Points

### Main App Integration
- Global navigator key setup in `main.dart` for modal display
- Achievement checking integrated into goal creation and completion flows
- Onboarding completion triggers account milestone checks

### Progress Screen Integration
- Achievement section displays recent achievements as badges
- "View All" button navigates to full achievements list
- Replaces the previous "Coming Soon" achievement section

## Usage

### Simple Achievement Checking
```dart
// Check a single achievement
await AchievementHelper.checkAchievement('first_goal');

// Check multiple achievements
await AchievementHelper.checkMultiple(['1_day_down', '3_days_down', '7_days_down']);

// Common milestone checks
await AchievementHelper.checkAccountMilestones();
await AchievementHelper.checkGoalMilestones();
```

### Achievement Triggers
- **Account Creation**: Automatically triggers account milestone assessments
- **Goal Creation**: Triggers "first_goal" achievement check  
- **Goal Completion**: Triggers goal completion achievement checks
- **Screen Navigation**: Async checks when returning to Progress or Home screens
- **Persona Generation**: Account age achievements work correctly with backdated personas

### Account Age Achievement Details
The account age achievements (`1_day_down`, `3_days_down`, `7_days_down`) are calculated based on:
- **Storage Field**: `accountCreatedDate` (millisecond timestamp)
- **Assessment Method**: `UserDataService.getAccountCreatedDate()` 
- **Calculation**: `DateTime.now().difference(creationDate).inDays`
- **Persona Support**: PersonaDataService correctly backdates account creation for testing

**Example Persona Timeline**:
- "Mostly Sober Samuel" (90 days): Account created 90 days ago → Should trigger all account age achievements
- "Normal Norman" (60 days): Account created 60 days ago → Should trigger 1-day, 3-day, and 7-day achievements
- "Drunk Deirdre" (15 days): Account created 15 days ago → Should trigger 1-day, 3-day, and 7-day achievements

## Data Storage
- Uses Hive for local storage of granted achievements
- Achievements stored with timestamps and context
- Statistics tracking for total achievements, categories, etc.

## Future Enhancements
1. **Additional Achievement Categories**
   - Streak achievements (consecutive days)
   - Progress achievements (specific milestones)
   - Social achievements (sharing, etc.)

2. **Enhanced UI**
   - Achievement detail modals
   - Progress bars for upcoming achievements
   - Achievement sharing capabilities
   - Visual progress indicators for achievement chains

3. **Notification System**
   - Push notifications for achievements
   - Weekly/monthly achievement summaries

## Troubleshooting & Fixes

### Critical Issues Resolved

#### 1. Achievement Modal Display Issue
**Problem**: Achievements were being granted but modals weren't displaying to users.
**Root Cause**: `GoRouter` was creating its own navigator key instead of using the shared one from `main.dart`.
**Solution**: Modified `app_router.dart` to use `DrinkmodApp.navigatorKey` for proper modal overlay.

#### 2. Account Age Assessment Bug
**Problem**: Account age achievements (1-day, 3-day, 7-day) weren't triggering for personas with older creation dates.
**Root Cause**: `BaseAssessor.getAccountCreationDate()` was looking for a `createdAt` string field instead of using the proper `UserDataService.getAccountCreatedDate()` method.
**Fields Involved**:
- ✅ **UserDataService**: Stores `accountCreatedDate` as millisecond timestamp
- ✅ **PersonaDataService**: Correctly sets `accountCreatedDate` when creating test personas
- ❌ **BaseAssessor**: Was incorrectly looking for `createdAt` string field
**Solution**: Fixed `BaseAssessor` to use `_userService.getAccountCreatedDate()` method.

#### 3. Achievement Badge UI Alignment
**Problem**: Achievement badge text was pushing circular icons out of alignment.
**Solution**: Implemented fixed container sizing in `achievement_badge.dart`:
- Fixed width: 64px for badge containers
- Fixed height: 88px total (64px circle + 24px text)
- Consistent 8px spacing between badges

#### 4. Race Conditions in Achievement Checking
**Problem**: Achievement checks were running before user data was fully loaded.
**Solution**: Implemented async achievement checking with 500ms delays:
- `_checkAchievementsAsync()` method with `Future.delayed()`
- Integrated into `didChangeDependencies()` for screen transitions
- Applied to both `ProgressScreen` and `HomeScreen`

### Debugging Tools Used
- Comprehensive logging in `AchievementManager` for modal display
- Debug output in assessors showing account creation dates and calculations
- Storage verification logging to confirm achievements are being saved
- UI refresh mechanisms using `GlobalKey` for achievement sections

### Integration Patterns

#### Async Achievement Checking Pattern
```dart
Future<void> _checkAchievementsAsync() async {
  Future.delayed(const Duration(milliseconds: 500), () async {
    print('🏆 Checking achievements asynchronously');
    await AchievementHelper.checkMultiple([
      '1_day_down',
      '3_days_down', 
      '7_days_down',
      'first_goal',
    ]);
  });
}
```

#### Screen Integration Pattern
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _checkAchievementsAsync(); // Check when returning to screen
}
```

### Data Flow Verification
1. **Account Creation**: `UserDataService.completeOnboarding()` sets `accountCreatedDate` timestamp
2. **Persona Generation**: `PersonaDataService._updateAccountCreationDate()` backdate accounts correctly
3. **Achievement Assessment**: `BaseAssessor.getDaysSinceAccountCreation()` calculates from proper field
4. **Achievement Granting**: `AchievementManager._grantAchievement()` stores with context
5. **Modal Display**: Uses shared navigator key for proper overlay presentation
6. **UI Refresh**: Achievement sections refresh after granting new achievements

## Enhanced Achievements List View
The achievements list now displays both unlocked and locked achievements, helping users understand what they can work towards:

**Visual Design**:
- **Unlocked Section**: Full-color icons with check marks and unlock dates
- **Locked Section**: Greyed-out icons with "Locked" badges
- **Progress Indicator**: App bar shows "X of Y unlocked" count

**Organization**:
- Achievements grouped into "Unlocked" and "Work Towards" sections
- Locked achievements sorted by category and chain position
- Account milestones (1-day, 3-day, 7-day) appear in logical progression

**User Benefits**:
- Clear visibility of all available achievements
- Motivation to work towards specific goals
- Understanding of achievement progression and requirements

## Implementation Status
✅ Core architecture implemented
✅ Six initial achievements defined
✅ Assessment system working and debugged
✅ UI components created with proper alignment
✅ Integration with main app completed
✅ Data storage implemented and verified
✅ Modal notification system functional
✅ Navigator key sharing fixed
✅ Account age assessment corrected
✅ Race condition handling implemented
✅ Async achievement checking on multiple screens

The achievement system is now fully functional and properly debugged. All critical issues have been resolved, and the system reliably grants and displays achievements to users!
