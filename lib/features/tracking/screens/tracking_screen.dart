import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/drink_entry.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/utils/drink_calculator.dart';
import '../widgets/drink_item_view_modal.dart';
import '../widgets/tracking_date_header.dart';
import '../widgets/daily_status_card.dart';
import '../widgets/drink_entries_list.dart';
import '../widgets/week_overview_widget.dart';
import '../widgets/quick_actions_widget.dart';
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
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: _goToToday,
            tooltip: 'Go to today',
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
      floatingActionButton: _canLogToday() 
          ? FloatingActionButton(
              onPressed: _openDrinkLogging,
              tooltip: 'Log a drink',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDayView(DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final entries = _databaseService.getDrinkEntriesForDate(date);
    final totalDrinks = entries.fold<double>(0, (sum, e) => sum + (e['standardDrinks'] as double));
    final dailyLimit = _userData?['drinkLimit'] ?? 2;
    final isDrinkingDay = _databaseService.isDrinkingDay(date: date);
    
    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header with navigation hints
            TrackingDateHeader(date: date, isToday: isToday),
            const SizedBox(height: 16),
            
            // Daily status card
            DailyStatusCard(
              date: date,
              totalDrinks: totalDrinks,
              dailyLimit: dailyLimit,
              isDrinkingDay: isDrinkingDay,
              isToday: isToday,
            ),
            const SizedBox(height: 16),
            
            // Quick actions (only for today)
            if (isToday) ...[
              QuickActionsWidget(
                onOpenDrinkLogging: _openDrinkLogging,
                onShowQuickLogSheet: _showQuickLogSheet,
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
            ),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
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

  // Helper methods
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _canLogToday() {
    return _isSameDay(_currentDate, DateTime.now()) && 
           _databaseService.canAddDrinkToday();
  }

  void _onPageChanged(int index) {
    final offset = index - 1000;
    final newDate = _baseDate.add(Duration(days: offset));
    
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drink logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
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
    final commonDrinks = DrinkCalculator.getCommonDrinks().take(6).toList();
    
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
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: commonDrinks.length,
            itemBuilder: (context, index) {
              final drink = commonDrinks[index];
              return Card(
                child: InkWell(
                  onTap: () => _quickLogDrink(drink),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drink.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${drink.standardDrinks.toStringAsFixed(1)} drinks',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _quickLogDrink(DrinkSuggestion drink) async {
    Navigator.of(context).pop(); // Close bottom sheet
    
    try {
      final now = DateTime.now();
      final drinkEntry = DrinkEntry(
        timestamp: now,
        timeOfDay: _getTimeOfDayFromHour(now.hour),
        drinkId: drink.name,
        drinkName: drink.name,
        standardDrinks: drink.standardDrinks,
        intention: 'Quick logged',
        isWithinLimit: true, // Will be recalculated in cubit
        isScheduleCompliant: true, // Will be recalculated in cubit
      );

      // Create a local cubit instance for this operation
      final cubit = DrinkLoggingCubit(_databaseService);
      await cubit.logDrinkEntry(drinkEntry);
      
      _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${drink.name} logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Drink deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
