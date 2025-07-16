import 'package:flutter/material.dart';
import '../../../../core/services/user_data_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/goal_management_service.dart';

/// Welcome step that introduces the goal system with personalized motivation
class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  
  const WelcomeStep({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          // Welcome header with personalization
          _buildWelcomeHeader(),
          
          const SizedBox(height: 32),
          
          // Progress summary to show current status
          _buildProgressSummary(),
          
          const SizedBox(height: 24),
          
          // Goal history for returning users
          _buildGoalHistorySummary(),
          
          const SizedBox(height: 32),
          
          // Goal benefits explanation
          _buildGoalBenefits(),
          
          const SizedBox(height: 40),
          
          // Continue button
          _buildContinueButton(context),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeHeader() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getWelcomeData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final data = snapshot.data!;
        final userName = data['userName'] as String;
        final hasCompletedGoals = data['hasCompletedGoals'] as bool;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userName!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasCompletedGoals 
                ? 'Ready to set your next goal?'
                : 'Ready to take your progress to the next level?',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildProgressSummary() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getProgressSummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final data = snapshot.data!;
        final daysTracking = data['daysTracking'] as int;
        final totalEntries = data['totalEntries'] as int;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insights_outlined,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Your Journey So Far',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Days Tracking',
                      daysTracking.toString(),
                      Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryItem(
                      'Entries Logged',
                      totalEntries.toString(),
                      Icons.note_add_outlined,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalHistorySummary() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getGoalHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final completedGoals = snapshot.data!;
        final goalCount = completedGoals.length;
        final mostRecentGoal = completedGoals.first;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Your Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Goals Completed',
                      goalCount.toString(),
                      Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryItem(
                      'Latest Goal',
                      mostRecentGoal['title'] ?? 'Goal',
                      Icons.flag_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Great job on your progress! Let\'s continue building on your success.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGoalBenefits() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getWelcomeData(),
      builder: (context, snapshot) {
        final hasCompletedGoals = snapshot.data?['hasCompletedGoals'] as bool? ?? false;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasCompletedGoals 
                ? 'Why continue with goals?'
                : 'Goals help you:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildBenefitItem(
              icon: Icons.trending_up_outlined,
              title: hasCompletedGoals ? 'Build on your momentum' : 'Track meaningful progress',
              description: hasCompletedGoals 
                ? 'Keep the positive changes going with new challenges'
                : 'See how your efforts translate into real improvements',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              icon: Icons.psychology_outlined,
              title: hasCompletedGoals ? 'Maintain your success' : 'Stay motivated',
              description: hasCompletedGoals
                ? 'Continue celebrating milestones and achievements'
                : 'Celebrate milestones and maintain momentum',
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              icon: Icons.insights_outlined,
              title: hasCompletedGoals ? 'Explore new approaches' : 'Gain deeper insights',
              description: hasCompletedGoals
                ? 'Try different goal types and discover new patterns'
                : 'Understand patterns and make informed decisions',
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildContinueButton(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getWelcomeData(),
      builder: (context, snapshot) {
        final hasCompletedGoals = snapshot.data?['hasCompletedGoals'] as bool? ?? false;
        
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              hasCompletedGoals 
                ? 'Let\'s Set Up Your Next Goal'
                : 'Let\'s Set Up Your First Goal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Future<Map<String, dynamic>> _getWelcomeData() async {
    final userData = UserDataService.instance.getUserData();
    final userName = userData?['name'] as String? ?? 'there';
    
    // Check if user has completed goals before
    final completedGoals = GoalManagementService.instance.getGoalHistory();
    final hasCompletedGoals = completedGoals.isNotEmpty;
    
    return {
      'userName': userName,
      'hasCompletedGoals': hasCompletedGoals,
    };
  }
  
  Future<Map<String, dynamic>> _getProgressSummary() async {
    final stats = AnalyticsService.instance.getDashboardStats();
    final userData = UserDataService.instance.getUserData();
    
    // Calculate days since account creation
    int daysTracking = 1;
    if (userData != null && userData.containsKey('accountCreatedDate')) {
      final createdDate = DateTime.fromMillisecondsSinceEpoch(userData['accountCreatedDate']);
      daysTracking = DateTime.now().difference(createdDate).inDays + 1;
    }
    
    return {
      'daysTracking': daysTracking,
      'totalEntries': stats['totalDays'] ?? 0,
    };
  }
  
  Future<List<Map<String, dynamic>>> _getGoalHistory() async {
    return GoalManagementService.instance.getGoalHistory();
  }
}
