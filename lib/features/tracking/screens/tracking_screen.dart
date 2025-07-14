import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/models/drink_entry.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/utils/drink_calculator.dart';
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
              child: const Icon(Icons.add),
              tooltip: 'Log a drink',
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
            _buildDateHeader(date, isToday),
            const SizedBox(height: 16),
            
            // Daily status card
            _buildDailyStatusCard(date, totalDrinks, dailyLimit, isDrinkingDay, isToday),
            const SizedBox(height: 16),
            
            // Quick actions (only for today)
            if (isToday) ...[
              _buildQuickActions(),
              const SizedBox(height: 16),
            ],
            
            // Drink entries
            _buildDrinkEntries(entries, date),
            
            // Week overview
            const SizedBox(height: 24),
            _buildWeekOverview(date),
            
            // Bottom spacing for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, bool isToday) {
    final dayName = DateFormat('EEEE').format(date);
    final dateStr = DateFormat('MMMM d, y').format(date);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.swipe_left,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Today' : dayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.swipe_right,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStatusCard(DateTime date, double totalDrinks, int dailyLimit, bool isDrinkingDay, bool isToday) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (!isDrinkingDay) {
      statusColor = Colors.blue;
      statusText = 'Non-drinking day';
      statusIcon = Icons.schedule;
    } else if (totalDrinks == 0) {
      statusColor = Colors.green;
      statusText = 'No drinks logged';
      statusIcon = Icons.check_circle;
    } else if (totalDrinks <= dailyLimit) {
      statusColor = Colors.green;
      statusText = 'Within limit';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.orange;
      statusText = 'Over limit';
      statusIcon = Icons.warning;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isDrinkingDay)
                  Text(
                    '${totalDrinks.toStringAsFixed(1)}/$dailyLimit drinks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            
            if (isDrinkingDay) ...[
              const SizedBox(height: 12),
              _buildDrinkVisualizer(totalDrinks, dailyLimit),
            ],
            
            if (isToday && isDrinkingDay) ...[
              const SizedBox(height: 12),
              Text(
                _getRemainingDrinksMessage(totalDrinks, dailyLimit),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkVisualizer(double totalDrinks, int dailyLimit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dailyLimit, (index) {
        final drinkNumber = index + 1;
        final isFilled = totalDrinks >= drinkNumber;
        final isPartial = totalDrinks > index && totalDrinks < drinkNumber;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
            color: isFilled 
                ? Theme.of(context).primaryColor
                : isPartial 
                    ? Theme.of(context).primaryColor.withOpacity(0.5)
                    : Colors.transparent,
          ),
          child: Center(
            child: Icon(
              Icons.local_drink,
              size: 16,
              color: isFilled || isPartial ? Colors.white : Theme.of(context).primaryColor,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openDrinkLogging,
                    icon: const Icon(Icons.add),
                    label: const Text('Log Drink'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openQuickLog,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Quick Log'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkEntries(List<Map<String, dynamic>> entries, DateTime date) {
    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.local_drink_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No drinks logged',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isSameDay(date, DateTime.now()) 
                    ? 'Tap the + button to log your first drink'
                    : 'No drinks were logged on this day',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drinks (${entries.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...entries.map((entry) => _buildDrinkCard(entry, date)).toList(),
      ],
    );
  }

  Widget _buildDrinkCard(Map<String, dynamic> entry, DateTime date) {
    final drinkDate = DateTime.parse(entry['drinkDate']);
    final standardDrinks = entry['standardDrinks'] as double;
    final drinkName = entry['drinkName'] as String;
    
    // Use timeOfDay from enhanced metadata, fallback to timestamp if not available
    final timeStr = entry['timeOfDay'] as String? ?? DateFormat('h:mm a').format(drinkDate);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            standardDrinks.toStringAsFixed(1),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(drinkName),
        subtitle: Text(timeStr),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editDrink(entry),
              tooltip: 'Edit drink',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteDrink(entry),
              tooltip: 'Delete drink',
            ),
          ],
        ),
        onTap: () => _viewDrinkDetails(entry),
      ),
    );
  }

  Widget _buildWeekOverview(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final weekDays = List.generate(7, (index) => weekStart.add(Duration(days: index)));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Week Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: weekDays.map((day) {
                final dayEntries = _databaseService.getDrinkEntriesForDate(day);
                final totalDrinks = dayEntries.fold<double>(0, (sum, e) => sum + (e['standardDrinks'] as double));
                final dailyLimit = _userData?['drinkLimit'] ?? 2;
                final isToday = _isSameDay(day, DateTime.now());
                final isFuture = day.isAfter(DateTime.now());
                
                Color dotColor;
                if (isFuture) {
                  dotColor = Colors.grey.shade300;
                } else if (totalDrinks == 0) {
                  dotColor = Colors.green;
                } else if (totalDrinks <= dailyLimit) {
                  dotColor = Colors.green;
                } else {
                  dotColor = Colors.orange;
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: isFuture ? null : () => _goToDate(day),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(day).substring(0, 1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? Theme.of(context).primaryColor : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                            border: isToday 
                                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (!isFuture)
                          Text(
                            totalDrinks > 0 ? totalDrinks.toStringAsFixed(0) : '•',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
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

  String _getRemainingDrinksMessage(double totalDrinks, int dailyLimit) {
    final remaining = dailyLimit - totalDrinks;
    if (remaining <= 0) {
      return 'You\'ve reached your daily limit.';
    } else if (remaining == 1) {
      return 'You have 1 drink remaining today';
    } else {
      return 'You have ${remaining.toStringAsFixed(0)} drinks remaining today';
    }
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

  void _goToDate(DateTime date) {
    final daysDiff = date.difference(_baseDate).inDays;
    final targetPage = 1000 + daysDiff;
    
    _pageController.animateToPage(
      targetPage,
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
    
    if (result == true) {
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${drink.name} logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log drink: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    
    if (result == true) {
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drink deleted'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete drink: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewDrinkDetails(Map<String, dynamic> entry) {
    // Show detailed view of the drink entry
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry['drinkName']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Standard Drinks: ${(entry['standardDrinks'] as double).toStringAsFixed(1)}'),
            const SizedBox(height: 8),
            Text('Time: ${DateFormat('h:mm a').format(DateTime.parse(entry['drinkDate']))}'),
            if (entry['reason'] != null) ...[
              const SizedBox(height: 8),
              Text('Reason: ${entry['reason']}'),
            ],
            if (entry['notes'] != null) ...[
              const SizedBox(height: 8),
              Text('Notes: ${entry['notes']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editDrink(entry);
            },
            child: const Text('Edit'),
          ),
        ],
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
