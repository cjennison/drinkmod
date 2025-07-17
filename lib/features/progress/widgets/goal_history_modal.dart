import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../core/services/goal_management_service.dart';
import '../../../core/services/goal_progress_service.dart';
import '../../../core/utils/map_utils.dart';
import '../shared/components/goal_history_components.dart';

/// Goal history modal with organized goal timeline and progress tracking
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
      developer.log('Loading goal summary for: ${goal['title']}', name: 'GoalHistoryModal');
      final summary = await _calculateGoalSummary(goal);
      
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
    final startDate = DateTime.parse(goal['startDate']);
    final endDate = goal['updatedAt'] != null 
        ? DateTime.parse(goal['updatedAt'])
        : DateTime.now();
    
    final progressService = GoalProgressService.instance;
    final cleanGoalData = MapUtils.deepConvertMap(goal);
    final summary = await progressService.calculateGoalProgress(cleanGoalData);
    
    final durationDays = endDate.difference(startDate).inDays + 1;
    
    return {
      ...summary,
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: _goalHistory.isEmpty 
                  ? GoalHistoryComponents.buildEmptyState()
                  : _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.history, size: 24),
        const SizedBox(width: 8),
        const Text(
          'Goal History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Goal list
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completed Goals (${_goalHistory.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _goalHistory.length,
                  itemBuilder: (context, index) {
                    final goal = _goalHistory[index];
                    final isSelected = _selectedGoal?['id'] == goal['id'];
                    
                    return GoalHistoryComponents.buildGoalListItem(
                      goal: goal,
                      isSelected: isSelected,
                      onTap: () => _selectGoal(goal),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Right side - Goal details
        Expanded(
          flex: 2,
          child: _selectedGoal == null
              ? const Center(child: Text('Select a goal to view details'))
              : _buildGoalDetails(),
        ),
      ],
    );
  }

  Widget _buildGoalDetails() {
    if (_selectedGoal == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoalHistoryComponents.buildSummaryHeader(
          goal: _selectedGoal!,
          summary: _selectedGoalSummary,
        ),
        const SizedBox(height: 16),
        
        if (_isLoadingSummary)
          Expanded(
            child: GoalHistoryComponents.buildLoadingIndicator('Loading progress data...'),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: GoalHistoryComponents.buildProgressOverview(
                summary: _selectedGoalSummary,
                goal: _selectedGoal!,
              ),
            ),
          ),
      ],
    );
  }
}
