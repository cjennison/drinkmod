import 'package:flutter/material.dart';
import '../engines/breathing_engine.dart';

class BreathingExerciseModal extends StatefulWidget {
  const BreathingExerciseModal({super.key});

  @override
  State<BreathingExerciseModal> createState() => _BreathingExerciseModalState();
}

class _BreathingExerciseModalState extends State<BreathingExerciseModal> {
  bool _isActive = false;
  int _cycleCount = 0;
  final int _totalCycles = 4;

  void _startExercise() {
    setState(() {
      _isActive = true;
      _cycleCount = 0;
    });
    
    // Start counting cycles
    _startCycleCounter();
  }

  void _startCycleCounter() {
    Future.delayed(const Duration(seconds: 19), () {
      if (mounted && _isActive) {
        setState(() {
          _cycleCount++;
        });
        
        if (_cycleCount < _totalCycles) {
          _startCycleCounter();
        } else {
          _completeExercise();
        }
      }
    });
  }

  void _completeExercise() {
    setState(() {
      _isActive = false;
    });
    
    // Show completion message briefly before closing
    Future.delayed(const Duration(seconds: 2), () {
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.indigo.shade800,
              Colors.purple.shade800,
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
                  '4-7-8 Breathing',
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
            
            const SizedBox(height: 20),
            
            // Progress indicator
            if (_isActive) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cycle ${_cycleCount + 1} of $_totalCycles',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (_cycleCount + 1) / _totalCycles,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ] else ...[
              const Text(
                'Find a comfortable position and prepare to breathe',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const Spacer(),
            
            // Breathing circle
            Center(
              child: _isActive
                ? BreathingCircle(
                    cycleDuration: const Duration(seconds: 19), // 4+7+8 = 19 seconds total
                    color: Colors.white,
                    size: 200,
                    opacity: 0.8,
                    pattern: '4-7-8', // Use the new 4-7-8 pattern
                    isActive: _isActive,
                    showControls: true,
                    alwaysShowInstructions: true, // Keep instructions visible for SOS
                  )
                : Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.air,
                      size: 80,
                      color: Colors.white54,
                    ),
                  ),
            ),
            
            const Spacer(),
            
            // Instructions or completion message
            if (!_isActive && _cycleCount == 0) ...[
              const Text(
                'This breathing technique helps calm your nervous system:\n\n• Inhale for 4 counts\n• Hold for 7 counts\n• Exhale for 8 counts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Begin Breathing Exercise',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else if (_cycleCount >= _totalCycles) ...[
              const Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Great work! You\'ve completed the breathing exercise.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              BreathingInstructions(
                cycleDuration: const Duration(seconds: 19), // Match the 4-7-8 timing
                pattern: '4-7-8', // Use the new 4-7-8 pattern
                showInstructions: true,
                alwaysShowInstructions: true, // Keep instructions visible for SOS
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
