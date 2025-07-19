import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart' as theme;
import '../../../core/models/app_event.dart';

/// Custom completion dialog that collects user feedback
class MeditationCompletionDialog extends StatefulWidget {
  final Function(bool feelsBetter) onComplete;

  const MeditationCompletionDialog({
    super.key,
    required this.onComplete,
  });

  @override
  State<MeditationCompletionDialog> createState() => _MeditationCompletionDialogState();
}

class _MeditationCompletionDialogState extends State<MeditationCompletionDialog> {
  bool? _feelsBetter;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: theme.AppTheme.transparentColor,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.AppTheme.blackMediumTransparent,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Session Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            const Text(
              'Well done on completing your meditation.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Feeling better question
            const Text(
              'Do you feel better than when you started?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Custom styled checkbox
            GestureDetector(
              onTap: () {
                setState(() {
                  _feelsBetter = !(_feelsBetter ?? false);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: (_feelsBetter ?? false) 
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_feelsBetter ?? false) 
                        ? Colors.green 
                        : Colors.grey.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: (_feelsBetter ?? false) 
                            ? Colors.green 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (_feelsBetter ?? false) 
                              ? Colors.green 
                              : Colors.grey.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: (_feelsBetter ?? false)
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Yes, I feel better',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onComplete(_feelsBetter ?? false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class to record meditation completion events
class MeditationCompletionTracker {
  static void recordCompletionEvent({
    required String sessionId,
    required String exerciseType,
    required int actualDurationSeconds,
    required bool feelsBetter,
    required String configId,
    required String configTitle,
  }) {
    // Create app event for meditation completion with feeling better data
    AppEvent.mindfulnessSessionCompleted(
      timestamp: DateTime.now(),
      sessionId: sessionId,
      exerciseType: exerciseType,
      actualDurationSeconds: actualDurationSeconds,
      additionalData: {
        'feelsBetter': feelsBetter,
        'configId': configId,
        'configTitle': configTitle,
      },
    );
    
    // TODO: Send event to analytics/tracking system
    print('📊 Meditation completion event: feelsBetter=$feelsBetter');
  }
}
