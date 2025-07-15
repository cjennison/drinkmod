import 'package:flutter/material.dart';
import '../../../core/utils/drink_intervention_utils.dart';

/// Universal therapeutic intervention screen for all drink logging interventions
/// Provides consistent therapeutic approach regardless of intervention type
class TherapeuticInterventionScreen extends StatefulWidget {
  final DrinkInterventionResult interventionResult;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  const TherapeuticInterventionScreen({
    super.key,
    required this.interventionResult,
    required this.onProceed,
    required this.onCancel,
  });

  @override
  State<TherapeuticInterventionScreen> createState() => _TherapeuticInterventionScreenState();
}

class _TherapeuticInterventionScreenState extends State<TherapeuticInterventionScreen> {
  int? _currentMood;
  String? _selectedReason;
  bool _hasReflected = false;

  final List<String> _reasons = [
    'Social pressure',
    'Stress or anxiety',
    'Celebration',
    'Habit or routine',
    'Emotional difficulty',
    'Peer influence',
    'Special occasion',
    'Boredom',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapeutic Check-In'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dynamic header based on intervention type
            _buildInterventionHeader(),
            
            const SizedBox(height: 24),
            
            // Universal therapeutic check-in
            Text(
              'Let\'s take a moment to check in',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Before you decide, let\'s reflect on how you\'re feeling right now.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Mood check
            _buildMoodSelector(),
            
            const SizedBox(height: 24),
            
            // Reason selection
            _buildReasonSelector(),
            
            const SizedBox(height: 24),
            
            // Reflection prompt
            _buildReflectionPrompt(),
            
            const SizedBox(height: 32),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionHeader() {
    Color headerColor;
    IconData headerIcon;
    String headerTitle;
    
    // Customize header based on intervention type
    if (widget.interventionResult.isScheduleViolation) {
      headerColor = Colors.orange.shade600;
      headerIcon = Icons.calendar_today;
      headerTitle = 'Alcohol-Free Day';
    } else if (widget.interventionResult.isLimitExceeded) {
      headerColor = Colors.red.shade600;
      headerIcon = Icons.warning;
      headerTitle = 'Daily Limit Reached';
    } else if (widget.interventionResult.isApproachingLimit) {
      headerColor = Colors.orange.shade600;
      headerIcon = Icons.warning_amber;
      headerTitle = 'Approaching Daily Limit';
    } else if (widget.interventionResult.isRetroactive) {
      headerColor = Colors.blue.shade600;
      headerIcon = Icons.history;
      headerTitle = 'Retroactive Entry';
    } else {
      headerColor = Colors.blue.shade600;
      headerIcon = Icons.info;
      headerTitle = 'Mindful Check-In';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: headerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: headerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            headerIcon,
            color: headerColor,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            headerTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: headerColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.interventionResult.userMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: headerColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This therapeutic information will help you understand your patterns and make mindful choices.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling right now?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final mood = index + 1;
                final emojis = ['😢', '😕', '😐', '😊', '😄'];
                final labels = ['Very Low', 'Low', 'Neutral', 'Good', 'Great'];
                final isSelected = _currentMood == mood;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentMood = mood;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          emojis[index],
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected 
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade600,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s driving this decision?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return FilterChip(
                  label: Text(reason),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedReason = selected ? reason : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionPrompt() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Take a moment to pause',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consider these questions:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Will this drink help me feel better tomorrow?\n'
                    '• What would my future self want me to do?\n'
                    '• Are there other ways to handle what I\'m feeling?\n'
                    '• How will I feel if I stick to my goal?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _hasReflected,
                        onChanged: (value) {
                          setState(() {
                            _hasReflected = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'I\'ve taken a moment to reflect on these questions',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final canProceed = _currentMood != null && _selectedReason != null && _hasReflected;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary action - stay on track
        ElevatedButton.icon(
          onPressed: widget.onCancel,
          icon: const Icon(Icons.favorite),
          label: Text(_getStayOnTrackButtonText()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary action - proceed anyway
        OutlinedButton.icon(
          onPressed: canProceed ? widget.onProceed : null,
          icon: const Icon(Icons.check_circle_outline),
          label: Text(_getProceedButtonText()),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange.shade700,
            side: BorderSide(color: Colors.orange.shade300),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        
        if (!canProceed) ...[
          const SizedBox(height: 8),
          Text(
            'Please complete the check-in above to continue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _getStayOnTrackButtonText() {
    if (widget.interventionResult.isScheduleViolation) {
      return 'Honor my alcohol-free day';
    } else if (widget.interventionResult.isLimitExceeded) {
      return 'I\'ll stick to my goal';
    } else if (widget.interventionResult.isApproachingLimit) {
      return 'Stop here for today';
    } else {
      return 'Choose differently';
    }
  }

  String _getProceedButtonText() {
    if (widget.interventionResult.isScheduleViolation) {
      return 'Continue logging';
    } else if (widget.interventionResult.isLimitExceeded || widget.interventionResult.isApproachingLimit) {
      return 'Continue anyway';
    } else {
      return 'Proceed mindfully';
    }
  }
}
