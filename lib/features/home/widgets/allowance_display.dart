import 'package:flutter/material.dart';

/// Visual display of today's drink allowance with therapeutic messaging
class AllowanceDisplay extends StatelessWidget {
  final int todaysDrinks;
  final int dailyLimit;
  final bool isAllowedDay;
  final String userName;
  
  const AllowanceDisplay({
    super.key,
    required this.todaysDrinks,
    required this.dailyLimit,
    required this.isAllowedDay,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remainingDrinks = (dailyLimit - todaysDrinks).clamp(0, dailyLimit);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            _getGreeting(userName),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          
          // Allowance visualization
          if (isAllowedDay) ...[
            _buildAllowanceIndicator(context),
            const SizedBox(height: 16),
            Text(
              remainingDrinks > 0 
                ? 'Remaining: $remainingDrinks drink${remainingDrinks != 1 ? 's' : ''}'
                : todaysDrinks > dailyLimit 
                  ? 'Over limit by ${todaysDrinks - dailyLimit} drink${todaysDrinks - dailyLimit != 1 ? 's' : ''}'
                  : 'Limit reached for today',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (remainingDrinks > 0 && dailyLimit > 0)
              Text(
                _getDrinkExamples(remainingDrinks.toInt()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Today isn\'t a planned drinking day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAllowanceIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final progress = dailyLimit > 0 ? (todaysDrinks / dailyLimit).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(dailyLimit, (index) {
            final isFilled = index < todaysDrinks;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface.withValues(alpha: 0.5),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: isFilled 
                ? Icon(
                    Icons.local_bar,
                    color: theme.colorScheme.onPrimary,
                    size: 18,
                  )
                : null,
            );
          }),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 1.0 
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
  
  String _getGreeting(String userName) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    
    return '$timeGreeting, $userName!';
  }
  
  String _getDrinkExamples(int count) {
    if (count == 1) {
      return 'Example: 1 beer OR 1 glass of wine OR 1 cocktail';
    } else if (count == 2) {
      return 'Example: 2 beers OR 1 beer + 1 wine OR 2 cocktails';
    } else {
      return 'Example: $count beers OR mixed drinks equivalent';
    }
  }
}
