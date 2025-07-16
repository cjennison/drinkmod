import 'package:flutter/material.dart';
import '../../../core/services/goal_management_service.dart';
import '../widgets/goal_card.dart';
import 'goal_setup_wizard.dart';

/// Progress screen for analytics and streak tracking
/// Shows user progress, streaks, and analytics data
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;
  bool _hasActiveGoals = false;
  Map<String, dynamic>? _activeGoalData;

  @override
  void initState() {
    super.initState();
    _checkUserGoals();
  }

  Future<void> _checkUserGoals() async {
    try {
      final activeGoal = await Future.microtask(() => GoalManagementService.instance.getActiveGoal());
      setState(() {
        _hasActiveGoals = activeGoal != null;
        _activeGoalData = activeGoal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasActiveGoals = false;
        _activeGoalData = null;
        _isLoading = false;
      });
    }
  }

  void _onGoalCreated() {
    setState(() {
      _hasActiveGoals = true;
    });
  }

  void _showGoalHistory() {
    final goalHistory = GoalManagementService.instance.getGoalHistory();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Goal History (${goalHistory.length})'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: goalHistory.isEmpty
                ? [
                    const Text(
                      'No completed goals yet. Keep working on your current goal!',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ]
                : goalHistory.map((goal) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title'] ?? 'Completed Goal',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Type: ${goal['goalType'] ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (goal['updatedAt'] != null) ...[
                              Text(
                                'Completed: ${DateTime.parse(goal['updatedAt']).toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Progress'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show wizard for first-time users
    if (!_hasActiveGoals) {
      return Scaffold(
       
        body: GoalSetupWizard(
          onGoalCreated: _onGoalCreated,
          onShowHistory: () {
            _showGoalHistory();
          },
          canPop: false, // First-time users can't pop because there's no navigation stack
        ),
      );
    }

    // Show main progress screen for users with goals
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Change Goal'),
                    ),
                    body: GoalSetupWizard(
                      onGoalCreated: () {
                        Navigator.of(context).pop();
                        _checkUserGoals();
                      },
                      onShowHistory: () {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          _showGoalHistory();
                        });
                      },
                    ),
                  ),
                ),
              );
            },
            tooltip: 'Change Goal',
          ),
        ],
      ),
      body: _buildProgressContent(),
    );
  }

  Widget _buildProgressContent() {
    if (_activeGoalData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'No Active Goal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a goal to track your progress',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Goal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your progress and achievements',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Goal Card
          GoalCard(
            goalData: _activeGoalData!,
            onTap: () {
              _showGoalDetails();
            },
          ),
          
          const SizedBox(height: 32),
          
          // Additional sections coming soon
          _buildComingSoonSection('Weekly Insights', Icons.analytics_outlined),
          const SizedBox(height: 16),
          _buildComingSoonSection('Achievement Badges', Icons.emoji_events_outlined),
          const SizedBox(height: 16),
          _buildComingSoonSection('Progress Charts', Icons.show_chart_outlined),
        ],
      ),
    );
  }

  Widget _buildComingSoonSection(String title, IconData icon) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.grey.shade600,
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
                    'Coming soon...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Goal Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goal Type: ${_activeGoalData!['goalType']?.toString().split('.').last ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Created: ${_activeGoalData!['startDate'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            const Text('Detailed analytics and goal management features coming soon...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
