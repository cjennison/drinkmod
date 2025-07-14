/// Constants and enums for onboarding data
/// This ensures consistency between saved values and UI display
library;

class OnboardingConstants {
  // Gender options
  static const String genderMale = 'male';
  static const String genderFemale = 'female';
  static const String genderOther = 'other';
  
  static const List<String> genderOptions = [
    genderMale,
    genderFemale,
    genderOther,
  ];

  // Schedule types
  static const String scheduleWeekendsOnly = 'weekends_only';
  static const String scheduleFridayOnly = 'friday_only';
  static const String scheduleSocialOccasions = 'social_occasions';
  static const String scheduleCustomWeekly = 'custom_weekly';
  static const String scheduleReducedCurrent = 'reduced_current';
  
  static const List<String> scheduleOptions = [
    scheduleWeekendsOnly,
    scheduleFridayOnly,
    scheduleSocialOccasions,
    scheduleCustomWeekly,
    scheduleReducedCurrent,
  ];

  // Schedule type classifications
  static const String scheduleTypeStrict = 'strict';
  static const String scheduleTypeOpen = 'open';
  
  static const Map<String, String> scheduleTypeMap = {
    scheduleWeekendsOnly: scheduleTypeStrict,
    scheduleFridayOnly: scheduleTypeStrict,
    scheduleSocialOccasions: scheduleTypeOpen,
    scheduleCustomWeekly: scheduleTypeOpen,
    scheduleReducedCurrent: scheduleTypeOpen,
  };

  // Available schedule options for profile (strict schedules only for now)
  static const List<String> profileScheduleOptions = [
    scheduleWeekendsOnly,
    scheduleFridayOnly,
  ];

  // Default weekly limits for open schedules
  static const Map<String, int> defaultWeeklyLimits = {
    scheduleSocialOccasions: 4,
    scheduleCustomWeekly: 6,
    scheduleReducedCurrent: 5,
  };

  // Maximum drinks per day for open schedules
  static const int maxDrinksPerDayOpen = 2;

  // Motivations
  static const String motivationHealth = 'health';
  static const String motivationWeightLoss = 'weight_loss';
  static const String motivationSaveMoney = 'save_money';
  static const String motivationBetterSleep = 'better_sleep';
  static const String motivationFamily = 'family';
  static const String motivationPersonalGrowth = 'personal_growth';
  
  static const List<String> motivationOptions = [
    motivationHealth,
    motivationWeightLoss,
    motivationSaveMoney,
    motivationBetterSleep,
    motivationFamily,
    motivationPersonalGrowth,
  ];

  // Drinking frequency options
  static const String frequencyDaily = 'daily';
  static const String frequencySeveralTimesWeek = 'several_times_week';
  static const String frequencyOnceOrTwiceWeek = 'once_or_twice_week';
  static const String frequencyFewTimesMonth = 'few_times_month';
  static const String frequencyOnceMonthOrLess = 'once_month_or_less';
  
  static const List<String> frequencyOptions = [
    frequencyDaily,
    frequencySeveralTimesWeek,
    frequencyOnceOrTwiceWeek,
    frequencyFewTimesMonth,
    frequencyOnceMonthOrLess,
  ];

  // Drinking amount options
  static const String amount1To2 = '1_to_2_drinks';
  static const String amount3To4 = '3_to_4_drinks';
  static const String amount5To6 = '5_to_6_drinks';
  static const String amount7Plus = '7_plus_drinks';
  
  static const List<String> amountOptions = [
    amount1To2,
    amount3To4,
    amount5To6,
    amount7Plus,
  ];

  // Drink types
  static const String drinkBeer = 'Beer';
  static const String drinkWine = 'Wine';
  static const String drinkCocktail = 'Cocktail';
  static const String drinkWhiskey = 'Whiskey';
  static const String drinkVodka = 'Vodka';
  static const String drinkRum = 'Rum';
  static const String drinkGin = 'Gin';
  static const String drinkTequila = 'Tequila';
  static const String drinkChampagne = 'Champagne';
  static const String drinkHardSeltzer = 'Hard Seltzer';
  static const String drinkCider = 'Cider';
  static const String drinkSake = 'Sake';
  
  static const List<String> drinkOptions = [
    drinkBeer,
    drinkWine,
    drinkCocktail,
    drinkWhiskey,
    drinkVodka,
    drinkRum,
    drinkGin,
    drinkTequila,
    drinkChampagne,
    drinkHardSeltzer,
    drinkCider,
    drinkSake,
  ];

  // Drink limits
  static const List<int> drinkLimitOptions = [1, 2, 3, 4, 5, 6];
  static const List<int> weeklyLimitOptions = [2, 3, 4, 5, 6, 7, 8, 10, 12, 14];

  /// Get human-readable display text for any onboarding value
  static String getDisplayText(String value) {
    switch (value) {
      // Gender
      case genderMale:
        return 'Male';
      case genderFemale:
        return 'Female';
      case genderOther:
        return 'Other';
      
      // Schedule types
      case scheduleWeekendsOnly:
        return 'Weekends Only';
      case scheduleFridayOnly:
        return 'Friday Only';
      case scheduleSocialOccasions:
        return 'Social Occasions Only';
      case scheduleCustomWeekly:
        return 'Custom Weekly Pattern';
      case scheduleReducedCurrent:
        return 'Reduced Current Pattern';
      
      // Motivations
      case motivationHealth:
        return 'Health';
      case motivationWeightLoss:
        return 'Weight Loss';
      case motivationSaveMoney:
        return 'Save Money';
      case motivationBetterSleep:
        return 'Better Sleep';
      case motivationFamily:
        return 'Family';
      case motivationPersonalGrowth:
        return 'Personal Growth';
      
      // Drinking frequency
      case frequencyDaily:
        return 'Daily';
      case frequencySeveralTimesWeek:
        return 'Several times a week';
      case frequencyOnceOrTwiceWeek:
        return 'Once or twice a week';
      case frequencyFewTimesMonth:
        return 'A few times a month';
      case frequencyOnceMonthOrLess:
        return 'Once a month or less';
      
      // Drinking amount
      case amount1To2:
        return '1-2 drinks';
      case amount3To4:
        return '3-4 drinks';
      case amount5To6:
        return '5-6 drinks';
      case amount7Plus:
        return '7+ drinks';
      
      // Drinks (already in display format)
      case drinkBeer:
      case drinkWine:
      case drinkCocktail:
      case drinkWhiskey:
      case drinkVodka:
      case drinkRum:
      case drinkGin:
      case drinkTequila:
      case drinkChampagne:
      case drinkHardSeltzer:
      case drinkCider:
      case drinkSake:
        return value;
      
      // Fallback - capitalize and replace underscores
      default:
        return value.split('_').map((word) => 
          word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }

  /// Default values for onboarding
  static const Map<String, dynamic> defaultValues = {
    'gender': genderMale,
    'scheduleType': scheduleWeekendsOnly,
    'drinkLimit': 2,
    'motivation': motivationHealth,
    'favoriteDrinks': [drinkBeer, drinkWine],
    'onboardingCompleted': false,
  };
}
