import 'dart:async';
import 'package:flutter/material.dart';
import '../models/meditation_config.dart';
import '../engines/script_engine.dart';
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
  bool _isCompleting = false; // Prevent multiple completion calls
  Duration _elapsed = Duration.zero;

  MeditationEngine({
    required this.config,
    MindfulnessRepository? repository,
  }) : _repository = repository ?? MindfulnessRepository() {
    _scriptEngine = ScriptEngine(
      script: config.script,
      displayDuration: const Duration(seconds: 4),
      fadeDuration: const Duration(milliseconds: 800),
      totalDuration: Duration(minutes: config.durationMinutes), // Pass total duration
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
  bool get isComplete {
    final timeComplete = _elapsed >= totalDuration;
    final scriptComplete = _scriptEngine.isComplete;
    final result = timeComplete || scriptComplete;
    
    if (result) {
      print('📊 isComplete=true: timeComplete=$timeComplete (${_elapsed.inSeconds}s/${totalDuration.inSeconds}s), scriptComplete=$scriptComplete');
    }
    
    return result;
  }

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
    print('🛑 STOP METHOD CALLED! isActive: $_isActive');
    if (!_isActive) {
      print('🛑 Stop called but not active, returning early');
      return;
    }

    print('🛑 Cancelling session timer');
    _sessionTimer?.cancel();
    print('🛑 Stopping script engine');
    _scriptEngine.stop();
    
    // Complete session in repository if it exists
    if (_currentSession != null) {
      print('🛑 Completing session in repository');
      final completed = await _repository.completeSession(
        _currentSession!.id,
        postMood: postMood,
        urgeIntensityAfter: urgeIntensityAfter,
        notes: notes,
      );
      _currentSession = completed;
      print('🛑 Session completed in repository');
    }
    
    print('🛑 Setting isActive=false, isPaused=false');
    _isActive = false;
    _isPaused = false;
    _isCompleting = false; // Reset completion flag
    
    print('🛑 Calling notifyListeners()');
    notifyListeners();
    print('🛑 Stop method finished');
  }

  /// Force complete the meditation
  Future<void> complete({
    MoodRating? postMood,
    int? urgeIntensityAfter,
    String? notes,
  }) async {
    print('🏁 COMPLETE METHOD CALLED! _isCompleting: $_isCompleting, _isActive: $_isActive');
    
    if (_isCompleting || !_isActive) {
      print('🏁 COMPLETE BLOCKED - Already completing or not active');
      return;
    }
    
    _isCompleting = true;
    print('🏁 COMPLETE PROCEEDING - Setting elapsed to total duration');
    _elapsed = totalDuration;
    print('🏁 Calling stop() method');
    await stop(
      postMood: postMood,
      urgeIntensityAfter: urgeIntensityAfter,
      notes: notes,
    );
    print('🏁 Complete method finished');
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
    print('📜 _onScriptChanged called - scriptComplete: ${_scriptEngine.isComplete}, isActive: $_isActive, elapsed: ${_elapsed.inSeconds}s');
    // Auto-complete when script finishes - but only if we're still actively running
    if (_scriptEngine.isComplete && _isActive && _elapsed < totalDuration) {
      print('📜 Script completed before time limit - calling complete()');
      complete();
    }
    notifyListeners();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    print('🕒 Starting session timer - total duration: ${totalDuration.inSeconds} seconds');
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isActive && !_isPaused) {
        _elapsed = _elapsed + const Duration(seconds: 1);
        
        final elapsedSeconds = _elapsed.inSeconds;
        final totalSeconds = totalDuration.inSeconds;
        final progress = (elapsedSeconds / totalSeconds * 100).toStringAsFixed(1);
        
        print('🕒 Timer tick: ${elapsedSeconds}s/${totalSeconds}s (${progress}%) - isComplete: $isComplete');
        
        // Check for completion
        if (_elapsed >= totalDuration) {
          print('⏰ TIME LIMIT REACHED! Calling complete()');
          complete();
          return;
        }
        
        // Check script engine completion
        if (_scriptEngine.isComplete) {
          print('📜 SCRIPT ENGINE COMPLETE! Calling complete()');
          complete();
          return;
        }
        
        notifyListeners();
      } else {
        print('🕒 Timer tick skipped - isActive: $_isActive, isPaused: $_isPaused');
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
