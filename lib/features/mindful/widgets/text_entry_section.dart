import 'package:flutter/material.dart';

/// Text entry section with suggestions and smart features
class TextEntrySection extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final List<String> suggestions;

  const TextEntrySection({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 3,
    this.suggestions = const [],
  });

  @override
  State<TextEntrySection> createState() => _TextEntrySectionState();
}

class _TextEntrySectionState extends State<TextEntrySection> {
  bool _showSuggestions = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.controller.text.isEmpty) {
      setState(() => _showSuggestions = true);
    }
  }

  void _onTextChange() {
    if (widget.controller.text.isNotEmpty && _showSuggestions) {
      setState(() => _showSuggestions = false);
    } else if (widget.controller.text.isEmpty && !_showSuggestions) {
      setState(() => _showSuggestions = true);
    }
  }

  void _applySuggestion(String suggestion) {
    widget.controller.text = '${suggestion.substring(0, suggestion.length - 3)} '; // Remove "..." if present and add space
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length - 2), // -3 + 1 to account for space
    );
    _focusNode.requestFocus();
    setState(() => _showSuggestions = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        
        // Suggestions
        if (_showSuggestions && widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Need inspiration? Try one of these:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.suggestions.map((suggestion) {
              return InkWell(
                onTap: () => _applySuggestion(suggestion),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        
        // Character count (if near limit)
        if (widget.controller.text.length > 100) ...[
          const SizedBox(height: 8),
          Text(
            '${widget.controller.text.length} characters',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }
}
