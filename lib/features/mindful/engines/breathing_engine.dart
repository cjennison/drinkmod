import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated breathing circle inspired by Headspace
/// Provides visual breathing guidance with customizable patterns
class BreathingCircle extends StatefulWidget {
  final Duration cycleDuration;
  final Color color;
  final double size;
  final double opacity;
  final String pattern; // 'standard', 'calm', 'energize'
  final bool isActive;

  const BreathingCircle({
    super.key,
    this.cycleDuration = const Duration(seconds: 6),
    this.color = Colors.white,
    this.size = 120,
    this.opacity = 0.3,
    this.pattern = 'standard',
    this.isActive = true,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: widget.cycleDuration,
      vsync: this,
    );

    // Create breathing animation based on pattern
    _breathingAnimation = _createBreathingAnimation();
    _pulseAnimation = _createPulseAnimation();

    if (widget.isActive) {
      _breathingController.repeat();
    }
  }

  Animation<double> _createBreathingAnimation() {
    switch (widget.pattern) {
      case 'calm':
        // Longer inhale, pause, longer exhale, pause (4-4-6-2 pattern)
        return TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.6, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
            weight: 25, // Inhale
          ),
          TweenSequenceItem(
            tween: ConstantTween(1.0),
            weight: 25, // Hold
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 0.6).chain(CurveTween(curve: Curves.easeOut)),
            weight: 37.5, // Exhale
          ),
          TweenSequenceItem(
            tween: ConstantTween(0.6),
            weight: 12.5, // Hold - ensures we end exactly where we started
          ),
        ]).animate(_breathingController);

      case 'energize':
        // Quick, energizing breathing pattern - ensure perfect loop
        return TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50, // Quick inhale
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 0.7).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50, // Quick exhale - ends exactly at start value
          ),
        ]).animate(_breathingController);

      case 'standard':
      default:
        // Standard 4-4 breathing pattern - ensure perfect loop
        return TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50, // Inhale
          ),
          TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 0.7).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 50, // Exhale - ends exactly at start value
          ),
        ]).animate(_breathingController);
    }
  }

  Animation<double> _createPulseAnimation() {
    // Subtle pulse that starts and ends at 1.0 for perfect looping
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.02).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.02, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_breathingController);
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _breathingController.repeat();
      } else {
        _breathingController.stop();
      }
    }
    
    if (oldWidget.cycleDuration != widget.cycleDuration) {
      _breathingController.duration = widget.cycleDuration;
      _breathingAnimation = _createBreathingAnimation();
      _pulseAnimation = _createPulseAnimation();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer breathing circle
              Container(
                width: widget.size * _breathingAnimation.value * _pulseAnimation.value,
                height: widget.size * _breathingAnimation.value * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: widget.opacity * 0.3),
                  border: Border.all(
                    color: widget.color.withValues(alpha: widget.opacity * 0.5),
                    width: 2,
                  ),
                ),
              ),
              
              // Inner core circle
              Container(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: widget.opacity * 0.6),
                ),
              ),
              
              // Breathing guide dots
              ..._buildGuideDots(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildGuideDots() {
    const dotCount = 8;
    final dots = <Widget>[];
    
    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * math.pi) / dotCount;
      final radius = widget.size * 0.45;
      
      dots.add(
        Positioned(
          left: (widget.size / 2) + (radius * math.cos(angle)) - 3,
          top: (widget.size / 2) + (radius * math.sin(angle)) - 3,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(
                alpha: widget.opacity * (0.3 + 0.4 * _breathingAnimation.value),
              ),
            ),
          ),
        ),
      );
    }
    
    return dots;
  }
}

/// Breathing instruction text that shows initial guidance only
class BreathingInstructions extends StatefulWidget {
  final Duration cycleDuration;
  final String pattern;
  final TextStyle? textStyle;
  final bool showInstructions;
  final Duration instructionDuration; // How long to show instructions

  const BreathingInstructions({
    super.key,
    this.cycleDuration = const Duration(seconds: 6),
    this.pattern = 'standard',
    this.textStyle,
    this.showInstructions = true,
    this.instructionDuration = const Duration(seconds: 12), // Show for 2 cycles
  });

  @override
  State<BreathingInstructions> createState() => _BreathingInstructionsState();
}

class _BreathingInstructionsState extends State<BreathingInstructions>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _currentInstruction = '';
  bool _showingInstructions = false;
  Timer? _instructionTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.cycleDuration,
      vsync: this,
    );

    _controller.addListener(_updateInstruction);
    
    if (widget.showInstructions) {
      _startInstructions();
    }
  }

  void _startInstructions() {
    setState(() {
      _showingInstructions = true;
    });
    
    _controller.repeat();
    
    // Stop showing instructions after the specified duration
    _instructionTimer = Timer(widget.instructionDuration, () {
      if (mounted) {
        setState(() {
          _showingInstructions = false;
          _currentInstruction = '';
        });
        _controller.stop();
      }
    });
  }

  void _updateInstruction() {
    if (!widget.showInstructions || !_showingInstructions) return;
    
    final progress = _controller.value;
    String newInstruction = '';

    switch (widget.pattern) {
      case 'calm':
        if (progress < 0.25) {
          newInstruction = 'Breathe in slowly';
        } else if (progress < 0.5) {
          newInstruction = 'Hold gently';
        } else if (progress < 0.875) {
          newInstruction = 'Breathe out slowly';
        } else {
          newInstruction = 'Rest';
        }
        break;

      case 'energize':
        if (progress < 0.4) {
          newInstruction = 'Breathe in';
        } else {
          newInstruction = 'Breathe out';
        }
        break;

      case 'standard':
      default:
        if (progress < 0.5) {
          newInstruction = 'Breathe in';
        } else {
          newInstruction = 'Breathe out';
        }
        break;
    }

    if (newInstruction != _currentInstruction) {
      setState(() {
        _currentInstruction = newInstruction;
      });
    }
  }

  @override
  void didUpdateWidget(BreathingInstructions oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.showInstructions != widget.showInstructions) {
      if (widget.showInstructions && !_showingInstructions) {
        _startInstructions();
      } else if (!widget.showInstructions) {
        _instructionTimer?.cancel();
        _controller.stop();
        setState(() {
          _currentInstruction = '';
          _showingInstructions = false;
        });
      }
    }
    
    if (oldWidget.cycleDuration != widget.cycleDuration) {
      _controller.duration = widget.cycleDuration;
    }
  }

  @override
  void dispose() {
    _instructionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showInstructions || !_showingInstructions || _currentInstruction.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_currentInstruction),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _currentInstruction,
          style: widget.textStyle ?? theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
