import 'package:flutter/material.dart';
import '../../../../core/services/goal_progress_service.dart';
import '../types/goal_display_types.dart';

/// Adaptive goal card component with shared loading and error handling logic
/// Provides different display variants for various UI contexts
abstract class AdaptiveGoalCard extends StatefulWidget {
  final Map<String, dynamic> goalData;
  final VoidCallback? onTap;  final GoalCardSize variant;

  const AdaptiveGoalCard({
    super.key,
    required this.goalData,
    this.onTap,
    this.variant = GoalCardSize.expanded,
  });
}

abstract class AdaptiveGoalCardState<T extends AdaptiveGoalCard> extends State<T> {
  Map<String, dynamic>? progressData;
  DataLoadingState loadingState = DataLoadingState.loading;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.goalData != widget.goalData) {
      setState(() {
        loadingState = DataLoadingState.loading;
      });
      _loadProgressData();
    }
  }

  Future<void> _loadProgressData() async {
    try {
      final progressService = GoalProgressService.instance;
      final data = await progressService.calculateGoalProgress(widget.goalData);
      
      if (mounted) {
        setState(() {
          progressData = data;
          loadingState = data.isEmpty 
              ? DataLoadingState.empty 
              : DataLoadingState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          progressData = _getEmptyProgressData();
          loadingState = DataLoadingState.error;
        });
      }
    }
  }

  Map<String, dynamic> _getEmptyProgressData() {
    return {
      'percentage': 0.0,
      'isOnTrack': true,
      'statusText': 'Goal started today',
      'currentMetric': '0',
      'targetMetric': 'Loading...',
      'bonusMetric': null,
      'recentActions': [
        {
          'icon': 'Icons.flag',
          'color': 'Colors.blue',
          'text': 'Goal created - ready to start!',
        }
      ],
      'daysRemaining': 0,
      'timeProgress': 0.0,
    };
  }

  /// Protected method for subclasses to refresh data
  @protected
  Future<void> refreshProgressData() async {
    await _loadProgressData();
  }

  /// Build method must be implemented by subclasses
  @override
  Widget build(BuildContext context);

  /// Helper method to build loading state
  @protected
  Widget buildLoadingState() {
    return Card(
      elevation: 4,
      margin: _getCardMargin(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: _getCardHeight(),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Helper method to build error state
  @protected
  Widget buildErrorState() {
    return Card(
      elevation: 4,
      margin: _getCardMargin(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: _getCardHeight(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.grey[400],
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load progress',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: refreshProgressData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _getCardMargin() {
    switch (widget.variant) {
      case GoalCardSize.compact:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case GoalCardSize.standard:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case GoalCardSize.expanded:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  double _getCardHeight() {
    switch (widget.variant) {
      case GoalCardSize.compact:
        return 120;
      case GoalCardSize.standard:
        return 150;
      case GoalCardSize.expanded:
        return 200;
    }
  }
}
