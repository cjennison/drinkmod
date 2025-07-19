import 'package:flutter/material.dart';
import '../../../core/models/journal_entry.dart';

/// Emotion tags selector for categorizing emotional experiences
class EmotionTagsSelector extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;

  const EmotionTagsSelector({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  State<EmotionTagsSelector> createState() => _EmotionTagsSelectorState();
}

class _EmotionTagsSelectorState extends State<EmotionTagsSelector>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _currentTags;

  final Map<String, List<String>> _emotionCategories = {
    'Positive': EmotionTags.positive,
    'Negative': EmotionTags.negative,
    'Neutral': EmotionTags.neutral,
  };

  final Map<String, Color> _categoryColors = {
    'Positive': Colors.green,
    'Negative': Colors.red,
    'Neutral': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentTags = List.from(widget.selectedTags);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_currentTags.contains(tag)) {
        _currentTags.remove(tag);
      } else {
        _currentTags.add(tag);
      }
    });
    widget.onTagsChanged(_currentTags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What emotions did you experience today?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Select all that apply',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Selected tags summary
        if (_currentTags.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected emotions (${_currentTags.length}):',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _currentTags.map((tag) {
                    final category = _getCategoryForTag(tag);
                    final color = _categoryColors[category] ?? Colors.grey;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: color.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _toggleTag(tag),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: color.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Emotion category tabs
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: _emotionCategories.keys.map((category) {
              final color = _categoryColors[category]!;
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(category),
                  ],
                ),
              );
            }).toList(),
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicator: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Emotion tags
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabController,
            children: _emotionCategories.entries.map((entry) {
              final category = entry.key;
              final tags = entry.value;
              final color = _categoryColors[category]!;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    final isSelected = _currentTags.contains(tag);
                    
                    return InkWell(
                      onTap: () => _toggleTag(tag),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? color.withValues(alpha: 0.2)
                              : theme.colorScheme.surfaceContainerHighest,
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected 
                                ? color
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getCategoryForTag(String tag) {
    for (final entry in _emotionCategories.entries) {
      if (entry.value.contains(tag)) {
        return entry.key;
      }
    }
    return 'Neutral';
  }
}
