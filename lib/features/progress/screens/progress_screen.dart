import 'package:flutter/material.dart';
import '../../../core/services/goal_management_service.dart';
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasActiveGoals = false;
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
            'Your Progress',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track your achievements and trends',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Goal dashboard coming soon...',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
