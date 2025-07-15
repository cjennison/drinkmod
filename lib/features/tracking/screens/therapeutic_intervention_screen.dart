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
            Card(
              elevation: 2,
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Required Check-In',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All fields below are required to continue. This check-in helps you make mindful decisions and understand your patterns.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
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
      // Check if this is a tolerance vs hard failure state
      if (widget.interventionResult.isToleranceExceeded) {
        headerColor = Colors.red.shade600;
        headerIcon = Icons.cancel;
        headerTitle = 'Will be over limit';
      } else if (widget.interventionResult.isWithinTolerance) {
        headerColor = Colors.orange.shade600;
        headerIcon = Icons.warning;
        headerTitle = 'Over Limit - Within Tolerance';
      } else {
        // Check if already exceeded vs about to exceed
        final currentDrinks = widget.interventionResult.currentDrinks ?? 0;
        final dailyLimit = widget.interventionResult.dailyLimit ?? 2;
        if (currentDrinks >= dailyLimit) {
          headerColor = Colors.orange.shade600;
          headerIcon = Icons.warning;
          headerTitle = 'Tracking Additional Drink';
        } else {
          headerColor = Colors.red.shade600;
          headerIcon = Icons.warning;
          headerTitle = 'Daily Limit Reached';
        }
      }
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
            Row(
              children: [
                Text(
                  'How are you feeling right now?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Required',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
            Row(
              children: [
               
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Required',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
            Row(
              children: [
                Text(
                  'Take a moment to pause',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Required',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
        // Completion status indicator
        if (!canProceed) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Complete all sections to continue',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _currentMood != null ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: _currentMood != null ? Colors.green : Colors.red.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mood selection',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _currentMood != null ? Colors.green : Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _selectedReason != null ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: _selectedReason != null ? Colors.green : Colors.red.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reason selection',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _selectedReason != null ? Colors.green : Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _hasReflected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: _hasReflected ? Colors.green : Colors.red.shade400,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reflection confirmation',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _hasReflected ? Colors.green : Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
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
          icon: Icon(canProceed ? Icons.check_circle_outline : Icons.lock_outline),
          label: Text(canProceed ? _getProceedButtonText() : 'Complete check-in to proceed'),
          style: OutlinedButton.styleFrom(
            foregroundColor: canProceed ? Colors.orange.shade700 : Colors.grey.shade500,
            side: BorderSide(
              color: canProceed ? Colors.orange.shade300 : Colors.grey.shade300,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  String _getStayOnTrackButtonText() {
    if (widget.interventionResult.isScheduleViolation) {
      return 'Honor my alcohol-free day';
    } else if (widget.interventionResult.isLimitExceeded) {
      if (widget.interventionResult.isToleranceExceeded) {
        return 'I need to stop now';
      } else if (widget.interventionResult.isWithinTolerance) {
        return 'I\'ll stay in tolerance zone';
      } else {
        // Check if already exceeded vs about to exceed
        final currentDrinks = widget.interventionResult.currentDrinks ?? 0;
        final dailyLimit = widget.interventionResult.dailyLimit ?? 2;
        if (currentDrinks >= dailyLimit) {
          return 'I\'ll pause here';
        } else {
          return 'I\'ll stick to my goal';
        }
      }
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
      if (widget.interventionResult.isToleranceExceeded) {
        return 'Log drink anyway';
      } else if (widget.interventionResult.isWithinTolerance) {
        return 'Continue in tolerance';
      } else {
        // Check if already exceeded vs about to exceed
        final currentDrinks = widget.interventionResult.currentDrinks ?? 0;
        final dailyLimit = widget.interventionResult.dailyLimit ?? 2;
        if (currentDrinks >= dailyLimit) {
          return 'Log this drink';
        } else {
          return 'Continue anyway';
        }
      }
    } else {
      return 'Proceed mindfully';
    }
  }
}
