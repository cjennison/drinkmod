/// Data model for onboarding user responses and state
class OnboardingState {
  // User responses
  String userName = '';
  String userGender = '';
  String userMotivation = '';
  String drinkingFrequency = '';
  String drinkingAmount = '';
  List<String> favoriteDrinks = [];
  String recommendedSchedule = '';
  String selectedSchedule = '';
  int drinkLimit = 2;
  
  // Step tracking
  int currentStep = 1;
  final int totalSteps = 7;
  
  // Submission states
  bool nameSubmitted = false;
  bool motivationSubmitted = false;
  bool drinkingPatternsSubmitted = false;
  bool favoriteDrinksSubmitted = false;
  bool scheduleSubmitted = false;
  bool drinkLimitSubmitted = false;
  
  // UI state
  bool isLoading = true;
  final Map<String, bool> messageCompletionStates = {};
  int messageIdCounter = 0;

  /// Reset all state
  void reset() {
    userName = '';
    userGender = '';
    userMotivation = '';
    drinkingFrequency = '';
    drinkingAmount = '';
    favoriteDrinks.clear();
    recommendedSchedule = '';
    selectedSchedule = '';
    drinkLimit = 2;
    
    currentStep = 1;
    
    nameSubmitted = false;
    motivationSubmitted = false;
    drinkingPatternsSubmitted = false;
    favoriteDrinksSubmitted = false;
    scheduleSubmitted = false;
    drinkLimitSubmitted = false;
    
    isLoading = true;
    messageCompletionStates.clear();
    messageIdCounter = 0;
  }

  /// Generate schedule recommendation based on current drinking frequency
  void generateScheduleRecommendation() {
    switch (drinkingFrequency.toLowerCase()) {
      case 'daily':
        recommendedSchedule = '3 times per week';
        break;
      case 'several times a week':
        recommendedSchedule = 'weekends only';
        break;
      case 'once or twice a week':
        recommendedSchedule = 'once per week';
        break;
      case 'a few times a month':
        recommendedSchedule = 'twice per month';
        break;
      case 'once a month or less':
        recommendedSchedule = 'maintain current frequency';
        break;
      default:
        recommendedSchedule = 'a more structured schedule';
    }
  }

  /// Get summary of user's setup
  Map<String, dynamic> getSummary() {
    return {
      'name': userName,
      'gender': userGender,
      'motivation': userMotivation,
      'drinkingFrequency': drinkingFrequency,
      'drinkingAmount': drinkingAmount,
      'favoriteDrinks': favoriteDrinks,
      'schedule': selectedSchedule,
      'drinkLimit': drinkLimit,
      'onboardingCompleted': true,
    };
  }
}
