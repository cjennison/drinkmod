import 'dart:async';
import 'package:flutter/material.dart';

class GroundingExerciseModal extends StatefulWidget {
  const GroundingExerciseModal({super.key});

  @override
  State<GroundingExerciseModal> createState() => _GroundingExerciseModalState();
}

class _GroundingExerciseModalState extends State<GroundingExerciseModal>
    with TickerProviderStateMixin {
  bool _hasStarted = false;
  int _currentStep = 0;
  int _currentCount = 0;
  bool _isCompleted = false;
  Timer? _progressTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _steps = [
    {
      'count': 5,
      'sense': 'See',
      'instruction': 'Name 5 things you can see around you',
      'icon': Icons.visibility,
      'color': Colors.blue,
      'examples': ['A wall', 'Your phone', 'A window', 'Your hands', 'The ceiling'],
    },
    {
      'count': 4,
      'sense': 'Touch',
      'instruction': 'Name 4 things you can touch',
      'icon': Icons.touch_app,
      'color': Colors.green,
      'examples': ['Your chair', 'Your clothes', 'The table', 'Your hair'],
    },
    {
      'count': 3,
      'sense': 'Hear',
      'instruction': 'Name 3 things you can hear',
      'icon': Icons.hearing,
      'color': Colors.orange,
      'examples': ['Traffic outside', 'Your breathing', 'Air conditioning'],
    },
    {
      'count': 2,
      'sense': 'Smell',
      'instruction': 'Name 2 things you can smell',
      'icon': Icons.air,
      'color': Colors.purple,
      'examples': ['Fresh air', 'Coffee'],
    },
    {
      'count': 1,
      'sense': 'Taste',
      'instruction': 'Name 1 thing you can taste',
      'icon': Icons.restaurant,
      'color': Colors.red,
      'examples': ['Mint', 'Coffee', 'Nothing - that\'s okay too!'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _hasStarted = true;
      _currentStep = 0;
      _currentCount = 0;
    });
  }

  void _nextItem() {
    setState(() {
      _currentCount++;
    });
    
    if (_currentCount >= _steps[_currentStep]['count']) {
      _nextStep();
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _currentCount = 0;
      });
    } else {
      _completeExercise();
    }
  }

  void _completeExercise() {
    setState(() {
      _isCompleted = true;
    });
    
    // Close after showing completion message
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _skipExercise() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.8, // Increased height to prevent clipping
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85, // Maximum height constraint
          minHeight: 600, // Minimum height to ensure content fits
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade800,
              Colors.cyan.shade700,
              Colors.blue.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '5-4-3-2-1 Grounding',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _skipExercise,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12), // Reduced spacing
            
            if (!_hasStarted) ...[
              _buildIntroSection(),
            ] else if (_isCompleted) ...[
              _buildCompletionSection(),
            ] else ...[
              _buildExerciseSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.psychology,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Ground Yourself',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'This exercise helps you reconnect with the present moment by engaging all your senses.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Preview of steps
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'You\'ll identify:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(_steps.map((step) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          step['icon'],
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            '${step['count']} things you can ${step['sense'].toLowerCase()}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Button with safe area
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Begin Grounding Exercise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSection() {
    final currentStepData = _steps[_currentStep];
    final totalCompleted = _steps.take(_currentStep).fold<int>(0, (sum, step) => sum + step['count'] as int) + _currentCount;
    final totalItems = _steps.fold<int>(0, (sum, step) => sum + step['count'] as int);
    
    return Expanded(
      child: Column(
        children: [
          // Progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of ${_steps.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$totalCompleted/$totalItems completed',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalCompleted / totalItems,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Current step icon with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (currentStepData['color'] as Color).withValues(alpha: 0.3),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    currentStepData['icon'],
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Current instruction
          Text(
            currentStepData['instruction'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Current count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentCount + 1} of ${currentStepData['count']}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Examples (if available) - made flexible to prevent overflow
          if ((currentStepData['examples'] as List).isNotEmpty) ...[
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Examples:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...((currentStepData['examples'] as List).take(3).map((example) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $example',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ] else
            const SizedBox(height: 20),
          
          // Next button with safe area
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentCount < currentStepData['count'] - 1 
                      ? 'Found One! Next Item'
                      : 'Complete This Step',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSection() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Well Done!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'You\'ve successfully completed the 5-4-3-2-1 grounding exercise. You should feel more connected to the present moment.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white70,
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(
                  'Remember, you can use this technique anytime you feel overwhelmed or disconnected.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
