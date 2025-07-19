import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/drink_status_utils.dart';
import '../../../core/services/hive_database_service.dart';

/// Enhanced dashboard header with streak, welcome message, and motivation
class DashboardHeader extends StatelessWidget {
  final String? userName;
  final int currentStreak;
  final String motivationalMessage;
  final bool isDrinkingDay;
  final double todaysDrinks;
  final int dailyLimit;
  final HiveDatabaseService databaseService;

  const DashboardHeader({
    super.key,
    this.userName,
    required this.currentStreak,
    required this.motivationalMessage,
    required this.isDrinkingDay,
    required this.todaysDrinks,
    required this.dailyLimit,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    
    return Container(
      width: double.infinity,
      padding: AppSpacing.screenPadding, // Use consistent padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withValues(alpha: 0.1),
            theme.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      today,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getGreeting(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Motivational message with status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor().withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getStatusMessage(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                if (motivationalMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    motivationalMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    if (userName != null && userName!.isNotEmpty) {
      return 'Welcome back, $userName!';
    }
    return 'Welcome back!';
  }

  String _getStatusMessage() {
    final drinkStatus = DrinkStatusUtils.calculateDrinkStatus(
      date: DateTime.now(),
      databaseService: databaseService,
    );
    
    switch (drinkStatus) {
      case DrinkStatus.alcoholFreeSuccess:
        return 'Alcohol-free day success';
      case DrinkStatus.alcoholFreeViolation:
        return 'Alcohol-free day - drinks logged';
      case DrinkStatus.withinLimit:
        final remaining = dailyLimit - todaysDrinks;
        if (remaining == dailyLimit) {
          return 'Ready to track your drinks';
        } else {
          final remainingText = remaining == remaining.toInt() 
              ? '${remaining.toInt()}'
              : remaining.toStringAsFixed(1);
          return '$remainingText drinks remaining today';
        }
      case DrinkStatus.overButWithinTolerance:
        return 'Over limit but within tolerance';
      case DrinkStatus.exceeded:
        return 'Daily limit significantly exceeded';
      case DrinkStatus.unused:
        return 'No drinks logged today';
      case DrinkStatus.future:
        return 'Future date';
    }
  }

  IconData _getStatusIcon() {
    final drinkStatus = DrinkStatusUtils.calculateDrinkStatus(
      date: DateTime.now(),
      databaseService: databaseService,
    );
    
    return DrinkStatusUtils.getStatusIcon(drinkStatus);
  }

  Color _getStatusColor() {
    final drinkStatus = DrinkStatusUtils.calculateDrinkStatus(
      date: DateTime.now(),
      databaseService: databaseService,
    );
    
    return DrinkStatusUtils.getStatusColor(drinkStatus);
  }
}
