import 'package:flutter/material.dart';
import '../../../../core/services/user_data_service.dart';
import '../../../../core/services/analytics_service.dart';

/// Welcome step that introduces the goal system with personalized motivation
class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  
  const WelcomeStep({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          
          const SizedBox(height: 40),
          
          // Goal benefits explanation
          _buildGoalBenefits(),
          
          const Spacer(),
          
          // Continue button
          _buildContinueButton(context),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeHeader() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final userName = userData?['name'] as String? ?? 'there';
        
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
            const Text(
              'Ready to take your progress to the next level?',
              style: TextStyle(
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
  
  Widget _buildGoalBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goals help you:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        _buildBenefitItem(
          icon: Icons.trending_up_outlined,
          title: 'Track meaningful progress',
          description: 'See how your efforts translate into real improvements',
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(
          icon: Icons.psychology_outlined,
          title: 'Stay motivated',
          description: 'Celebrate milestones and maintain momentum',
          color: Colors.purple,
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(
          icon: Icons.insights_outlined,
          title: 'Gain deeper insights',
          description: 'Understand patterns and make informed decisions',
          color: Colors.orange,
        ),
      ],
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
        child: const Text(
          'Let\'s Set Up Your First Goal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  Future<Map<String, dynamic>?> _getUserData() async {
    return UserDataService.instance.getUserData();
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
}
