# Drinkmod - Project Development Plan

## Product Overview
Drinkmod is a Flutter/Dart mobile application designed to help users practice alcohol moderation through goal-setting, tracking, and positive reinforcement. The app focuses on empowerment and control rather than shame, providing therapeutic guidance for sustainable drinking habit management.

## Core Therapeutic Principles Integrated
- **Harm Reduction**: Focus on reducing negative consequences rather than complete abstinence
- **Self-Efficacy**: Empowering users with control and choice
- **Mindful Drinking**: Encouraging awareness and intentional consumption
- **Progress Recognition**: Celebrating improvements and milestones
- **Urge Management**: Providing tools to handle cravings therapeutically
- **Social Support**: Optional sharing for accountability and celebration

## Additional Requirements for Therapeutic Effectiveness

### Essential Features (Added to Requirements)
1. **Drink Definition Standards**: Integration with standard drink equivalencies (14g alcohol = 1 standard drink)
2. **Reflection Prompts**: Post-drinking reflection questions to build awareness
3. **Trigger Pattern Recognition**: Analytics to help users identify drinking triggers
4. **Emergency Support**: Quick access to crisis resources and support contacts
5. **Progress Visualization**: Charts and graphs showing improvement trends
6. **Educational Content**: Brief tips about moderation and health benefits
7. **Flexible Goal Adjustment**: Easy modification of goals based on progress
8. **Anonymous Data Backup**: Secure, private data storage and recovery

## Mobile & Therapeutic Design Principles

### Mobile-First UX Requirements
1. **One-Handed Operation**: All primary functions accessible within thumb reach
2. **Quick Access Patterns**: Critical features (logging, crisis support) ≤ 2 taps from any screen
3. **Gesture-Driven Navigation**: Swipe patterns for common actions and quick shortcuts
4. **Offline-First Architecture**: Core functionality available without internet connection
5. **Biometric Security**: Face ID/Touch ID protection for sensitive addiction data
6. **Discrete Usage**: Option for stealth mode and private notifications
7. **Voice Accessibility**: Voice commands for hands-free logging and navigation
8. **Haptic Feedback**: Subtle vibrations for confirmations and positive reinforcement

### Therapeutic UX Requirements
1. **Empowerment Language**: All copy focuses on user control and positive choice
2. **Non-Judgmental Design**: No shame-inducing colors, icons, or messaging
3. **Crisis-Aware Architecture**: Emergency support accessible from every screen
4. **Progress-Focused**: Celebrate any positive change, however small
5. **Mindfulness Integration**: Built-in moments for reflection and awareness
6. **Harm Reduction Support**: Tools and resources for high-risk situations
7. **Personalization**: Adaptive messaging based on user patterns and preferences
8. **Privacy by Design**: Anonymous usage options and comprehensive data protection

### Addiction-Informed Technical Requirements
1. **Real-Time Pattern Recognition**: ML algorithms for early intervention triggers
2. **Behavioral Data Capture**: Comprehensive logging of context, mood, and triggers
3. **Therapeutic Intervention System**: Automated support delivery based on risk indicators
4. **Crisis Escalation Protocols**: Clear pathways from app to professional support
5. **Evidence-Based Content**: All therapeutic interventions based on clinical research
6. **Data Portability**: Export capabilities for sharing with healthcare providers
7. **Relapse Recovery Features**: Immediate support and positive reframing after setbacks
8. **Long-Term Sustainability**: Features supporting months/years of continued use

## Development Stages

### Stage 1: Foundation & Core Infrastructure ✅ COMPLETED
**Objective**: Establish basic app structure and core data models
**Duration**: 2-3 weeks
**Status**: Complete

#### Features Implemented:
- ✅ Flutter project setup with proper architecture (BLoC pattern)
- ✅ Core data models (Users, DrinkSchedules, DrinkEntries, FavoriteDrinks, Milestones)
- ✅ Local database setup (Drift ORM with cross-platform support)
- ✅ Basic navigation structure (go_router implementation)
- ✅ App theme and design system setup (Material Design 3)
- ✅ Standard drink calculation utilities

#### Deliverables Completed:
- ✅ Functioning app shell with navigation
- ✅ Data persistence layer with platform-specific database connections
- ✅ Basic UI components and theme
- ✅ Unit tests for core models (7/7 passing)

#### Acceptance Criteria Met:
- ✅ App launches without crashes on web and native platforms
- ✅ Basic data models can be saved and retrieved via Drift ORM
- ✅ Navigation between screens works with go_router
- ✅ Code follows Flutter best practices

#### Technical Implementation Details:
- **Architecture**: BLoC pattern with MultiRepositoryProvider setup
- **Database**: Drift ORM 2.27.0 with conditional imports for web/native
- **Navigation**: go_router 14.8.1 with proper route structure
- **Theme**: Material Design 3 with therapeutic color palette
- **Testing**: Unit tests for drink calculator utilities
- **Platform Support**: Web (IndexedDB) and Native (SQLite) database implementations

---

### Stage 2: Onboarding & Initial Setup ✅ COMPLETED
**Objective**: Create user onboarding flow for goal and schedule setup
**Duration**: 2-3 weeks
**Status**: Complete with All 7 Steps Implemented

#### ✅ Full Implementation Completed:
- **Complete Conversational Flow**: All 7 onboarding steps with Mara's guidance
- **Data Collection**: Name/gender, motivation, drinking patterns, favorite drinks, schedule preferences, drink limits
- **Smart Recommendations**: AI-driven schedule and limit suggestions based on user patterns
- **UI Polish**: Persistent typewriter effects, proper scrolling, 33% bottom padding
- **Input Management**: Seamless input card replacement with compact response displays
- **Progress Tracking**: Step-by-step progress indicator throughout the flow

#### 🎯 All 7 Onboarding Steps:
1. **Name & Identity Collection**: Personal introduction with gender preferences
2. **Motivation Assessment**: 9 motivation categories plus custom option
3. **Drinking Patterns Analysis**: Frequency and amount assessment
4. **Favorite Drinks Collection**: Multi-select with custom drink addition
5. **Schedule Recommendations**: AI-generated suggestions with 5 schedule options
6. **Drink Limit Setting**: Interactive slider with health guidance (1-6 drinks)
7. **Plan Summary & Completion**: Personalized plan review and journey kickoff

#### 🔧 Technical Improvements Applied:
- **Enhanced Scrolling**: Automatic scroll-to-bottom on new elements
- **Responsive Padding**: 33% bottom whitespace for better UX
- **Performance Optimized**: Message completion persistence across scroll events
- **Smart UI Flow**: Dynamic input validation and progressive disclosure
- **Therapeutic Messaging**: Consistent supportive tone throughout experience

#### 🎨 UX Enhancements:
- **Clean Interface**: GPT-style conversation without chat bubbles
- **Intelligent Recommendations**: Context-aware suggestions based on user input
- **Validation Feedback**: Real-time input validation with helpful guidance
- **Smooth Animations**: Optimized typewriter speed (25ms) for engagement
- **Accessible Design**: Clear visual hierarchy and interaction patterns

#### Conversation Flow & Data Collection:

**1. Initial Welcome & Name Collection**
```
Mara: "Hey."
Mara: "I'm glad you're here."
Mara: "Can you tell me your name, or how you like to be called?"
[Input: Text field for name + preferred gender selection]
```

**2. Introduction & Safety**
```
Mara: "Nice to meet you [Name]."
Mara: "We're going to work on moderating your alcohol consumption."
Mara: "This is a safe place, and none of this information is shared with anyone."
```

**3. Motivation Collection**
```
Mara: "Can you tell me why you want to moderate your consumption?"
[Input: Dropdown with common reasons + "Other" text field]
- Health concerns
- Financial reasons
- Relationship impact
- Work/productivity
- Personal control
- Other (custom text)
```

**4. Current Drinking Pattern Assessment**
```
Mara: "Let's talk about your current drinking patterns."
Mara: "How often do you typically drink?"
[Input: Frequency selector - Daily, 5-6x/week, 3-4x/week, 1-2x/week, Occasionally]

Mara: "And on days when you do drink, how much would you say you have?"
[Input: Amount selector with standard drink equivalents]
```

**5. Favorite Drinks Collection (Playful & Value-Positive)**
```
Mara: "Now let's talk about the fun part - what do you love to drink?"
Mara: "I want you to still enjoy your drinks, we're just working on control."
Mara: "What's your go-to drink when you want to treat yourself?"
[Input: Searchable drink library + custom entry with standard drink calculation]

Mara: "Any other favorites? The more we know, the better I can help you plan."
[Input: Add multiple favorite drinks]
```

**6. Schedule Recommendation Based on Current Pattern**
```
Mara: "Based on what you've told me, I have some recommendations."
Mara: "Currently you drink [frequency]. Let's aim for [recommended frequency]."

Recommendation Logic:
- Daily → 3x per week (low-impact schedule)
- 5-6x/week → Weekends only + one weekday
- 3-4x/week → Weekends only (Friday-Sunday)
- 1-2x/week → Same frequency, focus on amount control
- Occasionally → Same frequency, reinforce positive patterns

[Input: Schedule preference selector with Mara's recommendation highlighted]
- Weekends Only (Friday-Sunday) [RECOMMENDED]
- Friday Only
- Social Occasions Only
- Custom Weekly Pattern
- Keep Current Pattern (with amount limits)
```

**7. Amount Preference Setting**
```
Mara: "How many drinks would you like to limit yourself to on drinking days?"
Mara: "I recommend [X] drinks based on your current pattern and goals."

Recommendation Logic:
- Consider current consumption
- Factor in health guidelines (1-2 drinks for moderation)
- Adjust based on motivation (health vs. control reasons)

[Input: Drink limit slider with recommendation marked]
```

#### Features to Implement:
- Agentic chat interface with typewriter text effect
- JSON script system for conversation management
- Dynamic data collection within chat flow
- Intelligent schedule recommendations based on current patterns
- Playful favorite drinks collection
- Shared UI component library (inputs, buttons, cards)
- Real-time validation and feedback
- Progress indicator showing onboarding completion

#### Predefined Schedule Options:
- Weekends Only (Friday-Sunday)
- Friday Only
- Social Occasions Only
- Custom Weekly Pattern
- Reduced Current Pattern (algorithmically determined)

#### Shared UI Components to Develop:
- **ChatBubble**: Agent message display with typewriter effect
- **InputCard**: Consistent input styling for forms within chat
- **DrinkSelector**: Reusable drink selection with standard drink calculation
- **ScheduleCard**: Visual schedule selection with recommendations
- **ProgressIndicator**: Onboarding completion status
- **ActionButton**: Consistent button styling throughout app

#### Deliverables:
- Complete agentic onboarding flow with Mara
- JSON script management system
- Typewriter effect text animation
- Schedule recommendation algorithm
- Favorite drinks management with standard drink integration
- Data validation and error handling
- Shared UI component library

#### Acceptance Criteria:
- Users can complete onboarding start to finish in a conversational flow
- Mara's typewriter text effect creates engaging, human-like interaction
- All schedule types can be configured with intelligent recommendations
- Drink limits are properly validated and explained therapeutically
- Favorite drinks can be added with accurate standard drink calculations
- Shared UI components are consistent and reusable across the app
- JSON script system allows easy conversation updates without code changes
- Onboarding feels warm, supportive, and non-judgmental throughout

#### 🔄 Stage 2 JSON Content Management ✅ COMPLETED
**Status**: Implemented - JSON Script System Active
**Implementation**: Conversation content extracted to JSON with dynamic loading

##### ✅ Completed Implementation:
- **JSON Script System**: All conversation content moved to `assets/scripts/onboarding_script.json`
- **Dynamic Content Loading**: ScriptManager service loads JSON scripts at runtime
- **Conversation Engine**: OnboardingController processes JSON flows with typewriter effects
- **Performance Optimized**: Faster typing speeds (10ms) and reduced delays (200-400ms)
- **Content Versioning**: JSON structure supports easy therapeutic messaging updates

##### JSON Structure Implemented:
```json
{
  "flows": {
    "welcome": {
      "messages": ["Hey.", "I'm glad you're here.", "..."],
      "delay": 200,
      "input_type": "name_and_gender"
    }
  },
  "typewriter_config": {
    "base_speed": 10,
    "punctuation_pause": 200
  }
}
```

##### Benefits Achieved:
- **Non-Developer Updates**: Content updates via JSON without code changes
- **Performance Improved**: Faster user experience through optimized timing
- **Content Management**: Clean separation between logic and therapeutic messaging
- **UI Optimization**: Reduced form heights and improved space utilization
- **Scalable Architecture**: Foundation ready for additional conversation flows

---

### Stage 2.5: Main App Layout & Navigation Structure ✅ COMPLETED
**Objective**: Implement foundational app navigation with Material Design 3 and 2025 Flutter best practices
**Duration**: 1-2 weeks
**Status**: Complete - All Core Features Implemented
**Prerequisite**: Stage 2 JSON Content Management Complete ✅

#### ✅ Implementation Completed:
- **Material Design 3 Navigation**: Complete bottom navigation with M3 Expressive design patterns
- **MainLayout Architecture**: Centralized navigation using PageView with proper state management
- **SafeArea Protection**: Full screen edge protection for notches, status bars, and keyboard areas
- **Profile Screen**: Complete user data management with go_router navigation integration
- **Modern Flutter Standards**: 2025 development practices with proper error handling
- **Cross-Platform Support**: Responsive design adapting to different screen sizes and orientations

#### 🎯 All Core Features Implemented:
- **Material Design 3 Navigation**: Bottom navigation bar with M3 Expressive design patterns
- **SafeArea Implementation**: Proper screen edge protection for notches, status bars, and keyboard areas
- **Adaptive Layout**: Responsive design that adapts to different screen sizes and orientations
- **Profile Screen**: Complete user data management with edit capabilities and reset functionality
- **Modern Flutter Architecture**: 2025 development standards with proper state management

#### 📱 Navigation Structure (Material Design 3):
```
Bottom Navigation Bar (3-5 destinations max per M3 guidelines):
├── Home (Dashboard) - Primary user landing
├── Track (Daily logging) - Core functionality access
├── Progress (Analytics) - Streak and milestone views  
├── Profile (Settings) - User management and data controls
```

#### 🔧 Technical Implementation Standards:
- **SafeArea Wrapping**: Scaffold body wrapped in SafeArea for proper screen protection
- **Keyboard Handling**: Automatic keyboard area protection for input fields
- **Responsive Breakpoints**: Material Design window size classes for adaptive layouts
- **State Preservation**: PageStorageKey for maintaining scroll positions across navigation
- **Touch-First Design**: Optimized for touch interaction with mouse/keyboard as acceleration

#### 🎨 Design Principles Applied:
- **M3 Expressive Navigation**: Shorter height navigation bars with pill-shaped active indicators
- **Adaptive vs Responsive**: UI fits available space rather than just being usable in space
- **Touch Interface Priority**: Primary interaction model optimized for touch with other inputs as accelerators
- **Consistent Visual Density**: Appropriate spacing and sizing for mobile form factor
- **Accessibility Support**: Proper semantic navigation and screen reader compatibility

#### 📋 Profile Screen Features:
- **User Data Display**: Name, gender, motivation, drinking patterns, and favorite drinks
- **Edit Capabilities**: Inline editing for all user preferences and settings
- **Schedule Management**: Modify drinking schedule and limits with visual feedback
- **Data Reset Options**: Complete onboarding restart with proper data cleanup
- **Settings Access**: App preferences, privacy controls, and account management

#### 🔄 Data Management Architecture:
- **SharedPreferences**: Simple app settings, onboarding completion status, user preferences
- **Drift Database**: Complex relational data (drink entries, schedules, milestones, analytics)
- **Clear Separation**: Logical data layer boundaries for maintainable architecture
- **Cross-Platform Storage**: Proper web/mobile data persistence with platform-specific optimizations

#### 🛡️ SafeArea & Responsive Implementation:
```dart
// Scaffold with proper SafeArea implementation
Scaffold(
  body: SafeArea(
    child: PageView(
      controller: _pageController,
      children: [
        HomeScreen(),
        TrackScreen(), 
        ProgressScreen(),
        ProfileScreen(),
      ],
    ),
  ),
  bottomNavigationBar: NavigationBar(
    // M3 Expressive navigation with adaptive design
    destinations: [/* navigation destinations */],
  ),
)
```

#### 📊 Layout Best Practices Applied:
- **No Orientation Locking**: Supports both portrait and landscape modes
- **MediaQuery Usage**: Uses window size rather than device type for layout decisions
- **Flexible Navigation**: Bottom nav adapts to content without fixed assumptions
- **Input Device Support**: Keyboard navigation and mouse interaction support
- **State Restoration**: Maintains app state through orientation changes and window resizing

#### 🔀 Navigation Flow Integration:
- **Onboarding → Main App**: Seamless transition after onboarding completion
- **Deep Navigation**: Each tab maintains its own navigation stack
- **Context Preservation**: User location and state maintained across app sections
- **Logical Flow**: Intuitive user journey from tracking to progress to profile management

#### ✅ Acceptance Criteria Completed:
- ✅ Bottom navigation follows Material Design 3 guidelines with proper M3 Expressive styling
- ✅ SafeArea properly protects content from device intrusions and system UI
- ✅ Profile screen allows complete user data management including onboarding reset via go_router
- ✅ App adapts to different screen sizes and orientations without layout breaks
- ✅ Navigation state is preserved across app lifecycle events with PageView controller
- ✅ Touch interactions are optimized with appropriate touch targets and feedback
- ✅ All screens maintain consistent visual design and interaction patterns
- ✅ go_router integration prevents navigation conflicts and provides proper declarative routing
- ✅ Onboarding reset functionality works correctly without imperative navigation crashes
- ✅ Dashboard provides engaging user experience with personalized content and quick actions
- ✅ iOS device testing successful - app runs smoothly on iPhone (iOS 18.5)
- ✅ Cross-platform compatibility confirmed for web and iOS platforms

#### 🚀 2025 Flutter Standards Implemented:
- **VS Code F5 Debugging**: Primary development workflow without terminal commands
- **Modern API Usage**: No deprecated Flutter APIs, updated to latest 3.32.6 standards
- **Performance Optimizations**: Const widgets, efficient rebuilds, lazy loading
- **Accessibility Compliance**: Semantic widgets, screen reader support, focus management
- **Cross-Platform Consistency**: Shared codebase with platform-specific optimizations

#### 📝 Deliverables Completed:
- **MainLayout Component**: `/lib/features/main/screens/main_layout.dart` - Central navigation hub
- **Screen Components**: TrackingScreen, ProgressScreen, ProfileScreen with placeholder content
- **Navigation Integration**: Updated app_router.dart to use MainLayout instead of individual HomeScreen
- **Profile Functionality**: Complete user data display, editing interface, and onboarding reset
- **Dashboard Enhancement**: Updated HomeScreen with welcome cards, quick stats, and action buttons
- **go_router Integration**: Proper navigation flow from onboarding to main app using declarative routing
- **Error Resolution**: Fixed navigation conflicts between imperative and declarative routing patterns

#### 🔧 Technical Achievements:
- **Navigation Architecture**: PageView-based navigation with smooth transitions and state preservation
- **M3 Navigation Bar**: Proper Material Design 3 styling with pill-shaped indicators and adaptive height
- **SafeArea Implementation**: Comprehensive protection from device intrusions across all screens
- **User Data Management**: Complete profile screen with reset functionality using proper go_router navigation
- **Responsive Design**: Adaptive layouts supporting multiple screen sizes and orientations
- **Performance Optimization**: Efficient page transitions and proper widget disposal patterns

#### 🎨 UX Improvements Applied:
- **Dashboard Enhancement**: Personalized welcome messages with user name integration
- **Quick Stats Display**: Placeholder streak counter and daily limit cards for future data integration
- **Action Buttons**: Primary and secondary call-to-action buttons for key user journeys
- **Profile Management**: Intuitive data display with edit capabilities and clear reset workflow
- **Navigation Consistency**: Uniform app bar styling and consistent interaction patterns
- **Error Prevention**: Proper go_router usage preventing navigation conflicts and crashes

#### 📱 iOS Device Testing ✅ COMPLETED:
- **Real Device Testing**: Successfully built and deployed to iPhone (iOS 18.5)
- **Code Signing**: Configured Apple Developer account and certificates for device testing
- **Cross-Platform Validation**: App functions correctly on both web and iOS platforms
- **Material Design 3**: Proper rendering of M3 components on iOS device
- **Navigation Flow**: Confirmed onboarding → main app transition works on iOS
- **Performance**: Smooth animations and responsive UI on physical device

---

### Stage 3: Core Tracking & Control Panel ⚙️ IN PROGRESS
**Objective**: Implement therapeutically-informed main dashboard and drinking tracking with mobile-first UX
**Duration**: 4-5 weeks (Extended for therapeutic depth)
**Status**: In Progress - Schedule System & Dashboard Enhancement

#### ✅ Completed Implementation:

##### 🎯 Schedule Type System (COMPLETED)
- **Schedule Classification**: Added `scheduleTypeStrict` and `scheduleTypeOpen` constants
- **Strict Schedules**: Day-specific restrictions (Weekends, Fridays only)
- **Open Schedules**: Flexible daily drinking with weekly limits (disabled in profile for now)
- **Profile Restrictions**: Limited to strict schedules only (Weekends/Fridays) until weekly limit system implemented

##### 📅 Date & Schedule Integration (COMPLETED)
- **Current Date Display**: Added formatted date display to home screen using `intl` package
- **Schedule Checking**: Implemented `isDrinkingDay()` method in HiveDatabaseService
- **Drinking Day Logic**: Weekends = Fri/Sat/Sun, Friday Only = Friday
- **Permission System**: `canAddDrinkToday()` checks both schedule and daily limits

##### 🏠 Enhanced Dashboard Features (COMPLETED)
- **Real-Time Status**: Dashboard now reflects schedule-aware drinking permissions  
- **Therapeutic Messaging**: Different messages for non-drinking days vs. limit reached
- **Smart Quick Logging**: Blocks logging on non-drinking days with supportive messaging
- **Remaining Drinks**: Accurate calculation based on schedule and current consumption

#### 🔧 Technical Implementation Details:

##### Database Service Enhancements:
```dart
// New methods in HiveDatabaseService:
bool isDrinkingDay({DateTime? date})           // Check schedule compliance
bool canAddDrinkToday({DateTime? date})        // Combined schedule + limit check
int getRemainingDrinksToday({DateTime? date})  // Accurate remaining count
bool _isStrictScheduleDrinkingDay()            // Weekday logic for strict schedules
```

##### Schedule Type Constants:
```dart
static const Map<String, String> scheduleTypeMap = {
  scheduleWeekendsOnly: scheduleTypeStrict,     // Fri/Sat/Sun only
  scheduleFridayOnly: scheduleTypeStrict,       // Friday only  
  scheduleSocialOccasions: scheduleTypeOpen,    // Any day (disabled)
  scheduleCustomWeekly: scheduleTypeOpen,       // Custom days (disabled)
  scheduleReducedCurrent: scheduleTypeOpen,     // Reduced pattern (disabled)
};
```

##### Enhanced Features to Implement:

##### 📱 Mobile-Optimized Drink Logging
- **One-Tap Quick Log**: Favorite drinks accessible within 1 tap from any screen
- **Progressive Disclosure**: Basic log → detailed entry → reflection prompts
- **Smart Defaults**: Pre-filled based on time of day, location, and historical patterns
- **Undo Functionality**: 30-second undo window for accidental entries
- **Offline Capability**: Full logging functionality without internet connection

##### 🧠 Therapeutic Logging Enhancement
- **Mindful Check-ins**: "How are you feeling?" before and after logging
- **Intention Setting**: "What's your plan for this drink?" with guided options
- **Context Capture**: Automatic time, estimated location category, social context
- **Reflection Prompts**: Post-drink "How did that feel?" with therapeutic framing
- **Trigger Awareness**: Optional quick trigger identification during logging

##### ⚡ Real-Time Therapeutic Interventions
- **Pre-Limit Gentle Nudges**: "You have 1 drink left today. How are you feeling?"
- **Over-Limit Support**: Compassionate messaging without shame or judgment
- **Urge Surfing Triggers**: Quick access to urge management when approaching limits
- **Celebration Moments**: Positive reinforcement for staying within limits
- **Micro-Reflections**: Brief therapeutic check-ins throughout the day

##### 📊 Intelligent Dashboard Elements
- **Adaptive Goal Display**: Shows today's specific schedule (drinking day vs. non-drinking day)
- **Streak Visualization**: Current streak with next milestone progress
- **Weekly Pattern View**: Last 7 days at-a-glance with trend indicators
- **Mood Integration**: Simple mood tracking correlated with drinking patterns
- **Success Indicators**: Visual celebration of adherence and positive choices

##### 🎨 Mobile UX Enhancements
- **Gesture Navigation**: Swipe patterns for common actions (log drink, view history)
- **Haptic Feedback**: Subtle vibrations for confirmations and celebrations
- **Dark Mode Optimization**: OLED-friendly dark theme for evening use
- **One-Handed Use**: All primary functions accessible with thumb reach
- **Voice Commands**: Optional voice logging for accessibility and convenience

##### 🔒 Privacy & Security Features
- **Biometric Lock**: Face ID/fingerprint protection for sensitive data
- **Stealth Mode**: Discrete app icon and notification options
- **Data Encryption**: Local database encryption for sensitive information
- **Anonymous Mode**: Option to use app without identifying information
- **Emergency Data Wipe**: Quick data deletion in crisis situations

##### 📈 Early Analytics Foundation
- **Adherence Tracking**: Daily/weekly adherence rates with trend analysis
- **Pattern Recognition**: Time-of-day, day-of-week drinking patterns
- **Trigger Correlation**: Basic correlation between triggers and consumption
- **Goal Adjustment Alerts**: Suggestions when patterns indicate goal misalignment
- **Progress Momentum**: Visual indicators of positive trajectory

##### 🚨 Crisis Prevention Features
- **Escalation Detection**: Algorithm to identify concerning patterns
- **Emergency Contacts**: Quick access to support person or crisis line
- **Therapist Communication**: Optional data sharing with healthcare providers
- **Harm Reduction Resources**: Information for high-risk situations
- **Crisis Plan Integration**: Personal crisis management plan access

#### Mobile-First Dashboard Layout:
```
┌─────────────────────────────────┐
│ Good morning, [Name]! 🌅        │ ← Personalized greeting
│ Day 12 streak • Today: 2 drinks │ ← Status bar
├─────────────────────────────────┤
│ ● ● ○ ○                        │ ← Visual allowance
│ "Remaining: 2 drinks"           │ ← Clear language
│ Example: 2 beers OR 1 cocktail  │ ← Concrete examples
├─────────────────────────────────┤
│ [📝 Log a Drink] [📊 Progress] │ ← Primary actions
├─────────────────────────────────┤
│ This Week: ████░░░ 5/7 days    │ ← Weekly view
│ Feeling: 😊 | Urges: Low       │ ← Mood integration
└─────────────────────────────────┘
```

#### Drink Logging Flow (Mobile-Optimized):
1. **Quick Entry**: Tap favorite drink → Confirm → Done (3 taps total)
2. **Detailed Entry**: Add drink → Select amount → Add context → Reflection
3. **Mindful Mode**: Pre-drink intention → Log drink → Post-drink reflection
4. **Emergency Mode**: Crisis resources → Harm reduction → Support contact

#### Therapeutic Messaging Framework:
- **Empowerment Language**: "You're in control" vs. "Don't drink"
- **Progress Focus**: Celebrate any positive change, no matter how small
- **Non-Judgmental**: "Notice what happened" vs. "You failed"
- **Forward-Looking**: "What would help you tomorrow?" vs. dwelling on mistakes
- **Strength-Based**: Highlight user's existing coping skills and resources

#### Advanced Features for Stage 3:
- **Smart Notifications**: ML-driven personalized reminder timing
- **Location Awareness**: Automatic context detection (home, work, social)
- **Calendar Integration**: Sync with phone calendar for event-based planning
- **Weather Correlation**: Track weather patterns with drinking behaviors
- **Exercise Integration**: Connect with health apps for holistic view

#### Data Models to Implement:
```dart
// Enhanced DrinkEntry model
class DrinkEntry {
  String id;
  DateTime timestamp;
  String drinkId; // References FavoriteDrink
  double amount; // Standard drinks
  String? location; // Home, Work, Social, Other
  List<String>? triggers; // Emotional, Social, Environmental
  int? moodBefore; // 1-10 scale
  int? moodAfter; // 1-10 scale
  String? intention; // Pre-drink intention
  String? reflection; // Post-drink reflection
  bool isWithinLimit; // Calculated field
  Map<String, dynamic>? metadata; // Extensible data
}

// Mood tracking
class MoodEntry {
  String id;
  DateTime timestamp;
  int mood; // 1-10 scale
  List<String>? tags; // Happy, Stressed, Anxious, etc.
  String? note; // Optional reflection
}

// Quick trigger tracking
class TriggerEntry {
  String id;
  DateTime timestamp;
  String category; // Emotional, Social, Environmental, Physical
  String specific; // Stress, Boredom, Social pressure, etc.
  int intensity; // 1-10 scale
  bool didDrink; // Whether user drank after trigger
  String? copingStrategy; // What they did instead
}
```

#### Deliverables:
- **Therapeutically-informed main dashboard** with empowering UX
- **Mobile-optimized drink logging system** with progressive disclosure
- **Real-time therapeutic interventions** and support features
- **Privacy and security features** for sensitive data protection
- **Early analytics foundation** for pattern recognition
- **Crisis prevention features** with emergency support access
- **Comprehensive data models** supporting therapeutic goals

#### Acceptance Criteria:
- ✅ Dashboard accurately reflects current allowance with therapeutic messaging
- ✅ Drink logging is accessible within 2 taps maximum from any screen
- ✅ Data updates immediately after logging with positive reinforcement
- ✅ Clear visual feedback for all states using empowering language
- ✅ Mobile-first design supports one-handed use and gesture navigation
- ✅ Privacy features protect sensitive information with biometric security
- ✅ Therapeutic interventions provide support without judgment
- ✅ Crisis prevention features are accessible within emergency timeframes
- ✅ Analytics foundation captures data needed for later pattern recognition
- ✅ Offline functionality maintains core features without internet connection

#### Success Metrics for Stage 3:
- **Engagement**: Daily active usage rates and session duration
- **Therapeutic Effectiveness**: Adherence improvement rates after implementation
- **User Experience**: Task completion rates for logging and dashboard navigation
- **Crisis Prevention**: Early warning system accuracy and intervention effectiveness
- **Data Quality**: Completeness and accuracy of logged drinking data

---

### Stage 4: Streak Tracking & Basic Analytics
**Objective**: Implement streak counting and basic progress visualization
**Duration**: 2-3 weeks
**Status**: Not Started

#### Features to Implement:
- Streak calculation and display
- Basic progress charts (weekly/monthly views)
- Adherence percentage tracking
- Simple analytics dashboard
- Historical data views

#### Analytics Features:
- Days on track vs. off track
- Average drinks per day/week
- Most common drinking days
- Progress trends over time

#### Deliverables:
- Streak tracking system
- Basic analytics views
- Historical data presentation
- Progress visualization

#### Acceptance Criteria:
- Streak counts accurately
- Charts display meaningful data
- Historical views are navigable
- Data is presented clearly

---

### Stage 4.5: Enhanced Onboarding Skip Functionality
**Objective**: Implement video game-style skip functionality for onboarding conversations
**Duration**: 1-2 weeks
**Status**: Not Started
**Priority**: Pre-MVP Polish Feature

#### Features to Implement:
- **Instant Message Display**: Skip typewriter effect to show remaining messages immediately
- **Flow-Scoped Skip**: Skip only affects current conversation flow, not entire onboarding
- **Input Ready State**: Immediately display input forms after skip activation
- **Visual Skip Indicator**: Clear UI indication when skip mode is active
- **Smooth Transitions**: Seamless experience between normal and skipped content

#### Skip Behavior Design:
- **Single Flow Scope**: Skip button only affects current conversation flow (welcome, motivation, etc.)
- **Message Queue Display**: Instantly render all remaining messages in current flow
- **Input Immediate**: Show input form immediately after last message in flow
- **Reset Per Flow**: Skip state resets when moving to next conversation flow
- **Accessibility**: Keyboard shortcut support and screen reader compatibility

#### Technical Implementation:
- **Skip State Management**: BLoC state for managing skip mode per conversation flow
- **Message Queue Processing**: Batch processing of remaining messages in current flow
- **Animation Overrides**: Disable typewriter effects when skip is active
- **Flow Boundary Detection**: Identify conversation flow boundaries for scoped skip behavior
- **User Preference**: Optional setting to remember skip preference across sessions

#### UX Considerations:
- **Skip Button Placement**: Accessible but not intrusive positioning
- **Visual Feedback**: Clear indication when content has been skipped
- **Undo/Replay**: Option to replay skipped content if desired
- **Performance**: Ensure skip functionality doesn't impact app performance
- **Testing**: Comprehensive testing across all onboarding flows

#### Deliverables:
- Skip functionality integrated into existing onboarding system
- Flow-scoped skip behavior working across all 7 onboarding steps
- Visual skip indicators and accessibility features
- User preference settings for skip behavior
- Performance testing and optimization

#### Acceptance Criteria:
- Skip button instantly displays remaining messages in current flow only
- Input forms appear immediately after skip activation
- Skip state resets properly between conversation flows
- No performance degradation during skip operations
- Accessibility standards met for skip functionality
- User can choose to replay skipped content if desired

---

### Stage 5: Milestone System & Rewards
**Objective**: Implement milestone tracking and celebration features
**Duration**: 2-3 weeks
**Status**: Not Started

#### Features to Implement:
- Preset milestone definitions (1 day, 3 days, 1 week, 2 weeks, 1 month, etc.)
- Custom milestone creation
- Reward selection and assignment
- Milestone achievement celebrations
- Progress toward next milestone display
- Social sharing functionality

#### Preset Milestones:
- **Early Success**: 1 day, 3 days, 1 week, 2 weeks
- **Building Momentum**: 1 month, 2 months, 3 months
- **Long-term Success**: 6 months, 1 year, ongoing quarterly

#### Deliverables:
- Milestone tracking system
- Reward management interface
- Achievement celebration UX
- Social sharing capabilities

#### Acceptance Criteria:
- Milestones trigger at correct intervals
- Users can set custom milestones
- Celebrations are engaging but not intrusive
- Sharing works with major social platforms

---

### Stage 6: Urge Tracking & Therapeutic Support
**Objective**: Implement urge management and therapeutic guidance
**Duration**: 3-4 weeks
**Status**: Not Started

#### Features to Implement:
- Quick urge logging interface
- Trigger identification and categorization
- "Ride the urge" guided exercises
- Breathing exercises and mindfulness prompts
- Urge pattern analytics
- Emergency support access

#### Therapeutic Elements:
- Urge surfing techniques
- Distraction strategies
- Mindfulness exercises
- Progressive muscle relaxation
- Cognitive reframing prompts

#### Trigger Categories:
- Emotional (stress, anxiety, boredom, celebration)
- Environmental (location, people, time of day)
- Physical (fatigue, hunger, habit)
- Social (peer pressure, social anxiety)

#### Deliverables:
- Urge tracking system
- Guided therapeutic interventions
- Analytics for urge patterns
- Emergency resource access

#### Acceptance Criteria:
- Urge logging is accessible within 2 taps
- Therapeutic exercises are engaging
- Users can complete full urge management flow
- Emergency resources are clearly accessible

---

### Stage 7: Enhanced Analytics & Data Visualization
**Objective**: Create comprehensive data views and insights
**Duration**: 2-3 weeks
**Status**: Not Started

#### Features to Implement:
- Advanced analytics dashboard
- Trigger pattern recognition
- Drinking pattern insights
- Goal adjustment recommendations
- Progress comparison tools
- Export functionality

#### Analytics Features:
- Weekly/monthly/yearly summaries
- Trigger correlation analysis
- Success factor identification
- Trend predictions
- Comparative progress metrics

#### Deliverables:
- Comprehensive analytics suite
- Pattern recognition system
- Data export capabilities
- Actionable insights generation

#### Acceptance Criteria:
- Analytics provide meaningful insights
- Data visualizations are clear and helpful
- Users can identify their patterns
- Recommendations are relevant and actionable

---

## MVP Definition (Stages 1-4.5)
The MVP includes core functionality for:
- User onboarding and goal setting with enhanced skip functionality
- Main app navigation and layout structure
- Daily tracking and control panel
- Streak counting and basic progress
- Milestone celebration and rewards
- Basic analytics and history

**MVP Target**: Fully functional moderation tracking app with polished onboarding ready for beta testing

## Post-MVP Enhancements (Nice-to-Have Features)

### Phase 2 Features:
- Advanced urge management (Stage 6)
- Comprehensive analytics (Stage 7)
- Social features and community
- Integration with health apps
- Wearable device support
- Machine learning for personalized insights

### Phase 3 Features:
- Professional dashboard for therapists
- Family/friend support network
- Advanced goal templates
- Habit replacement suggestions
- Integration with treatment programs
- Research participation options

## Technical Architecture Notes

### Technology Stack:
- **Frontend**: Flutter/Dart
- **Local Storage**: SQLite with drift ORM
- **State Management**: BLoC pattern
- **Analytics**: Custom implementation with export capabilities
- **Authentication**: Firebase Auth (for backup/sync)
- **Cloud Storage**: Firebase Firestore (optional, anonymous)

### Key Considerations:
- Privacy-first approach with local data storage
- Offline-capable functionality
- Cross-platform consistency (iOS/Android)
- Accessibility compliance
- Performance optimization for daily use
- Secure data handling and backup

## Success Metrics
- User retention rates
- Goal adherence improvement
- Streak length increases
- Urge management effectiveness
- User satisfaction scores
- Clinical outcome improvements

---

**Last Updated**: Stage 2 JSON Refactoring Requirement Added - Content Management System Missing
**Next Review**: After Stage 2 JSON Refactoring - Enable Dynamic Content Loading for Onboarding
