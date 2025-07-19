import 'package:flutter/material.dart';

/// A tag selector widget for choosing emotion, activity, or trigger tags
class TagSelector extends StatelessWidget {
  final String title;
  final List<String> availableTags;
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;
  final Color color;

  const TagSelector({
    super.key,
    required this.title,
    required this.availableTags,
    required this.selectedTags,
    required this.onTagsChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            
            return GestureDetector(
              onTap: () {
                final newTags = List<String>.from(selectedTags);
                if (isSelected) {
                  newTags.remove(tag);
                } else {
                  newTags.add(tag);
                }
                onTagsChanged(newTags);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? color.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? color
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected 
                        ? color
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        if (selectedTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Selected: ${selectedTags.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => onTagsChanged([]),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear all',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
