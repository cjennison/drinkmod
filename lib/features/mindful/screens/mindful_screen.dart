import 'package:flutter/material.dart';
import '../models/meditation_config.dart';
import 'meditation_session_screen.dart';

/// Mindful page - Therapeutic mindfulness hub for alcohol moderation
class MindfulScreen extends StatefulWidget {
  const MindfulScreen({super.key});

  @override
  State<MindfulScreen> createState() => _MindfulScreenState();
}

class _MindfulScreenState extends State<MindfulScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with SOS button
              _buildHeader(context),
              
              const SizedBox(height: 24),
              
              // Mindfulness exercises section
              _buildMindfulnessSection(context),
              
              const SizedBox(height: 32),
              
              // Reflection section
              _buildReflectionSection(context),
              
              const SizedBox(height: 32),
              
              // Insights section
              _buildInsightsSection(context),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mindful',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Take a moment for yourself',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        
        // SOS Emergency Button
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // TODO: Navigate to emergency urge surfing
                _showSOSDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SOS',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMindfulnessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Mindfulness Exercises',
          'Ground yourself in the present moment',
          Icons.self_improvement,
        ),
        
        const SizedBox(height: 16),
        
        // Primary urge surfing cards
        _buildUrgeSurfingCard(context),
        
        const SizedBox(height: 16),
        
        // Additional mindfulness exercises
        Row(
          children: [
            Expanded(
              child: _buildMindfulnessExerciseCard(
                context,
                'Body Scan',
                'Release tension',
                '3 min',
                Icons.accessibility_new,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMindfulnessExerciseCard(
                context,
                'Loving-Kindness',
                'Self-compassion',
                '3 min',
                Icons.favorite_outline,
                Colors.pink,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildMindfulnessExerciseCard(
                context,
                'Quick Check-In',
                'How are you feeling?',
                '2 min',
                Icons.mood,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMindfulnessExerciseCard(
                context,
                'RAIN Technique',
                'Process emotions',
                '4 min',
                Icons.wb_cloudy,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReflectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Personal Reflection',
          'Notes for your journey',
          Icons.edit_note,
        ),
        
        const SizedBox(height: 16),
        
        // Reflection categories
        _buildReflectionCard(
          context,
          'Daily Check-In',
          'How am I feeling today?',
          Icons.today,
          Colors.blue,
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildReflectionCard(
                context,
                'Gratitude',
                'What went well?',
                Icons.star,
                Colors.amber,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReflectionCard(
                context,
                'Triggers',
                'What challenged me?',
                Icons.warning_amber,
                Colors.orange,
                isCompact: true,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildReflectionCard(
                context,
                'Values',
                'What matters to me?',
                Icons.favorite,
                Colors.purple,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildReflectionCard(
                context,
                'Progress',
                'How have I grown?',
                Icons.trending_up,
                Colors.green,
                isCompact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Mindfulness Insights',
          'Your mindful journey patterns',
          Icons.insights,
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                context,
                'Session History',
                'Track your practice',
                Icons.history,
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                context,
                'Mood Patterns',
                'Emotional trends',
                Icons.psychology,
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUrgeSurfingCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to urge surfing meditation
            _startUrgeSurfingMeditation(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.waves,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Urge Surfing',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Ride out cravings mindfully',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Visual metaphor options
                Row(
                  children: [
                    Expanded(
                      child: _buildUrgeSurfingOption(
                        context,
                        'Wave',
                        '30-60s',
                        Colors.blue,
                        Icons.waves,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildUrgeSurfingOption(
                        context,
                        'Candle',
                        '45-90s',
                        Colors.orange,
                        Icons.local_fire_department,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildUrgeSurfingOption(
                        context,
                        'Bubble',
                        '30-45s',
                        Colors.purple,
                        Icons.bubble_chart,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrgeSurfingOption(
    BuildContext context,
    String label,
    String duration,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            duration,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMindfulnessExerciseCard(
    BuildContext context,
    String title,
    String subtitle,
    String duration,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to specific meditation
            _startMeditation(context, title);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionCard(
    BuildContext context,
    String title,
    String prompt,
    IconData icon,
    Color color, {
    bool isCompact = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate to reflection prompt
            _showReflectionDialog(context, title, prompt);
          },
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        icon,
                        color: color,
                        size: isCompact ? 16 : 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: (isCompact 
                                ? theme.textTheme.titleSmall 
                                : theme.textTheme.titleMedium)?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (!isCompact) ...[
                            const SizedBox(height: 4),
                            Text(
                              prompt,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isCompact)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 14,
                      ),
                  ],
                ),
                if (isCompact) ...[
                  const SizedBox(height: 8),
                  Text(
                    prompt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navigate to insights
            _showInsightsDialog(context, title);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigation methods for meditation experiences
  void _startUrgeSurfingMeditation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Your Urge Surfing Experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Select a visual metaphor that resonates with you:'),
            const SizedBox(height: 20),
            
            // Wave option
            ListTile(
              leading: Icon(Icons.waves, color: Colors.blue, size: 24),
              title: const Text('Wave'),
              subtitle: const Text('30-60 seconds - Rise, peak, and recede'),
              onTap: () {
                Navigator.of(context).pop();
                _launchMeditation(context, 'urge_surfing_wave');
              },
            ),
            
            // Candle option
            ListTile(
              leading: Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              title: const Text('Candle'),
              subtitle: const Text('45-90 seconds - Burn bright and extinguish'),
              onTap: () {
                Navigator.of(context).pop();
                _launchMeditation(context, 'urge_surfing_candle');
              },
            ),
            
            // Bubble option
            ListTile(
              leading: Icon(Icons.bubble_chart, color: Colors.purple, size: 24),
              title: const Text('Bubble'),
              subtitle: const Text('30-45 seconds - Form, expand, and pop'),
              onTap: () {
                Navigator.of(context).pop();
                _launchMeditation(context, 'urge_surfing_bubble');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startMeditation(BuildContext context, String title) {
    String? meditationId;
    
    switch (title) {
      case 'Body Scan':
        meditationId = 'body_scan';
        break;
      case 'Loving-Kindness':
        meditationId = 'loving_kindness';
        break;
      case 'Quick Check-In':
        meditationId = 'quick_checkin';
        break;
      case 'RAIN Technique':
        meditationId = 'rain_technique';
        break;
      default:
        meditationId = 'basic_mindfulness';
    }
    
    _launchMeditation(context, meditationId);
  }

  void _launchMeditation(BuildContext context, String meditationId) {
    final config = MeditationRegistry.getMeditationById(meditationId);
    
    if (config == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meditation not found')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeditationSessionScreen(
          config: config,
          // TODO: Add mood/urge intensity inputs
        ),
      ),
    );
  }

  void _showReflectionDialog(BuildContext context, String title, String prompt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reflection prompt: "$prompt"'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Write your thoughts...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // TODO: Save reflection entry
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Save and close
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showInsightsDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('$title insights and analytics would appear here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SOS - Urge Support'),
        content: const Text('Quick access to urge surfing exercises.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startUrgeSurfingMeditation(context);
            },
            child: const Text('Start Urge Surfing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
