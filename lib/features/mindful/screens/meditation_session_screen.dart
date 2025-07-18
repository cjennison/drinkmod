import 'dart:async';
import 'package:flutter/material.dart';
import '../models/meditation_config.dart';
import '../engines/meditation_engine.dart';
import '../engines/script_engine.dart';
import '../engines/breathing_engine.dart';
import '../widgets/meditation_completion_dialog.dart';
import '../../../core/models/mindfulness_session.dart';

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
    
    print('📈 Created progress controller with duration: ${widget.config.durationMinutes} minutes');
    
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
      print('📈 Starting progress animation');
      _progressController.forward();
    });
    
    _hideControlsAfterDelay();
  }

  void _onEngineChanged() {
    print('🔄 _onEngineChanged called - isComplete: ${_engine.isComplete}, completionDialogShown: $_completionDialogShown');
    if (_engine.isComplete && !_completionDialogShown) {
      print('✅ MEDITATION COMPLETE! Showing completion dialog');
      _completionDialogShown = true; // Prevent multiple dialogs
      // Stop the progress animation when meditation completes
      print('🎯 Stopping progress controller');
      _progressController.stop();
      // Set progress to 100% to ensure visual completion
      _progressController.value = 1.0;
      print('🎯 Progress set to 100%, showing completion dialog');
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
    print('🎉 _showCompletionDialog called - showing completion dialog');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MeditationCompletionDialog(
        onComplete: (feelsBetter) {
          _recordCompletionEvent(feelsBetter);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _recordCompletionEvent(bool feelsBetter) {
    // Record completion event using the separated tracker
    MeditationCompletionTracker.recordCompletionEvent(
      sessionId: _engine.currentSession?.id ?? '',
      exerciseType: _engine.currentSession?.exerciseType.name ?? 'unknown',
      actualDurationSeconds: _engine.elapsed.inSeconds,
      feelsBetter: feelsBetter,
      configId: widget.config.id,
      configTitle: widget.config.title,
    );
  }
}
