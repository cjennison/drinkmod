# Drinkmod - Progress & Goals System (Phase 2)

## Project Overview
**Objective**: Build a comprehensive progress tracking and goal management system that provides therapeutic insights, trend analysis, and data-driven motivation for users managing their alcohol consumption.

**Target Users**: Individuals who have completed initial onboarding and have been logging drinks for 2+ weeks, seeking deeper insights and long-term goal management.

---

## Core Principles

### 🎯 **Therapeutic Foundation**
- **Goal-Oriented Recovery**: Every metric ties back to user-defined therapeutic goals
- **Progress Recognition**: Celebrate both major achievements and incremental improvements  
- **Data-Driven Insights**: Transform raw logging data into actionable therapeutic insights
- **Personalized Experience**: Adapt visualizations and goals to individual patterns and preferences

### 🔧 **Technical Excellence**
- **Extensible Architecture**: Goal types and analytics can be easily added without refactoring
- **Shared Components**: Reusable chart, metric, and visualization components
- **Performance**: Efficient data processing for real-time insights with large datasets
- **Data Integrity**: Robust algorithms that handle edge cases and missing data gracefully

---

## Phase 2 Data Models

### 1. Goal System Architecture

#### **UserGoal Model**
```dart
class UserGoal {
  final String id;
  final GoalType goalType;
  final String title;                    // User-friendly goal name
  final String description;              // Detailed goal description
  final DateTime startDate;              // When goal tracking started
  final DateTime? endDate;               // When goal was completed/discontinued
  final GoalStatus status;               // Active, Completed, Paused, Discontinued
  final Map<String, dynamic> parameters; // Goal-specific parameters
  final List<ChartType> requiredCharts;  // Charts needed for this goal
  final GoalMetrics metrics;             // Current progress metrics
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum GoalType {
  weeklyReduction,      // "Drink X drinks per week over Y months"
  dailyLimit,           // "Stay under X drinks per day for Y weeks"  
  alcoholFreeDays,      // "Have X alcohol-free days per week for Y months"
  interventionWins,     // "Choose not to drink X times over Y weeks"
  moodImprovement,      // "Maintain average mood of X+ for Y weeks"
  streakMaintenance,    // "Maintain adherence streak for X days"
  costSavings,          // "Save $X over Y months through reduced drinking"
  customGoal,           // User-defined goal with custom metrics
}

enum GoalStatus {
  active,
  completed,
  paused,
  discontinued,
}

enum ChartType {
  weeklyDrinksTrend,
  adherenceOverTime,
  interventionStats,
  moodCorrelation,
  riskDayAnalysis,
  timeOfDayPattern,
  costSavingsProgress,
  calorieReduction,
  streakVisualization,
}
```

#### **GoalMetrics Model**
```dart
class GoalMetrics {
  final double currentProgress;          // 0.0 to 1.0 (percentage complete)
  final double targetValue;              // The target the user is working toward
  final double currentValue;             // Current measurement
  final String unit;                     // "drinks", "days", "dollars", etc.
  final DateTime lastUpdated;
  final List<Milestone> milestones;      // Progress milestones achieved
  final Map<String, dynamic> metadata;   // Goal-specific tracking data
}

class Milestone {
  final String id;
  final String title;
  final String description;
  final double threshold;                // Progress percentage for this milestone
  final DateTime? achievedDate;
  final bool isAchieved;
}
```

### 2. Intervention Tracking Enhancement

#### **InterventionEvent Model** (New)
```dart
class InterventionEvent {
  final String id;
  final DateTime timestamp;
  final InterventionType type;
  final InterventionDecision decision;    // Proceeded or Declined
  final String? reason;                   // User's reason for decision
  final int? moodAtTime;                  // Mood during intervention
  final Map<String, dynamic>? context;   // Additional context data
}

enum InterventionDecision {
  proceeded,     // User chose to drink despite intervention
  declined,      // User chose NOT to drink (intervention win)
}
```

### 3. Historical Baseline Model

#### **DrinkingBaseline Model** (New)
```dart
class DrinkingBaseline {
  final String id;
  final String period;                   // "before_app", "month_1", etc.
  final double averageWeeklyDrinks;
  final double averageDailyCost;         // Cost per day
  final double averageCaloriesPerDay;    // Calories from alcohol per day
  final List<String> commonDrinks;       // Most frequent drinks
  final Map<String, double> drinkFrequency; // Drink type -> frequency
  final DateTime periodStart;
  final DateTime periodEnd;
  final bool isEstimated;                // User-provided estimate vs actual data
}
```

### 4. Progress Analytics Models

#### **TrendData Model**
```dart
class TrendData {
  final String metricName;
  final List<DataPoint> dataPoints;
  final TrendDirection direction;        // Improving, Declining, Stable
  final double changePercent;            // Week over week / month over month
  final DateTime calculatedAt;
}

class DataPoint {
  final DateTime date;
  final double value;
  final Map<String, dynamic>? metadata;
}

enum TrendDirection {
  improving,
  declining, 
  stable,
}
```

---

## Goal Types & Associated Visualizations

### 1. **Weekly Reduction Goal**
**Description**: "Reduce weekly alcohol consumption to X drinks over Y consecutive months"

**Parameters**:
- `targetWeeklyDrinks: int` (target drinks per week)
- `durationMonths: int` (goal duration)
- `currentBaseline: double` (starting weekly average)

**Required Charts**:
- `weeklyDrinksTrend`: Line chart showing weekly consumption over time
- `adherenceOverTime`: Progress toward weekly targets
- `streakVisualization`: Consecutive weeks within target

**Algorithm**:
```dart
double calculateProgress() {
  final weeksInGoal = DateTime.now().difference(startDate).inDays / 7;
  final targetWeeks = durationMonths * 4.33; // Average weeks per month
  final successfulWeeks = getWeeksWithinTarget();
  return (successfulWeeks / targetWeeks).clamp(0.0, 1.0);
}
```

### 2. **Daily Limit Goal**
**Description**: "Stay under X drinks per day for Y consecutive weeks"

**Parameters**:
- `dailyLimit: int` (max drinks per day)
- `durationWeeks: int` (goal duration)
- `allowedViolations: int` (tolerance for slip-ups)

**Required Charts**:
- `adherenceOverTime`: Daily adherence visualization
- `riskDayAnalysis`: Which days tend to exceed limits
- `interventionStats`: Success rate of interventions

### 3. **Alcohol-Free Days Goal**
**Description**: "Have X alcohol-free days per week for Y months"

**Parameters**:
- `alcoholFreeDaysPerWeek: int` (target AF days)
- `durationMonths: int` (goal duration)

**Required Charts**:
- `adherenceOverTime`: Weekly AF day achievement
- `streakVisualization`: Longest AF day streaks
- `weeklyDrinksTrend`: Overall consumption trends

### 4. **Intervention Success Goal**
**Description**: "Choose not to drink X times when prompted by interventions over Y weeks"

**Parameters**:
- `targetInterventionWins: int` (successful "no" decisions)
- `durationWeeks: int` (goal duration)

**Required Charts**:
- `interventionStats`: Win/loss ratio over time
- `moodCorrelation`: Mood vs intervention success
- `timeOfDayPattern`: When interventions are most/least effective

### 5. **Mood Improvement Goal**
**Description**: "Maintain average mood of X+ for Y consecutive weeks"

**Parameters**:
- `targetAverageMood: double` (target mood score)
- `durationWeeks: int` (goal duration)
- `measurementPeriod: String` ("weekly", "monthly")

**Required Charts**:
- `moodCorrelation`: Mood trends vs drinking patterns
- `adherenceOverTime`: Mood target achievement
- `weeklyDrinksTrend`: Correlation with consumption

### 6. **Cost Savings Goal**
**Description**: "Save $X over Y months through reduced drinking"

**Parameters**:
- `targetSavings: double` (dollars to save)
- `durationMonths: int` (goal duration)
- `baselineMonthlyCost: double` (previous spending)

**Required Charts**:
- `costSavingsProgress`: Cumulative savings over time
- `weeklyDrinksTrend`: Consumption reduction driving savings
- `adherenceOverTime`: Savings target achievement

---

## Component Architecture

### 1. **Shared Chart Components**

#### **BaseChartWidget** (Abstract)
```dart
abstract class BaseChartWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<DataPoint> data;
  final ChartStyle style;
  final Duration animationDuration;
  
  // Implemented by specific chart types
  Widget buildChart(BuildContext context);
  Widget buildLegend(BuildContext context);
  String formatValue(double value);
}
```

#### **Specific Chart Implementations**
- `LineChartWidget`: Trends over time
- `BarChartWidget`: Categorical comparisons  
- `ProgressChartWidget`: Goal progress visualization
- `HeatmapWidget`: Day/time pattern analysis
- `PieChartWidget`: Categorical breakdowns

### 2. **Goal Management Components**

#### **GoalSetupWizard**
- Multi-step wizard for creating new goals
- Dynamic parameter collection based on goal type
- Preview of required charts and metrics

#### **GoalCard**
- Summary view of individual goals
- Progress indicator and key metrics
- Quick actions (edit, pause, complete)

#### **GoalDetailsView**
- Full goal tracking with all associated charts
- Historical progress and milestones
- Goal adjustment options

### 3. **Analytics Components**

#### **InsightCard**
- Modular insight presentation
- Severity levels (positive, neutral, concerning)
- Action recommendations

#### **TrendSummary**
- Multi-metric trend overview
- Improvement/decline indicators
- Period-over-period comparisons

### 4. **Utility Services**

#### **GoalCalculationService**
```dart
class GoalCalculationService {
  static double calculateProgress(UserGoal goal, List<DrinkEntry> entries);
  static List<Milestone> checkMilestones(UserGoal goal, GoalMetrics metrics);
  static TrendData calculateTrend(String metric, DateTime start, DateTime end);
  static List<InsightData> generateInsights(UserGoal goal, TrendData trends);
}
```

#### **ChartDataService**
```dart
class ChartDataService {
  static List<DataPoint> getWeeklyDrinksData(DateTime start, DateTime end);
  static List<DataPoint> getAdherenceData(UserGoal goal);
  static Map<String, double> getInterventionStats(DateTime start, DateTime end);
  static List<DataPoint> getMoodTrendData(DateTime start, DateTime end);
}
```

---

## Implementation Phases

### **Phase 2.1: Foundation & Data Models** (5 days)
1. Create all data models (`UserGoal`, `GoalMetrics`, `InterventionEvent`, etc.)
2. Extend `HiveDatabaseService` with goal and analytics operations
3. Build goal calculation algorithms and utilities
4. Create data migration system for existing users

### **Phase 2.2: Goal Management System** (7 days)
1. Build `GoalSetupWizard` with all goal types
2. Implement goal CRUD operations
3. Create `GoalCard` and `GoalDetailsView` components
4. Add goal validation and business logic

### **Phase 2.3: Chart & Visualization Framework** (6 days)
1. Build `BaseChartWidget` architecture
2. Implement all specific chart types (`LineChartWidget`, `BarChartWidget`, etc.)
3. Create `ChartDataService` for data preparation
4. Add chart styling and theme system

### **Phase 2.4: Analytics & Insights Engine** (8 days)
1. Build trend calculation algorithms
2. Implement insight generation system
3. Create `TrendSummary` and `InsightCard` components
4. Add intervention success tracking

### **Phase 2.5: Progress Screen Integration** (4 days)
1. Redesign `ProgressScreen` with new architecture
2. Integrate goal management UI
3. Add onboarding flow for first goal setup
4. Performance optimization and testing

### **Phase 2.6: Historical Baseline & Cost Tracking** (3 days)
1. Implement `DrinkingBaseline` system
2. Add cost and calorie tracking features
3. Build baseline comparison visualizations
4. User profile integration for baseline data

---

## Database Schema Extensions

### **HiveDatabaseService Additions**
```dart
// New box for goals
late Box<Map> _goalsBox;

// New box for intervention events  
late Box<Map> _interventionEventsBox;

// New box for baselines
late Box<Map> _baselinesBox;

// Goal operations
Future<String> createGoal(UserGoal goal);
List<UserGoal> getActiveGoals();
Future<void> updateGoalProgress(String goalId, GoalMetrics metrics);
Future<void> completeGoal(String goalId);

// Intervention tracking
Future<void> logInterventionEvent(InterventionEvent event);
List<InterventionEvent> getInterventionEvents(DateTime start, DateTime end);
double getInterventionSuccessRate(DateTime start, DateTime end);

// Analytics operations
TrendData calculateWeeklyTrend(int weeks);
Map<String, double> getMoodCorrelations();
List<DataPoint> getRiskDayAnalysis();
```

---

## Success Metrics

### **User Engagement**
- Goal completion rate > 70%
- Average session time increase of 40%
- Weekly active user retention > 85%

### **Therapeutic Outcomes**  
- Intervention success rate improvement of 25%
- User-reported motivation increase
- Long-term adherence (3+ months) increase of 30%

### **Technical Performance**
- Chart rendering time < 500ms
- Data calculation time < 200ms
- Memory usage increase < 15%

---

## Future Extensibility

### **Additional Goal Types**
- Social goal tracking (events, gatherings)
- Health correlation goals (sleep, exercise)
- Habit replacement goals
- Community/family goals

### **Advanced Analytics**
- Machine learning pattern recognition
- Predictive risk modeling
- Personalized intervention timing
- External data integration (fitness trackers, calendar)

### **Sharing & Community**
- Anonymous progress sharing
- Goal achievement celebrations
- Community challenges
- Progress comparison with similar users

---

This architecture provides a solid foundation for comprehensive progress tracking while maintaining flexibility for future enhancements and therapeutic effectiveness.
