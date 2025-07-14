import 'package:flutter/material.dart';

/// Therapeutic intervention screen shown when user tries to log a drink after reaching their limit
class LimitExceededWarningScreen extends StatefulWidget {
  final double currentDrinks;
  final int dailyLimit;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  const LimitExceededWarningScreen({
    super.key,
    required this.currentDrinks,
    required this.dailyLimit,
    required this.onProceed,
    required this.onCancel,
  });

  @override
  State<LimitExceededWarningScreen> createState() => _LimitExceededWarningScreenState();
}

class _LimitExceededWarningScreenState extends State<LimitExceededWarningScreen> {
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
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
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
            // Warning header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade600,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You\'ve reached your daily limit',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.currentDrinks.toStringAsFixed(1)} of ${widget.dailyLimit} drinks today',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Therapeutic check-in
            Text(
              'Let\'s take a moment to check in',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Before you have another drink, let\'s reflect on how you\'re feeling right now.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Mood check
            _buildMoodSelector(),
            
            const SizedBox(height: 24),
            
            // Reason selector
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

  Widget _buildMoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling right now? (1-10)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(10, (index) {
                final mood = index + 1;
                final isSelected = _currentMood == mood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentMood = mood;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text(
                        mood.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('😢 Low', style: Theme.of(context).textTheme.bodySmall),
                Text('😊 High', style: Theme.of(context).textTheme.bodySmall),
              ],
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
          label: const Text('I\'ll stick to my goal'),
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
          icon: const Icon(Icons.warning_amber_rounded),
          label: const Text('Continue anyway'),
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
}
