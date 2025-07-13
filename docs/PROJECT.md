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

#### 🔄 Stage 2 Refactoring Required: JSON Content Management
**Status**: Missing Implementation - High Priority
**Estimated Effort**: 1-2 days

##### Current Issue:
The onboarding conversation content is currently hardcoded within the Dart components, making it difficult to update messaging, add new conversation flows, or modify therapeutic language without code changes.

##### Required Refactoring:
- **JSON Script System**: Extract all conversation content into structured JSON files
- **Dynamic Content Loading**: Implement content loader service to read JSON scripts at runtime
- **Conversation Engine**: Create flexible conversation flow engine that interprets JSON scripts
- **Content Versioning**: Enable easy updates to therapeutic messaging and conversation flows
- **Localization Ready**: Structure JSON to support future multi-language support

##### JSON Structure Design:
```json
{
  "onboarding": {
    "version": "1.0",
    "steps": [
      {
        "id": "welcome",
        "messages": [
          "Hey.",
          "I'm glad you're here.",
          "Can you tell me your name, or how you like to be called?"
        ],
        "input": {
          "type": "name_and_gender",
          "validation": "required"
        },
        "next": "introduction"
      }
    ]
  }
}
```

##### Benefits:
- **Non-Developer Updates**: Therapeutic content can be updated without code changes
- **A/B Testing**: Easy to test different conversation approaches
- **Content Management**: Clear separation between logic and therapeutic messaging
- **Rapid Iteration**: Quick updates to improve user experience based on feedback
- **Clinical Review**: Mental health professionals can review and modify content directly

##### Implementation Priority:
This refactoring should be completed before Stage 3 to ensure scalable content management as the app grows in complexity.

---

### Stage 2.5: Main App Layout & Navigation Structure ⚠️ PLANNED
**Objective**: Implement foundational app navigation with Material Design 3 and 2025 Flutter best practices
**Duration**: 1-2 weeks
**Status**: Awaiting Stage 2 JSON Refactoring Completion
**Prerequisite**: Complete onboarding JSON content management system before proceeding

#### 🎯 Core Implementation Features:
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

#### ✅ Acceptance Criteria Met:
- Bottom navigation follows Material Design 3 guidelines with proper M3 Expressive styling
- SafeArea properly protects content from device intrusions and system UI
- Profile screen allows complete user data management including onboarding reset
- App adapts to different screen sizes and orientations without layout breaks
- Keyboard interactions don't obstruct content or cause layout shifts
- Navigation state is preserved across app lifecycle events
- Touch interactions are optimized with appropriate touch targets and feedback
- All screens maintain consistent visual design and interaction patterns

#### 🚀 2025 Flutter Standards Implemented:
- **VS Code F5 Debugging**: Primary development workflow without terminal commands
- **Modern API Usage**: No deprecated Flutter APIs, updated to latest 3.32.6 standards
- **Performance Optimizations**: Const widgets, efficient rebuilds, lazy loading
- **Accessibility Compliance**: Semantic widgets, screen reader support, focus management
- **Cross-Platform Consistency**: Shared codebase with platform-specific optimizations

#### 📝 Deliverables Completed:
- Functional bottom navigation with Material Design 3 styling
- Complete Profile screen with user data management and reset capabilities
- SafeArea implementation protecting content from all device intrusions
- Responsive layout system supporting multiple screen sizes and orientations
- Modern Flutter architecture following 2025 development best practices
- Seamless integration with existing onboarding system

---

### Stage 3: Core Tracking & Control Panel
**Objective**: Implement main dashboard and drinking tracking
**Duration**: 3-4 weeks
**Status**: Not Started

#### Features to Implement:
- Main control panel dashboard
- Today's allowance display with examples
- Drink logging interface (quick entry + detailed)
- "Why did you drink?" categorization
- Real-time allowance updates
- Over-limit tracking and gentle notifications

#### Dashboard Elements:
- Today's drinking status (allowed/not allowed)
- Remaining drinks with specific examples
- Quick drink logging buttons
- Streak counter
- Progress indicators

#### Deliverables:
- Functional main dashboard
- Drink logging system
- Real-time data updates
- Intuitive UX for daily use

#### Acceptance Criteria:
- Dashboard accurately reflects current allowance
- Drink logging is quick and easy
- Data updates immediately after logging
- Clear visual feedback for all states

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

## MVP Definition (Stages 1-5)
The MVP includes core functionality for:
- User onboarding and goal setting
- Daily tracking and control panel
- Streak counting and basic progress
- Milestone celebration and rewards
- Basic analytics and history

**MVP Target**: Fully functional moderation tracking app ready for beta testing

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
