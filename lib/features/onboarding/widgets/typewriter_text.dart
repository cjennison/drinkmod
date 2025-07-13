import 'package:flutter/material.dart';
import 'dart:async';

/// A widget that displays text with a typewriter animation effect
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int typingSpeed;
  final Map<String, int> punctuationPauses;
  final VoidCallback? onComplete;
  final bool forceCompleted; // NEW: Forces text to show as completed

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.typingSpeed = 25,
    this.punctuationPauses = const {'.': 150, '!': 125, '?': 125, ',': 75},
    this.onComplete,
    this.forceCompleted = false, // NEW: Default to false
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    // If forceCompleted is true, show full text immediately
    if (widget.forceCompleted) {
      _displayedText = widget.text;
      _currentIndex = widget.text.length;
      _isCompleted = true;
    } else {
      _startTyping();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    if (_isCompleted) return; // Prevent restarting if already completed
    
    _timer = Timer.periodic(Duration(milliseconds: widget.typingSpeed), (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });

        // Check if we just added punctuation that needs a pause
        if (_currentIndex > 0) {
          final lastChar = widget.text[_currentIndex - 1];
          final pauseDuration = widget.punctuationPauses[lastChar];
          
          if (pauseDuration != null) {
            timer.cancel();
            Timer(Duration(milliseconds: pauseDuration), () {
              if (mounted && !_isCompleted) _startTyping();
            });
          }
        }
      } else {
        timer.cancel();
        _isCompleted = true;
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If forceCompleted changed to true, immediately complete
    if (!oldWidget.forceCompleted && widget.forceCompleted) {
      _timer?.cancel();
      setState(() {
        _displayedText = widget.text;
        _currentIndex = widget.text.length;
        _isCompleted = true;
      });
      return;
    }
    
    // If the text changed and not forced completed, reset and start typing the new text
    if (oldWidget.text != widget.text && !widget.forceCompleted && !_isCompleted) {
      _timer?.cancel();
      _displayedText = '';
      _currentIndex = 0;
      _isCompleted = false;
      _startTyping();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show full text immediately if forceCompleted or already completed
    final textToShow = (widget.forceCompleted || _isCompleted) ? widget.text : _displayedText;
    
    return Text(
      textToShow,
      style: widget.style,
    );
  }
}

/// A chat bubble widget for displaying agent messages
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isAgent;
  final bool showTypewriter;
  final VoidCallback? onTypewriterComplete;
  final bool isTypewriterCompleted; // NEW: Track if typewriter should be completed

  const ChatBubble({
    super.key,
    required this.message,
    this.isAgent = true,
    this.showTypewriter = true,
    this.onTypewriterComplete,
    this.isTypewriterCompleted = false, // NEW: Default to false
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Align(
        alignment: isAgent ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: showTypewriter && isAgent
              ? TypewriterText(
                  text: message,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  onComplete: onTypewriterComplete,
                  forceCompleted: isTypewriterCompleted, // NEW: Pass completion state
                )
              : Text(
                  message,
                  style: TextStyle(
                    color: isAgent 
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.primary,
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: isAgent ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
