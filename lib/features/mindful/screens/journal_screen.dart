import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/journal_entry.dart';
import '../../../core/services/journal_service.dart';
import '../widgets/mood_selector.dart';
import '../widgets/mood_scales_widget.dart';
import '../widgets/text_entry_section.dart';
import '../widgets/emotion_tags_selector.dart';

/// Modern journal experience for mental health reflection
class JournalScreen extends StatefulWidget {
  final DateTime? initialDate;
  final String? deepLinkSection;
  
  const JournalScreen({
    super.key,
    this.initialDate,
    this.deepLinkSection,
  });

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> 
    with TickerProviderStateMixin {
  late JournalEntry _entry;
  bool _isLoading = true;
  bool _hasChanges = false;
  
  late PageController _pageController;
  int _currentPage = 0;
  
  // Section controllers for auto-save
  final Map<String, TextEditingController> _textControllers = {};
  
  // Journal sections for guided experience
  final List<JournalSectionConfig> _sections = [
    JournalSectionConfig(
      title: 'How are you feeling?',
      subtitle: 'Start with your overall mood',
      icon: Icons.mood,
      color: Colors.blue,
      type: JournalSectionType.mood,
    ),
    JournalSectionConfig(
      title: 'Mood Check-In',
      subtitle: 'Rate different aspects of your wellbeing',
      icon: Icons.analytics,
      color: Colors.teal,
      type: JournalSectionType.scales,
    ),
    JournalSectionConfig(
      title: 'Gratitude',
      subtitle: 'What are you grateful for today?',
      icon: Icons.favorite,
      color: Colors.pink,
      type: JournalSectionType.gratitude,
    ),
    JournalSectionConfig(
      title: 'Challenges',
      subtitle: 'What was difficult today?',
      icon: Icons.warning_amber,
      color: Colors.orange,
      type: JournalSectionType.challenges,
    ),
    JournalSectionConfig(
      title: 'Accomplishments',
      subtitle: 'What did you achieve today?',
      icon: Icons.star,
      color: Colors.amber,
      type: JournalSectionType.accomplishments,
    ),
    JournalSectionConfig(
      title: 'Emotions',
      subtitle: 'Explore your emotional experience',
      icon: Icons.psychology,
      color: Colors.purple,
      type: JournalSectionType.emotions,
    ),
    JournalSectionConfig(
      title: 'Free Writing',
      subtitle: 'Anything else on your mind?',
      icon: Icons.edit_note,
      color: Colors.green,
      type: JournalSectionType.freeform,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize PageController with correct initial page for deep linking
    final initialPage = _getInitialPageIndex();
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage);
    
    _initializeTextControllers();
    _loadJournalEntry();
  }
  
  int _getInitialPageIndex() {
    if (widget.deepLinkSection != null) {
      final index = _sections.indexWhere(
        (section) => section.type.name.toLowerCase() == widget.deepLinkSection!.toLowerCase(),
      );
      return index != -1 ? index : 0;
    }
    return 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeTextControllers() {
    _textControllers['gratitude'] = TextEditingController();
    _textControllers['challenges'] = TextEditingController();
    _textControllers['accomplishments'] = TextEditingController();
    _textControllers['emotions'] = TextEditingController();
    _textControllers['freeform'] = TextEditingController();
    
    // Add listeners for auto-save
    for (final entry in _textControllers.entries) {
      entry.value.addListener(() => _onTextChanged(entry.key));
    }
  }

  Future<void> _loadJournalEntry() async {
    try {
      final targetDate = widget.initialDate ?? DateTime.now();
      final entry = await JournalService.instance.getEntryByDate(targetDate) ??
                   JournalEntry(date: targetDate);
      
      setState(() {
        _entry = entry;
        _isLoading = false;
      });
      
      _populateControllers();
    } catch (e) {
      setState(() {
        _entry = JournalEntry(date: widget.initialDate ?? DateTime.now());
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    _textControllers['gratitude']?.text = _entry.gratitudeEntry ?? '';
    _textControllers['challenges']?.text = _entry.challengesEntry ?? '';
    _textControllers['accomplishments']?.text = _entry.accomplishmentsEntry ?? '';
    _textControllers['emotions']?.text = _entry.emotionsEntry ?? '';
    _textControllers['freeform']?.text = _entry.freeformEntry ?? '';
  }

  void _onTextChanged(String section) {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
    
    // Auto-save after 2 seconds of inactivity
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _saveEntry();
    });
  }

  Future<void> _saveEntry() async {
    if (!_hasChanges) return;
    
    try {
      final updatedEntry = _entry.copyWith(
        gratitudeEntry: _textControllers['gratitude']?.text,
        challengesEntry: _textControllers['challenges']?.text,
        accomplishmentsEntry: _textControllers['accomplishments']?.text,
        emotionsEntry: _textControllers['emotions']?.text,
        freeformEntry: _textControllers['freeform']?.text,
      );
      
      await JournalService.instance.saveEntry(updatedEntry);
      
      setState(() {
        _entry = updatedEntry;
        _hasChanges = false;
      });
      
    } catch (e) {
      // Silent error handling - could log to analytics if needed
    }
  }

  void _onMoodChanged(MoodLevel? mood) {
    setState(() {
      _entry = _entry.copyWith(overallMood: mood);
      _hasChanges = true;
    });
    _saveEntry();
  }

  void _onScaleChanged(String scale, int? value) {
    JournalEntry updatedEntry;
    
    switch (scale) {
      case 'anxiety':
        updatedEntry = _entry.copyWith(anxietyLevel: value);
        break;
      case 'stress':
        updatedEntry = _entry.copyWith(stressLevel: value);
        break;
      case 'energy':
        updatedEntry = _entry.copyWith(energyLevel: value);
        break;
      default:
        return;
    }
    
    setState(() {
      _entry = updatedEntry;
      _hasChanges = true;
    });
    _saveEntry();
  }

  void _onEmotionTagsChanged(List<String> tags) {
    setState(() {
      _entry = _entry.copyWith(emotionTags: tags);
      _hasChanges = true;
    });
    _saveEntry();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = _isToday(_entry.date);
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with date and progress
            _buildHeader(context, isToday),
            
            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  return _buildSectionPage(context, _sections[index]);
                },
              ),
            ),
            
            // Navigation
            _buildNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isToday) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isToday ? 'Today\'s Journal' : 'Journal Entry',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      dateFormat.format(_entry.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPage(BuildContext context, JournalSectionConfig config) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: config.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    config.icon,
                    color: config.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Section content
          _buildSectionContent(context, config),
        ],
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, JournalSectionConfig config) {
    switch (config.type) {
      case JournalSectionType.mood:
        return MoodSelector(
          selectedMood: _entry.overallMood,
          onMoodChanged: _onMoodChanged,
        );
        
      case JournalSectionType.scales:
        return MoodScalesWidget(
          anxietyLevel: _entry.anxietyLevel,
          stressLevel: _entry.stressLevel,
          energyLevel: _entry.energyLevel,
          onScaleChanged: _onScaleChanged,
        );
        
      case JournalSectionType.gratitude:
        return TextEntrySection(
          controller: _textControllers['gratitude']!,
          hintText: 'What brought you joy or appreciation today?',
          maxLines: 4,
          suggestions: const [
            'I\'m grateful for...',
            'Something that made me smile was...',
            'I appreciated when...',
            'A small moment that mattered...',
          ],
        );
        
      case JournalSectionType.challenges:
        return TextEntrySection(
          controller: _textControllers['challenges']!,
          hintText: 'What was difficult or challenging today?',
          maxLines: 4,
          suggestions: const [
            'I struggled with...',
            'Something that was hard was...',
            'I felt overwhelmed when...',
            'A challenge I faced...',
          ],
        );
        
      case JournalSectionType.accomplishments:
        return TextEntrySection(
          controller: _textControllers['accomplishments']!,
          hintText: 'What did you accomplish or do well today?',
          maxLines: 4,
          suggestions: const [
            'I\'m proud that I...',
            'Something I did well was...',
            'I accomplished...',
            'A success today was...',
          ],
        );
        
      case JournalSectionType.emotions:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmotionTagsSelector(
              selectedTags: _entry.emotionTags,
              onTagsChanged: _onEmotionTagsChanged,
            ),
            const SizedBox(height: 20),
            TextEntrySection(
              controller: _textControllers['emotions']!,
              hintText: 'Describe your emotions in more detail...',
              maxLines: 4,
              suggestions: const [
                'I felt...',
                'My emotions today were...',
                'I noticed I was feeling...',
                'Emotionally, I experienced...',
              ],
            ),
          ],
        );
        
      case JournalSectionType.freeform:
        return TextEntrySection(
          controller: _textControllers['freeform']!,
          hintText: 'Anything else you want to share about your day?',
          maxLines: 6,
          suggestions: const [
            'Something else on my mind...',
            'I want to remember...',
            'Looking ahead, I...',
            'Right now I\'m thinking...',
          ],
        );
    }
  }

  Widget _buildNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == _sections.length - 1;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Previous button
          if (!isFirstPage)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            )
          else
            const Expanded(child: SizedBox()),
          
          const SizedBox(width: 16),
          
          // Page indicator dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_sections.length, (index) {
              final isActive = index == _currentPage;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          
          const SizedBox(width: 16),
          
          // Next/Done button
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                if (isLastPage) {
                  Navigator.of(context).pop();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
              label: Text(isLastPage ? 'Done' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}

/// Configuration for journal sections
class JournalSectionConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final JournalSectionType type;

  const JournalSectionConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.type,
  });
}

/// Types of journal sections
enum JournalSectionType {
  mood,
  scales,
  gratitude,
  challenges,
  accomplishments,
  emotions,
  freeform,
}
