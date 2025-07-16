import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../core/services/goal_management_service.dart';
import '../../../core/services/goal_progress_service.dart';
import '../../../core/utils/map_utils.dart';

/// Comprehensive goal history modal with 2-column layout
/// Left side: Chronological list of completed goals
/// Right side: Detailed summary of selected goal with progress data
class GoalHistoryModal extends StatefulWidget {
  const GoalHistoryModal({super.key});

  @override
  State<GoalHistoryModal> createState() => _GoalHistoryModalState();
}

class _GoalHistoryModalState extends State<GoalHistoryModal> {
  List<Map<String, dynamic>> _goalHistory = [];
  Map<String, dynamic>? _selectedGoal;
  Map<String, dynamic>? _selectedGoalSummary;
  bool _isLoadingSummary = false;

  @override
  void initState() {
    super.initState();
    _loadGoalHistory();
  }

  void _loadGoalHistory() {
    final history = GoalManagementService.instance.getGoalHistory();
    // Convert each goal to proper Map<String, dynamic> and sort by completion date (most recent first)
    final cleanHistory = history.map((goal) => MapUtils.deepConvertMap(goal)).toList();
    cleanHistory.sort((a, b) {
      final aDate = DateTime.parse(a['updatedAt'] ?? a['startDate']);
      final bDate = DateTime.parse(b['updatedAt'] ?? b['startDate']);
      return bDate.compareTo(aDate);
    });
    
    setState(() {
      _goalHistory = cleanHistory;
      if (cleanHistory.isNotEmpty) {
        _selectGoal(cleanHistory.first);
      }
    });
  }

  Future<void> _selectGoal(Map<String, dynamic> goal) async {
    setState(() {
      _selectedGoal = goal;
      _isLoadingSummary = true;
    });

    try {
      developer.log('Loading goal summary for: ${goal['title']} (${goal['id']})', name: 'GoalHistoryModal');
      
      // Calculate goal summary using the same service but with historical dates
      final summary = await _calculateGoalSummary(goal);
      
      developer.log('Goal summary calculated successfully', name: 'GoalHistoryModal');
      setState(() {
        _selectedGoalSummary = summary;
        _isLoadingSummary = false;
      });
    } catch (e, stackTrace) {
      developer.log('Error calculating goal summary: $e', name: 'GoalHistoryModal', error: e, stackTrace: stackTrace);
      setState(() {
        _selectedGoalSummary = null;
        _isLoadingSummary = false;
      });
    }
  }

  Future<Map<String, dynamic>> _calculateGoalSummary(Map<String, dynamic> goal) async {
    try {
      developer.log('Calculating goal summary for goal: ${goal['id']}', name: 'GoalHistoryModal');
      developer.log('Goal data: ${goal.toString()}', name: 'GoalHistoryModal');
      
      // Create a modified goal data for historical calculation
      final startDate = DateTime.parse(goal['startDate']);
      final endDate = goal['updatedAt'] != null 
          ? DateTime.parse(goal['updatedAt'])
          : DateTime.now();
      
      developer.log('Date range: $startDate to $endDate', name: 'GoalHistoryModal');
      
      // Use GoalProgressService to calculate historical progress
      final progressService = GoalProgressService.instance;
      developer.log('Calling GoalProgressService.calculateGoalProgress', name: 'GoalHistoryModal');
      
      // Convert LinkedMap to proper Map<String, dynamic> to avoid type issues
      final cleanGoalData = MapUtils.deepConvertMap(goal);
      developer.log('Clean goal data type: ${cleanGoalData.runtimeType}', name: 'GoalHistoryModal');
      developer.log('Parameters type: ${cleanGoalData['parameters']?.runtimeType}', name: 'GoalHistoryModal');
      
      final summary = await progressService.calculateGoalProgress(cleanGoalData);
      developer.log('Progress service returned: ${summary.toString()}', name: 'GoalHistoryModal');
      
      // Add additional historical context
      final durationDays = endDate.difference(startDate).inDays + 1;
      
      final result = {
        ...summary,
        'startDate': startDate,
        'endDate': endDate,
        'durationDays': durationDays,
        'goalType': goal['goalType'],
        'title': goal['title'],
        'description': goal['description'],
      };
      
      developer.log('Final result: ${result.toString()}', name: 'GoalHistoryModal');
      return result;
    } catch (e, stackTrace) {
      developer.log('Error in _calculateGoalSummary: $e', name: 'GoalHistoryModal', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.blue.shade600,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Goal History (${_goalHistory.length})',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _goalHistory.isEmpty
                  ? _buildEmptyState()
                  : Row(
                      children: [
                        // Left side: Goal list
                        Expanded(
                          flex: 2,
                          child: _buildGoalList(),
                        ),
                        
                        // Divider
                        Container(
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                        
                        // Right side: Goal summary
                        Expanded(
                          flex: 3,
                          child: _buildGoalSummary(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Completed Goals Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first goal to see\nyour progress history here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalList() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Completed Goals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _goalHistory.length,
              itemBuilder: (context, index) {
                final goal = _goalHistory[index];
                final isSelected = _selectedGoal?['id'] == goal['id'];
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: isSelected ? Colors.blue.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _selectGoal(goal),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.blue.shade300 
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title'] ?? 'Completed Goal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                    ? Colors.blue.shade800 
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getGoalTypeDisplayName(goal['goalType']),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatCompletionDate(goal),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSummary() {
    if (_selectedGoal == null) {
      return const Center(
        child: Text(
          'Select a goal to view details',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (_isLoadingSummary) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading goal summary...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedGoalSummary == null) {
      return const Center(
        child: Text(
          'Unable to load goal summary',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal header
          _buildSummaryHeader(),
          const SizedBox(height: 24),
          
          // Progress overview
          _buildProgressOverview(),
          const SizedBox(height: 24),
          
          // Timeline
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final summary = _selectedGoalSummary!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary['title'] ?? 'Goal Summary',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getGoalTypeDisplayName(summary['goalType']),
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (summary['description'] != null && summary['description'].isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            summary['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressOverview() {
    final summary = _selectedGoalSummary!;
    final percentage = (summary['percentage'] as double?) ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.green.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Goal Completed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const Text(
                      'Final Progress',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${summary['durationDays']}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const Text(
                      'Days Active',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final summary = _selectedGoalSummary!;
    final startDate = summary['startDate'] as DateTime;
    final endDate = summary['endDate'] as DateTime;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Started',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(startDate),
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Completed',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(endDate),
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getGoalTypeDisplayName(String? goalType) {
    switch (goalType) {
      case 'GoalType.dailyLimit':
        return 'Daily Drink Limit';
      case 'GoalType.weeklyLimit':
        return 'Weekly Drink Limit';
      case 'GoalType.dryDays':
        return 'Dry Days';
      case 'GoalType.streakDays':
        return 'Streak Days';
      case 'GoalType.reductionPercent':
        return 'Reduction Percentage';
      case 'GoalType.customTarget':
        return 'Custom Target';
      default:
        return goalType ?? 'Unknown Goal Type';
    }
  }

  String _formatCompletionDate(Map<String, dynamic> goal) {
    try {
      final dateStr = goal['updatedAt'] ?? goal['startDate'];
      final date = DateTime.parse(dateStr);
      return _formatDate(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
