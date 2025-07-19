import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/services/goal_management_service.dart';
import '../../../core/services/app_events_service.dart';
import '../../../core/models/app_event.dart';
import '../../progress/widgets/goal_progress_card.dart';
import '../../progress/shared/types/goal_display_types.dart';
import '../models/meditation_config.dart';
import '../screens/meditation_session_screen.dart';
import '../widgets/breathing_exercise_modal.dart';
import '../widgets/grounding_exercise_modal.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  final GoalManagementService _goalService = GoalManagementService.instance;
  final AppEventsService _eventsService = AppEventsService.instance;
  Map<String, dynamic>? _activeGoal;
  bool _isLoading = true;
  bool _hasCompletedAction = false;
  DateTime? _sessionStartTime;
  String _completedActionType = '';

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _loadGoalData();
  }

  Future<void> _loadGoalData() async {
    try {
      final activeGoal = await _goalService.getActiveGoal();
      if (mounted) {
        setState(() {
          _activeGoal = activeGoal;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _markActionCompleted(String actionType) {
    setState(() {
      _hasCompletedAction = true;
      _completedActionType = actionType;
    });
  }

  void _startRandomUrgeSurfing() {
    final urgeSurfingOptions = [
      'urge_surfing_wave',
      'urge_surfing_candle', 
      'urge_surfing_bubble'
    ];
    
    final random = Random();
    final selectedOption = urgeSurfingOptions[random.nextInt(urgeSurfingOptions.length)];
    
    final config = MeditationRegistry.getMeditationById(selectedOption);
    
    if (config == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Urge surfing not available')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeditationSessionScreen(
          config: config,
        ),
      ),
    ).then((_) => _markActionCompleted('urge_surfing'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SOS Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion message or initial calming message
              if (_hasCompletedAction) 
                _buildCompletionMessage()
              else
                _buildCalmingMessage(),
              
              const SizedBox(height: 24),
              
              // Goal card if present
              if (!_isLoading && _activeGoal != null) ...[
                _buildGoalSection(),
                const SizedBox(height: 24),
              ],
              
              // Urge surfing action
              _buildUrgeSurfingSection(),
              
              const SizedBox(height: 32),
              
              // Additional support options
              _buildSupportOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.teal.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 48,
            color: Colors.green.shade500,
          ),
          const SizedBox(height: 16),
          const Text(
            'You Did Great',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'You took action to help yourself feel better. That takes courage and strength.',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Record SOS completion event before closing
                final sessionDuration = DateTime.now().difference(_sessionStartTime!).inSeconds;
                await _eventsService.recordEvent(AppEvent.sosSessionCompleted(
                  timestamp: DateTime.now(),
                  actionType: _completedActionType,
                  sessionDurationSeconds: sessionDuration,
                  additionalData: {
                    'sessionStartTime': _sessionStartTime!.toIso8601String(),
                  },
                ));
                
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Close SOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalmingMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.indigo.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'You\'re Safe Here',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Take a deep breath. This moment is temporary. You have the strength to get through this.',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag,
                size: 24,
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 12),
              const Text(
                'Remember Your Goal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re working toward something important. This temporary moment doesn\'t define your journey.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 16),
          GoalProgressCard(
            goalData: _activeGoal!,
            variant: GoalCardSize.expanded,
          ),
        ],
      ),
    );
  }

  Widget _buildUrgeSurfingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.waves,
              size: 32,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ride Out This Urge',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start an immediate urge surfing session to help you through this moment',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startRandomUrgeSurfing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Urge Surfing Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other Ways to Cope',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        
        // Breathing exercise option
        _buildSupportOption(
          icon: Icons.air,
          iconColor: Colors.green.shade600,
          title: 'Deep Breathing',
          subtitle: 'Simple 4-7-8 breathing technique',
          onTap: () => _showBreathingExercise(),
        ),
        
        const SizedBox(height: 12),
        
        // Grounding exercise option
        _buildSupportOption(
          icon: Icons.psychology,
          iconColor: Colors.purple.shade600,
          title: '5-4-3-2-1 Grounding',
          subtitle: 'Connect with your senses',
          onTap: () => _showGroundingExercise(),
        ),
      ],
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showBreathingExercise() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BreathingExerciseModal(),
    ).then((_) => _markActionCompleted('breathing_exercise'));
  }

  void _showGroundingExercise() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const GroundingExerciseModal(),
    ).then((_) => _markActionCompleted('grounding_exercise'));
  }
}
