/// Goal display types and enums for progress and goal features

/// State of goal progress data loading
enum DataLoadingState {
  loading,
  loaded,
  error,
  empty,
}

/// Card interaction types
enum GoalCardAction {
  tap,
  celebrate,
  retry,
  refresh,
}

/// Goal card display size variants
enum GoalCardSize {
  compact,     // Compact version for home screen
  standard,    // Standard view for lists  
  expanded,    // Full progress card with all details
}

/// Goal display presentation context
enum GoalContext {
  progressScreen,
  homeScreen,
  historyModal,
  wizardPreview,
}

/// Data calculation and display precision
enum DataPrecision {
  exact,       // Show exact percentages and values
  rounded,     // Round to nearest meaningful increment
  simplified,  // Show simplified progress indicators
}

/// Time-based goal progress states
enum TimeState {
  justStarted,
  earlyProgress,
  midProgress,
  nearCompletion,
  overdue,
}

/// Achievement celebration levels
enum CelebrationLevel {
  milestone,
  majorAchievement,
  goalCompletion,
  streak,
}
