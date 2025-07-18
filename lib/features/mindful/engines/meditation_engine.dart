import 'dart:async';
import 'package:flutter/material.dart';
import '../models/meditation_config.dart';
import '../engines/script_engine.dart';
import '../engines/breathing_engine.dart';
import '../../../core/models/mindfulness_session.dart';
import '../../../core/repositories/mindfulness_repository.dart';

/// Core meditation engine that orchestrates the entire meditation experience
class MeditationEngine extends ChangeNotifier {
  final MeditationConfig config;
  final MindfulnessRepository _repository;
  
  late ScriptEngine _scriptEngine;
  Timer? _sessionTimer;
  MindfulnessSession? _currentSession;
  
  bool _isActive = false;
  bool _isPaused = false;
  Duration _elapsed = Duration.zero;

  MeditationEngine({
    required this.config,
    MindfulnessRepository? repository,
  }) : _repository = repository ?? MindfulnessRepository() {
    _scriptEngine = ScriptEngine(
      script: config.script,
      displayDuration: const Duration(seconds: 4),
      fadeDuration: const Duration(milliseconds: 800),
    );
    
    _scriptEngine.addListener(_onScriptChanged);
  }

  // Getters
  ScriptEngine get scriptEngine => _scriptEngine;
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  Duration get elapsed => _elapsed;
  Duration get totalDuration => Duration(minutes: config.durationMinutes);
  double get progress => totalDuration.inMilliseconds > 0 
      ? _elapsed.inMilliseconds / totalDuration.inMilliseconds 
      : 0.0;
  MindfulnessSession? get currentSession => _currentSession;
  bool get isComplete => _elapsed >= totalDuration || _scriptEngine.isComplete;

  /// Start the meditation session
  Future<void> start({
    MoodRating? preMood,
    int? urgeIntensityBefore,
  }) async {
    if (_isActive) return;

    _isActive = true;
    _isPaused = false;
    _elapsed = Duration.zero;
    
    // Create session in repository
    final exerciseType = _getExerciseType();
    final metaphor = _getUrgeSurfingMetaphor();
    
    _currentSession = await _repository.startSession(
      exerciseType: exerciseType,
      metaphor: metaphor,
      plannedDurationSeconds: totalDuration.inSeconds,
      preMood: preMood,
      urgeIntensityBefore: urgeIntensityBefore,
    );

    // Start script engine
    _scriptEngine.start();
    
    // Start session timer
    _startSessionTimer();
    
    notifyListeners();
  }

  /// Pause the meditation
  void pause() {
    if (!_isActive || _isPaused) return;
    
    _isPaused = true;
    _sessionTimer?.cancel();
    _scriptEngine.stop();
    
    notifyListeners();
  }

  /// Resume the meditation
  void resume() {
    if (!_isActive || !_isPaused) return;
    
    _isPaused = false;
    _scriptEngine.start();
    _startSessionTimer();
    
    notifyListeners();
  }

  /// Stop the meditation session
  Future<void> stop({
    MoodRating? postMood,
    int? urgeIntensityAfter,
    String? notes,
  }) async {
    if (!_isActive) return;

    _sessionTimer?.cancel();
    _scriptEngine.stop();
    
    // Complete session in repository if it exists
    if (_currentSession != null) {
      final completed = await _repository.completeSession(
        _currentSession!.id,
        postMood: postMood,
        urgeIntensityAfter: urgeIntensityAfter,
        notes: notes,
      );
      _currentSession = completed;
    }
    
    _isActive = false;
    _isPaused = false;
    
    notifyListeners();
  }

  /// Force complete the meditation
  Future<void> complete({
    MoodRating? postMood,
    int? urgeIntensityAfter,
    String? notes,
  }) async {
    _elapsed = totalDuration;
    await stop(
      postMood: postMood,
      urgeIntensityAfter: urgeIntensityAfter,
      notes: notes,
    );
  }

  /// Reset the meditation engine
  void reset() {
    _sessionTimer?.cancel();
    _scriptEngine.reset();
    
    _isActive = false;
    _isPaused = false;
    _elapsed = Duration.zero;
    _currentSession = null;
    
    notifyListeners();
  }

  /// Skip to next script section
  void skipToNext() {
    if (_isActive && !_isPaused) {
      _scriptEngine.skipToNext();
    }
  }

  void _onScriptChanged() {
    // Auto-complete when script finishes
    if (_scriptEngine.isComplete && _isActive) {
      complete();
    }
    notifyListeners();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isActive && !_isPaused) {
        _elapsed = _elapsed + const Duration(seconds: 1);
        
        // Auto-complete when time limit reached
        if (_elapsed >= totalDuration) {
          complete();
          return;
        }
        
        notifyListeners();
      }
    });
  }

  MindfulnessExerciseType _getExerciseType() {
    switch (config.metadata['type']) {
      case 'urge_surfing':
        return MindfulnessExerciseType.urgeSurfing;
      case 'mindfulness':
        switch (config.id) {
          case 'body_scan':
            return MindfulnessExerciseType.bodyScan;
          case 'loving_kindness':
            return MindfulnessExerciseType.lovingKindness;
          default:
            return MindfulnessExerciseType.breathingExercise;
        }
      default:
        return MindfulnessExerciseType.breathingExercise;
    }
  }

  UrgeSurfingMetaphor? _getUrgeSurfingMetaphor() {
    if (config.metadata['type'] != 'urge_surfing') return null;
    
    switch (config.metadata['metaphor']) {
      case 'wave':
        return UrgeSurfingMetaphor.wave;
      case 'candle':
        return UrgeSurfingMetaphor.candle;
      case 'bubble':
        return UrgeSurfingMetaphor.bubble;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _scriptEngine.removeListener(_onScriptChanged);
    _scriptEngine.dispose();
    super.dispose();
  }
}

/// Meditation session screen with full Headspace-inspired experience
class MeditationSessionScreen extends StatefulWidget {
  final MeditationConfig config;
  final MoodRating? preMood;
  final int? urgeIntensityBefore;

  const MeditationSessionScreen({
    super.key,
    required this.config,
    this.preMood,
    this.urgeIntensityBefore,
  });

  @override
  State<MeditationSessionScreen> createState() => _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends State<MeditationSessionScreen>
    with TickerProviderStateMixin {
  late MeditationEngine _engine;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _showControls = true;
  Timer? _controlsTimer;
  bool _isUpdatingControls = false; // Prevent concurrent state updates
  bool _completionDialogShown = false; // Prevent multiple completion dialogs

  @override
  void initState() {
    super.initState();
    _engine = MeditationEngine(config: widget.config);
    _engine.addListener(_onEngineChanged);
    
    // Create progress animation controller for continuous progress bar
    _progressController = AnimationController(
      duration: Duration(minutes: widget.config.durationMinutes),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
    
    // Auto-start the meditation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _engine.start(
        preMood: widget.preMood,
        urgeIntensityBefore: widget.urgeIntensityBefore,
      );
      // Start the continuous progress animation
      _progressController.forward();
    });
    
    _hideControlsAfterDelay();
  }

  void _onEngineChanged() {
    if (_engine.isComplete && !_completionDialogShown) {
      _completionDialogShown = true; // Prevent multiple dialogs
      // Stop the progress animation when meditation completes
      _progressController.stop();
      // Set progress to 100% to ensure visual completion
      _progressController.value = 1.0;
      _showCompletionDialog();
    }
  }

  void _hideControlsAfterDelay() {
    print('⏰ _hideControlsAfterDelay called');
    _controlsTimer?.cancel();
    
    // Wait for one complete breathing cycle before hiding controls
    final breathingCycleDuration = widget.config.breathingCycleDuration;
    print('⏰ Waiting ${breathingCycleDuration.inSeconds} seconds (one breathing cycle) before hiding controls');
    
    _controlsTimer = Timer(breathingCycleDuration, () {
      print('⏰ Timer fired - checking if should hide controls');
      if (mounted && _showControls && !_isUpdatingControls) { // Only hide if currently showing and not updating
        print('⏰ Timer fired - hiding controls');
        _isUpdatingControls = true;
        setState(() {
          _showControls = false;
        });
        _isUpdatingControls = false;
        print('⏰ Controls hidden - _showControls: $_showControls');
      }
    });
  }

  void _toggleControls() {
    print('🔄 _toggleControls called - current _showControls: $_showControls');
    
    // Prevent rapid-fire toggles that could cause setState conflicts
    if (!mounted || _isUpdatingControls) return;
    
    _controlsTimer?.cancel(); // Cancel any existing timer first
    _isUpdatingControls = true;
    
    setState(() {
      _showControls = !_showControls;
    });
    _isUpdatingControls = false;
    print('🔄 _toggleControls after setState - new _showControls: $_showControls');
    
    // Only start timer if controls are now visible
    if (_showControls) {
      print('⏰ Starting hide controls timer');
      _hideControlsAfterDelay();
    }
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineChanged);
    _controlsTimer?.cancel();
    _progressController.dispose();
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔨 Build called - _showControls: $_showControls');
    return Scaffold(
      backgroundColor: Color(widget.config.colorValue),
      body: GestureDetector(
        onTap: () {
          print('👆 GestureDetector onTap triggered!');
          _toggleControls();
        },
        behavior: HitTestBehavior.opaque, // Ensure the entire area is tappable
        child: SafeArea(
          child: Stack(
            children: [
              // Main meditation content
              Column(
                children: [
                  // Top controls
                  IgnorePointer(
                    ignoring: !_showControls,
                    child: AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut, // Add smooth curve
                      child: _buildTopControls(),
                    ),
                  ),
                  
                  // Breathing circle with overlaid instructions
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Breathing circle
                          AnimatedBuilder(
                            animation: _engine,
                            builder: (context, child) {
                              return BreathingCircle(
                                cycleDuration: widget.config.breathingCycleDuration,
                                color: Colors.white,
                                size: 160,
                                opacity: 0.4,
                                pattern: widget.config.breathingPattern,
                                isActive: _engine.isActive && !_engine.isPaused,
                                showControls: _showControls,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Script display
                  Expanded(
                    flex: 1,
                    child: MeditationScriptDisplay(
                      scriptEngine: _engine.scriptEngine,
                      height: 150,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bottom controls
                  IgnorePointer(
                    ignoring: !_showControls,
                    child: AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut, // Add smooth curve
                      child: _buildBottomControls(),
                    ),
                  ),
                ],
              ),
              
              // Progress indicator
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 2,
                    );
                  },
                ),
              ),
              
              // Tap hint (shows briefly at start)
              if (_showControls)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 0.7 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut, // Add smooth curve
                    child: const Center(
                      child: Text(
                        'Tap anywhere to show/hide controls',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: _exitMeditation,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const Spacer(),
          Text(
            widget.config.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _engine,
            builder: (context, child) {
              final minutes = _engine.elapsed.inMinutes;
              final seconds = _engine.elapsed.inSeconds % 60;
              return Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Play/Pause button
          AnimatedBuilder(
            animation: _engine,
            builder: (context, child) {
              return IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _engine.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 48,
                ),
              );
            },
          ),
          
          // Stop button
          IconButton(
            onPressed: _exitMeditation,
            icon: const Icon(Icons.stop, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    if (_engine.isPaused) {
      _engine.resume();
      // Resume progress animation from current position
      _progressController.forward();
    } else {
      _engine.pause();
      // Pause progress animation
      _progressController.stop();
    }
  }

  void _exitMeditation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Meditation?'),
        content: const Text(
          'Are you sure you want to end this meditation session? Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Meditation'),
          ),
          TextButton(
            onPressed: () {
              // Stop progress animation
              _progressController.stop();
              Navigator.of(context).pop();
              _engine.stop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Meditation Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text('Well done! You\'ve completed your meditation session.'),
            const SizedBox(height: 16),
            const Text('How are you feeling now?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
