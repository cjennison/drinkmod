import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/drink_entry.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/utils/drink_calculator.dart';
import '../../../core/utils/drink_intervention_utils.dart';
import '../../../core/achievements/achievement_helper.dart';
import '../../../shared/widgets/before_journey_banner.dart';
import '../widgets/drink_item_view_modal.dart';
import '../widgets/tracking_date_header.dart';
import '../widgets/daily_status_card.dart';
import '../widgets/drink_entries_list.dart';
import '../widgets/week_overview_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/drinking_calendar.dart';
import 'drink_logging_screen.dart';
import 'drink_logging_cubit.dart';

/// Enhanced tracking screen with history navigation and drink logging
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final PageController _pageController = PageController(initialPage: 1000);
  final HiveDatabaseService _databaseService = HiveDatabaseService.instance;
  
  DateTime _currentDate = DateTime.now();
  Map<String, dynamic>? _userData;
  
  // Calculate base date (today) and offset for infinite scroll
  late DateTime _baseDate;

  @override
  void initState() {
    super.initState();
    _baseDate = DateTime.now();
    _currentDate = _baseDate;
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check achievements when returning to tracking screen
    _checkAchievementsAsync();
  }

  /// Check tracking-related achievements asynchronously
  Future<void> _checkAchievementsAsync() async {
    // Run achievement checking in background with delay
    Future.delayed(const Duration(milliseconds: 500), () async {
      await AchievementHelper.checkMultiple([
        // Tracking achievements
        'first_drink_logged',
        '5_drinks_logged',
        '10_drinks_logged',
        '25_drinks_logged',
        '50_drinks_logged',
        '100_drinks_logged',
        'compliant_logger',
        // Intervention achievements
        'first_intervention_win',
        '5_intervention_wins',
        '10_intervention_wins',
        'intervention_champion',
        'streak_saver',
      ]);
    });
  }

  Future<void> _loadData() async {
    await _databaseService.initialize();
    _loadDayData();
    _loadUserData();
  }

  void _loadDayData() {
    final userData = _databaseService.getUserData();
    
    setState(() {
      _userData = userData;
    });
  }

  void _loadUserData() {
    final userData = _databaseService.getUserData();
    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.today),
              onPressed: _goToToday,
              tooltip: 'Go to today',
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          // Calculate date for this page
          final offset = index - 1000; // Center point
          final date = _baseDate.add(Duration(days: offset));
          
          // Don't allow future dates beyond today
          if (date.isAfter(DateTime.now().add(const Duration(days: 0)))) {
            return _buildFutureDateBlock();
          }
          
          return _buildDayView(date);
        },
      ),
      floatingActionButton: _canLogForDate(_currentDate) 
          ? FloatingActionButton(
              onPressed: _openDrinkLogging,
              tooltip: _isSameDay(_currentDate, DateTime.now()) 
                  ? 'Log a drink' 
                  : 'Add past drink',
              child: Icon(_isSameDay(_currentDate, DateTime.now()) 
                  ? Icons.add 
                  : Icons.history),
            )
          : null,
    );
  }

  Widget _buildDayView(DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    
    // Check if date is before account creation
    if (_databaseService.isDateBeforeAccountCreation(date)) {
      return _buildBeforeJourneyView(date);
    }
    
    final entries = _databaseService.getDrinkEntriesForDate(date);
    final totalDrinks = entries.fold<double>(0, (sum, e) => sum + (e['standardDrinks'] as double));
    final dailyLimit = _userData?['drinkLimit'] ?? 2;
    final isDrinkingDay = _databaseService.isDrinkingDay(date: date);
    
    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
        // Check achievements after manual refresh
        _checkAchievementsAsync();
      },
      child: CustomScrollView(
        slivers: [
          // Fixed header
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 0,
            toolbarHeight: 140,
            flexibleSpace: TrackingDateHeader(
              date: date, 
              isToday: isToday,
              onPreviousDay: _goToPreviousDay,
              onNextDay: isToday ? null : _goToNextDay, // Disable next when at today
              onCalendarTap: _showCalendar,
            ),
          ),
          // Scrollable content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Daily status card
                DailyStatusCard(
                  date: date,
                  totalDrinks: totalDrinks,
                  dailyLimit: dailyLimit,
                  isDrinkingDay: isDrinkingDay,
                  isToday: isToday,
                  databaseService: _databaseService,
                ),
                const SizedBox(height: 16),
                
                // Quick actions (for today and past dates)
                if (!date.isAfter(DateTime.now())) ...[
                  QuickActionsWidget(
                    onOpenDrinkLogging: _openDrinkLogging,
                    onShowQuickLogSheet: _showQuickLogSheet,
                    isRetroactive: !isToday,
                    date: date,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Drink entries
                DrinkEntriesList(
                  entries: entries,
                  date: date,
                  onViewDetails: _viewDrinkDetails,
                  onEdit: _editDrink,
                  onDelete: _deleteDrink,
                ),
                
                // Week overview
                const SizedBox(height: 24),
                WeekOverviewWidget(
                  date: date,
                  databaseService: _databaseService,
                  onDateSelected: _goToDate,
                ),
                
                // Bottom spacing for FAB
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureDateBlock() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Future Date',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can only view past and present data.\nSwipe left to go back to today.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforeJourneyView(DateTime date) {
    return CustomScrollView(
      slivers: [
        // Fixed header
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          pinned: true,
          expandedHeight: 0,
          toolbarHeight: 140,
          flexibleSpace: TrackingDateHeader(
            date: date, 
            isToday: false,
            onPreviousDay: _goToPreviousDay,
            onNextDay: date.isBefore(DateTime.now()) ? _goToNextDay : null, // Disable next if at or after today
            onCalendarTap: _showCalendar,
          ),
        ),
        // Banner content
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: BeforeJourneyBanner(
              accountCreationDate: _databaseService.getFormattedAccountCreationDate(),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _canLogForDate(DateTime date) {
    // Don't allow logging for future dates
    if (date.isAfter(DateTime.now())) {
      return false;
    }
    
    // Don't allow logging for dates before account creation
    if (_databaseService.isDateBeforeAccountCreation(date)) {
      return false;
    }
    
    // Allow logging for today and past dates (after account creation)
    return _databaseService.canAddDrinkToday(date: date);
  }

  void _onPageChanged(int index) {
    final offset = index - 1000;
    final newDate = _baseDate.add(Duration(days: offset));
    
    // Prevent navigation to future dates
    if (newDate.isAfter(DateTime.now().add(const Duration(days: 0)))) {
      // Navigate back to today (or current valid date) without triggering another page change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final todayIndex = 1000; // Today is at index 1000
        if (_pageController.hasClients) {
          _pageController.jumpToPage(todayIndex);
        }
      });
      return; // Don't update state for future dates
    }
    
    setState(() {
      _currentDate = newDate;
    });
    
    // Haptic feedback for page change
    HapticFeedback.lightImpact();
    
    _loadDayData();
  }

  void _goToToday() {
    _pageController.animateToPage(
      1000, // Back to center (today)
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openDrinkLogging() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => DrinkLoggingCubit(HiveDatabaseService.instance),
          child: DrinkLoggingScreen(
            selectedDate: _currentDate,
          ),
        ),
      ),
    );
    
    if (result == true && mounted) {
      _loadData();
      // Check achievements after returning from drink logging
      _checkAchievementsAsync();
    }
  }

  void _openQuickLog() {
    // Show bottom sheet with favorite drinks for quick logging
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildQuickLogSheet(),
    );
  }

  void _showQuickLogSheet() {
    _openQuickLog();
  }

  Widget _buildQuickLogSheet() {
    final allCommonDrinks = DrinkCalculator.getCommonDrinks();
    
    // Get favorite drinks from user data, not from separate favorite drinks box
    final userData = _databaseService.getUserData();
    final favoriteDrinksData = userData?['favoriteDrinks'];
    List<String> favoriteDrinkNames = [];
    
    if (favoriteDrinksData != null && favoriteDrinksData is List) {
      favoriteDrinkNames = favoriteDrinksData.cast<String>();
    }
    
    // Build prioritized drink list: favorites first, then remaining common drinks
    final List<DrinkSuggestion> prioritizedDrinks = [];
    
    // Add favorite drinks first
    for (String favoriteName in favoriteDrinkNames) {
      // Try exact match first
      var matchingDrink = allCommonDrinks.firstWhere(
        (drink) => drink.name.toLowerCase() == favoriteName.toLowerCase(),
        orElse: () => DrinkSuggestion('', '', 0), // Placeholder
      );
      
      // If no exact match, try partial matching or create custom drink
      if (matchingDrink.name.isEmpty) {
        // Try partial matching (e.g., "Whiskey" matches "Shot (1.5 oz)" for spirits)
        if (favoriteName.toLowerCase().contains('whiskey') || 
            favoriteName.toLowerCase().contains('gin') || 
            favoriteName.toLowerCase().contains('rum') ||
            favoriteName.toLowerCase().contains('vodka') ||
            favoriteName.toLowerCase().contains('tequila')) {
          // Create a spirit drink suggestion
          matchingDrink = DrinkSuggestion('$favoriteName (1.5 oz)', 'spirits', 1.0);
        } else if (favoriteName.toLowerCase().contains('beer')) {
          matchingDrink = DrinkSuggestion('$favoriteName (12 oz)', 'beer', 1.0);
        } else if (favoriteName.toLowerCase().contains('wine')) {
          matchingDrink = DrinkSuggestion('$favoriteName (5 oz)', 'wine', 1.0);
        } else {
          // Default custom drink
          matchingDrink = DrinkSuggestion(favoriteName, 'custom', 1.0);
        }
      }
      prioritizedDrinks.add(matchingDrink);
    }
    
    // Add remaining common drinks (excluding those already added as favorites)
    final remainingDrinks = allCommonDrinks.where((drink) {
      // Check if this drink type is already represented in favorites
      return !favoriteDrinkNames.any((favorite) => 
        drink.name.toLowerCase().contains(favorite.toLowerCase()) ||
        favorite.toLowerCase().contains(drink.name.toLowerCase())
      );
    }).toList();
    prioritizedDrinks.addAll(remainingDrinks);
    
    // Take only 6 drinks total for the grid
    final displayDrinks = prioritizedDrinks.take(6).toList();
    
    final warning = DrinkInterventionUtils.getQuickLogSheetWarning(
      date: _currentDate,
      databaseService: _databaseService,
    );
    final shouldShowQuickLog = DrinkInterventionUtils.shouldShowQuickLog(
      date: _currentDate,
      databaseService: _databaseService,
      isRetroactive: !_isSameDay(_currentDate, DateTime.now()),
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Log',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log a drink with default settings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          
          // Warning message if present
          if (warning != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: warning.severity == QuickLogWarningSeverity.error 
                    ? Colors.red.shade50 
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: warning.severity == QuickLogWarningSeverity.error 
                      ? Colors.red.shade200 
                      : Colors.orange.shade200
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        warning.severity == QuickLogWarningSeverity.error 
                            ? Icons.block 
                            : Icons.warning_amber, 
                        color: warning.severity == QuickLogWarningSeverity.error 
                            ? Colors.red.shade600 
                            : Colors.orange.shade600, 
                        size: 20
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warning.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: warning.severity == QuickLogWarningSeverity.error 
                                ? Colors.red.shade700 
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    warning.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: warning.severity == QuickLogWarningSeverity.error 
                          ? Colors.red.shade600 
                          : Colors.orange.shade600,
                    ),
                  ),
                  if (warning.severity == QuickLogWarningSeverity.error) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _openDrinkLogging();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Use Full Logging'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Only show drinks if quick log is allowed
          if (shouldShowQuickLog) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: displayDrinks.length,
              itemBuilder: (context, index) {
                final drink = displayDrinks[index];
                // Check if this drink is a favorite (either exact match or created from favorite)
                final isFavorite = index < favoriteDrinkNames.length ||
                    favoriteDrinkNames.any((favorite) => 
                      drink.name.toLowerCase().contains(favorite.toLowerCase()) ||
                      favorite.toLowerCase().contains(drink.name.toLowerCase())
                    );
                
                // Check if adding this drink would exceed limits
                final interventionResult = DrinkInterventionUtils.checkInterventionRequired(
                  date: _currentDate,
                  proposedStandardDrinks: drink.standardDrinks,
                  databaseService: _databaseService,
                  isRetroactive: !_isSameDay(_currentDate, DateTime.now()),
                );
                
                final wouldExceedLimit = interventionResult.requiresIntervention || 
                    interventionResult.decision == DrinkInterventionUtils.cannotLog;
                final isDisabled = wouldExceedLimit;
                
                return Card(
                  elevation: isFavorite ? 3 : 1,
                  child: InkWell(
                    onTap: isDisabled ? null : () => _quickLogDrink(drink),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: isFavorite ? BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDisabled 
                              ? Colors.grey.withValues(alpha: 0.3)
                              : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                if (isFavorite && !isDisabled) ...[
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                if (isDisabled) ...[
                                  Icon(
                                    Icons.warning_amber,
                                    size: 14,
                                    color: Colors.orange.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: Text(
                                    drink.name,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: isDisabled 
                                          ? Colors.grey.shade500 
                                          : isFavorite 
                                              ? Theme.of(context).primaryColor 
                                              : null,
                                      fontWeight: isFavorite && !isDisabled ? FontWeight.w600 : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Flexible(
                              child: Text(
                                isDisabled 
                                    ? 'Would exceed limit'
                                    : '${drink.standardDrinks.toStringAsFixed(1)} drinks',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDisabled 
                                      ? Colors.orange.shade600
                                      : isFavorite 
                                          ? Theme.of(context).primaryColor.withValues(alpha: 0.7)
                                          : Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            // Show message when quick log is not available
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Quick Log Not Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please use the "Log Drink" button for therapeutic support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _quickLogDrink(DrinkSuggestion drink) async {
    Navigator.of(context).pop(); // Close bottom sheet
    
    // Check intervention requirements using utility
    final interventionResult = DrinkInterventionUtils.checkInterventionRequired(
      date: _currentDate,
      proposedStandardDrinks: drink.standardDrinks,
      databaseService: _databaseService,
      isRetroactive: !_isSameDay(_currentDate, DateTime.now()),
    );
    
    // If intervention is required, show appropriate message and redirect
    if (interventionResult.requiresIntervention || interventionResult.decision == DrinkInterventionUtils.cannotLog) {
      final color = interventionResult.severity == DrinkInterventionSeverity.error 
          ? Colors.red 
          : Colors.orange;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(interventionResult.userMessage),
          backgroundColor: color,
          duration: Duration(seconds: 3),
          action: interventionResult.decision != DrinkInterventionUtils.cannotLog 
              ? SnackBarAction(
                  label: 'Log Drink',
                  onPressed: _openDrinkLogging,
                )
              : null,
        ),
      );
      return;
    }
    
    // Only allow quick log for drinking days when well under the limit
    try {
      final drinkEntry = DrinkEntry(
        timestamp: _currentDate.copyWith(
          hour: DateTime.now().hour,
          minute: DateTime.now().minute,
        ),
        timeOfDay: _getTimeOfDayFromHour(DateTime.now().hour),
        drinkId: drink.name,
        drinkName: drink.name,
        standardDrinks: drink.standardDrinks,
        isWithinLimit: true, // Will be recalculated in cubit
        isScheduleCompliant: true, // Will be recalculated in cubit
      );

      // Create a local cubit instance for this operation
      final cubit = DrinkLoggingCubit(_databaseService);
      await cubit.logDrinkEntry(drinkEntry);
      
      _loadData();
      // Check achievements after quick logging
      _checkAchievementsAsync();
    
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log drink: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editDrink(Map<String, dynamic> entry) async {
    final drinkEntry = DrinkEntry.fromHive(entry);
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => DrinkLoggingCubit(HiveDatabaseService.instance),
          child: DrinkLoggingScreen(
            selectedDate: drinkEntry.timestamp,
            editingEntry: drinkEntry,
          ),
        ),
      ),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drink updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
      // Check achievements after editing a drink
      _checkAchievementsAsync();
    }
  }

  void _deleteDrink(Map<String, dynamic> entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Drink'),
        content: Text('Are you sure you want to delete this ${entry['drinkName']} entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _databaseService.deleteDrinkEntry(entry['id']);
        _loadData();
        // Check achievements after deleting a drink (may affect counts)
        _checkAchievementsAsync();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete drink: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewDrinkDetails(Map<String, dynamic> entry) async {
    showDialog(
      context: context,
      builder: (context) => DrinkItemViewModal(
        entry: entry,
        onEdit: () => _editDrink(entry),
      ),
    );
  }

  /// Helper method to determine timeOfDay from hour
  String _getTimeOfDayFromHour(int hour) {
    if (hour >= 5 && hour < 11) {
      return 'Morning';
    } else if (hour >= 11 && hour < 13) {
      return 'Noon';
    } else if (hour >= 13 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  void _goToPreviousDay() {
    final targetPage = _pageController.page!.round() - 1;
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextDay() {
    final currentPage = _pageController.page!.round();
    final targetDate = _baseDate.add(Duration(days: currentPage - 1000 + 1));
    
    // Don't allow navigation to future dates (today or later)
    if (targetDate.isAfter(DateTime.now()) || _isSameDay(targetDate, DateTime.now())) {
      return;
    }
    
    final targetPage = currentPage + 1;
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showCalendar() {
    showDialog(
      context: context,
      builder: (context) => DrinkingCalendar(
        selectedDate: _currentDate,
        onDateSelected: _goToDate,
        userSchedule: _userData,
      ),
    );
  }

  void _goToDate(DateTime date) {
    // Don't allow navigation to future dates beyond today
    if (date.isAfter(DateTime.now())) {
      return;
    }
    
    final daysDifference = date.difference(_baseDate).inDays;
    final targetPage = 1000 + daysDifference;
    
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
