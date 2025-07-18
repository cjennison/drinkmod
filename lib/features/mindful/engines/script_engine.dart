import 'dart:async';
import 'package:flutter/material.dart';

/// Manages the meditation script display with fade in/out animations
class ScriptEngine extends ChangeNotifier {
  final List<String> _fullScript;
  Duration _displayDuration;
  final Duration _fadeDuration;
  final Duration _totalDuration; // Total meditation duration
  
  List<String> _currentGroup = [];
  int _currentGroupIndex = 0;
  int _currentSentenceIndex = 0;
  bool _isAnimating = false;
  bool _isComplete = false;
  Timer? _timer;

  ScriptEngine({
    required List<String> script,
    Duration displayDuration = const Duration(seconds: 4),
    Duration fadeDuration = const Duration(milliseconds: 800),
    Duration? totalDuration,
  })  : _fullScript = script,
        _displayDuration = displayDuration,
        _fadeDuration = fadeDuration,
        _totalDuration = totalDuration ?? Duration(minutes: 5) {
    // Calculate optimal display duration to fit the total meditation time
    _calculateOptimalTiming();
  }

  // Getters
  List<String> get currentGroup => _currentGroup;
  int get currentSentenceIndex => _currentSentenceIndex;
  bool get isAnimating => _isAnimating;
  bool get isComplete => _isComplete;
  int get totalGroups => (_fullScript.length / 3).ceil();
  int get currentGroupIndex => _currentGroupIndex;
  Duration get displayDuration => _displayDuration;

  /// Calculate optimal timing to fit the entire script within the total duration
  void _calculateOptimalTiming() {
    if (_fullScript.isEmpty) return;
    
    final totalGroups = (_fullScript.length / 3).ceil();
    final totalFadeTime = totalGroups * _fadeDuration.inMilliseconds;
    final availableTimeForDisplay = _totalDuration.inMilliseconds - totalFadeTime;
    
    // Each sentence gets equal time from the available display time
    final totalSentences = _fullScript.length;
    final optimalDisplayTimeMs = (availableTimeForDisplay / totalSentences).floor();
    
    // Ensure minimum 2 seconds, maximum 8 seconds per sentence
    final clampedTimeMs = optimalDisplayTimeMs.clamp(2000, 8000);
    
    _displayDuration = Duration(milliseconds: clampedTimeMs);
    
    print('📊 Script timing calculated:');
    print('  Total script items: ${_fullScript.length}');
    print('  Total groups: $totalGroups');
    print('  Total meditation duration: ${_totalDuration.inSeconds}s');
    print('  Calculated display duration per sentence: ${_displayDuration.inSeconds}s');
    print('  Expected script completion: ${_getExpectedScriptDuration().inSeconds}s');
  }

  /// Get the expected total duration for the script to complete
  Duration _getExpectedScriptDuration() {
    final totalGroups = (_fullScript.length / 3).ceil();
    final totalDisplayTime = _fullScript.length * _displayDuration.inMilliseconds;
    final totalFadeTime = totalGroups * _fadeDuration.inMilliseconds;
    return Duration(milliseconds: totalDisplayTime + totalFadeTime);
  }

  /// Start the script engine
  void start() {
    if (_isComplete) {
      reset();
    }
    _showNextGroup();
  }

  /// Stop the script engine
  void stop() {
    _timer?.cancel();
    _isAnimating = false;
    notifyListeners();
  }

  /// Reset the script engine
  void reset() {
    _timer?.cancel();
    _currentGroup = [];
    _currentGroupIndex = 0;
    _currentSentenceIndex = 0;
    _isAnimating = false;
    _isComplete = false;
    notifyListeners();
  }

  /// Skip to next group
  void skipToNext() {
    if (_isComplete) return;
    
    _timer?.cancel();
    _currentSentenceIndex = 0;
    _showNextGroup();
  }

  /// Show the next group of 3 sentences
  void _showNextGroup() {
    if (_currentGroupIndex * 3 >= _fullScript.length) {
      _complete();
      return;
    }

    // Get the next group of up to 3 sentences
    final startIndex = _currentGroupIndex * 3;
    final endIndex = (startIndex + 3).clamp(0, _fullScript.length);
    _currentGroup = _fullScript.sublist(startIndex, endIndex);
    _currentSentenceIndex = 0;
    _isAnimating = true;
    
    notifyListeners();

    // Start showing sentences one by one
    _showNextSentence();
  }

  /// Show the next sentence in the current group
  void _showNextSentence() {
    if (_currentSentenceIndex >= _currentGroup.length) {
      // All sentences in group shown, wait then fade out
      _timer = Timer(_displayDuration, () {
        _fadeOutGroup();
      });
      return;
    }

    // Show current sentence
    notifyListeners();
    
    // Schedule next sentence
    _timer = Timer(_displayDuration, () {
      _currentSentenceIndex++;
      _showNextSentence();
    });
  }

  /// Fade out the current group and move to next
  void _fadeOutGroup() {
    _isAnimating = false;
    notifyListeners();

    // After fade duration, show next group
    _timer = Timer(_fadeDuration, () {
      _currentGroupIndex++;
      _currentGroup = [];
      _showNextGroup();
    });
  }

  /// Complete the script
  void _complete() {
    _isComplete = true;
    _isAnimating = false;
    _currentGroup = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Widget that displays the meditation script with animations
class MeditationScriptDisplay extends StatefulWidget {
  final ScriptEngine scriptEngine;
  final TextStyle? textStyle;
  final double? height;

  const MeditationScriptDisplay({
    super.key,
    required this.scriptEngine,
    this.textStyle,
    this.height,
  });

  @override
  State<MeditationScriptDisplay> createState() => _MeditationScriptDisplayState();
}

class _MeditationScriptDisplayState extends State<MeditationScriptDisplay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    widget.scriptEngine.addListener(_onScriptEngineChanged);
  }

  void _onScriptEngineChanged() {
    if (widget.scriptEngine.isAnimating) {
      _fadeController.forward();
    } else {
      _fadeController.reverse();
    }
  }

  @override
  void dispose() {
    widget.scriptEngine.removeListener(_onScriptEngineChanged);
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: widget.height ?? 200,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.scriptEngine, _fadeAnimation]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.scriptEngine.currentGroup.asMap().entries.map((entry) {
                final index = entry.key;
                final sentence = entry.value;
                final isVisible = index <= widget.scriptEngine.currentSentenceIndex;
                
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: isVisible ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      sentence,
                      style: widget.textStyle ?? theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

/// Progress indicator for script progress
class ScriptProgressIndicator extends StatelessWidget {
  final ScriptEngine scriptEngine;
  final Color? color;

  const ScriptProgressIndicator({
    super.key,
    required this.scriptEngine,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scriptEngine,
      builder: (context, child) {
        final progress = scriptEngine.totalGroups > 0
            ? scriptEngine.currentGroupIndex / scriptEngine.totalGroups
            : 0.0;

        return LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: (color ?? Colors.white).withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation(color ?? Colors.white),
        );
      },
    );
  }
}
