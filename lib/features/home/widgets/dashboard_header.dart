import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Enhanced dashboard header with streak, welcome message, and motivation
class DashboardHeader extends StatelessWidget {
  final String? userName;
  final int currentStreak;
  final String motivationalMessage;
  final bool isDrinkingDay;
  final double todaysDrinks;
  final int dailyLimit;

  const DashboardHeader({
    super.key,
    this.userName,
    required this.currentStreak,
    required this.motivationalMessage,
    required this.isDrinkingDay,
    required this.todaysDrinks,
    required this.dailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              color: _getStatusColor(theme).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(theme).withValues(alpha: 0.3),
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
                      color: _getStatusColor(theme),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getStatusMessage(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(theme),
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
    if (!isDrinkingDay) {
      return 'Alcohol-free day today';
    }
    
    final remaining = dailyLimit - todaysDrinks;
    if (remaining <= 0) {
      return 'Daily limit reached';
    } else if (remaining == dailyLimit) {
      return 'Ready to track your drinks';
    } else {
      final remainingText = remaining == remaining.toInt() 
          ? '${remaining.toInt()}'
          : remaining.toStringAsFixed(1);
      return '$remainingText drinks remaining today';
    }
  }

  IconData _getStatusIcon() {
    if (!isDrinkingDay) {
      return Icons.spa;
    }
    
    final remaining = dailyLimit - todaysDrinks;
    if (remaining <= 0) {
      return Icons.check_circle;
    } else if (remaining == dailyLimit) {
      return Icons.play_circle;
    } else {
      return Icons.trending_up;
    }
  }

  Color _getStatusColor(ThemeData theme) {
    if (!isDrinkingDay) {
      return Colors.green;
    }
    
    final remaining = dailyLimit - todaysDrinks;
    if (remaining <= 0) {
      return theme.primaryColor;
    } else if (remaining == dailyLimit) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }
}
