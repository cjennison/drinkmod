/// Configuration for a meditation experience
class MeditationConfig {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final List<String> script;
  final String backgroundColor; // Hex color
  final String? lottieAssetPath; // Optional Lottie animation
  final bool hasBreathingCircle;
  final String breathingPattern; // 'standard', 'calm', 'energize'
  final Map<String, dynamic> metadata;

  MeditationConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.script,
    required this.backgroundColor,
    this.lottieAssetPath,
    this.hasBreathingCircle = true,
    this.breathingPattern = 'standard',
    this.metadata = const {},
  });

  /// Factory method for urge surfing meditations
  factory MeditationConfig.urgeSurfing({
    required String metaphor,
    required String title,
    required String description,
    required List<String> script,
    required String backgroundColor,
    String? lottieAssetPath,
  }) {
    return MeditationConfig(
      id: 'urge_surfing_$metaphor',
      title: title,
      description: description,
      durationMinutes: 1, // More realistic for 18 script items
      script: script,
      backgroundColor: backgroundColor,
      lottieAssetPath: lottieAssetPath,
      hasBreathingCircle: true,
      breathingPattern: 'calm',
      metadata: {
        'type': 'urge_surfing',
        'metaphor': metaphor,
      },
    );
  }

  /// Factory method for general mindfulness meditations
  factory MeditationConfig.mindfulness({
    required String id,
    required String title,
    required String description,
    required int durationMinutes,
    required List<String> script,
    required String backgroundColor,
    String breathingPattern = 'standard',
  }) {
    return MeditationConfig(
      id: id,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      script: script,
      backgroundColor: backgroundColor,
      hasBreathingCircle: true,
      breathingPattern: breathingPattern,
      metadata: {
        'type': 'mindfulness',
      },
    );
  }

  /// Get color from hex string
  int get colorValue {
    return int.parse(backgroundColor.replaceAll('#', '0xFF'));
  }

  /// Get breathing cycle duration based on pattern
  Duration get breathingCycleDuration {
    switch (breathingPattern) {
      case 'calm':
        return const Duration(seconds: 12); // 5 breaths per minute (deep relaxation)
      case 'energize':
        return const Duration(seconds: 8); // 7.5 breaths per minute (gentle energy)
      case 'standard':
      default:
        return const Duration(seconds: 10); // 6 breaths per minute (optimal for meditation)
    }
  }
}

/// Registry of all available meditations
class MeditationRegistry {
  static final List<MeditationConfig> _meditations = [
    // General Mindfulness Meditation
    MeditationConfig(
      id: 'basic_mindfulness',
      title: 'Basic Mindfulness',
      description: 'A gentle introduction to mindful awareness',
      durationMinutes: 5,
      backgroundColor: '#4A90E2', // Calm blue
      script: [
        'Welcome to this moment of mindfulness.',
        'Find a comfortable position and let your body settle.',
        'Notice that you\'ve taken this time for yourself.',
        
        'Begin to notice your breathing.',
        'There\'s no need to change it.',
        'Simply observe each breath as it comes and goes.',
        
        'When your mind wanders, that\'s completely normal.',
        'Gently guide your attention back to your breath.',
        'This returning is the practice.',
        
        'Feel the rhythm of your breathing.',
        'Notice the pause between inhale and exhale.',
        'Rest in this natural rhythm.',
        
        'If thoughts arise, acknowledge them kindly.',
        'Then let them pass like clouds in the sky.',
        'Return to the anchor of your breath.',
        
        'Take a moment to appreciate this practice.',
        'You\'ve given yourself the gift of presence.',
        'Carry this awareness with you.',
      ],
    ),

    // Urge Surfing - Wave
    MeditationConfig.urgeSurfing(
      metaphor: 'wave',
      title: 'Wave Urge Surfing',
      description: 'Ride out cravings like ocean waves',
      backgroundColor: '#2E86AB', // Ocean blue
      lottieAssetPath: 'assets/animations/wave.json',
      script: [
        'Notice the urge you\'re experiencing right now.',
        'See it as a wave building in the ocean.',
        'Waves always rise, peak, and fall.',
        
        'Feel the urge building like water gathering.',
        'It may feel intense, and that\'s okay.',
        'Remember, this is temporary.',
        
        'The wave is reaching its peak now.',
        'Notice its strength without fighting it.',
        'You are the surfer, riding this wave.',
        
        'Feel the wave beginning to crest.',
        'Its power is starting to diminish.',
        'You\'re surfing with skill and awareness.',
        
        'The wave is receding back to the ocean.',
        'Notice how the intensity naturally fades.',
        'You have successfully surfed this urge.',
        
        'Take a moment to appreciate your strength.',
        'You didn\'t fight the wave, you rode it.',
        'This is your power over urges.',
      ],
    ),

    // Urge Surfing - Candle
    MeditationConfig.urgeSurfing(
      metaphor: 'candle',
      title: 'Candle Urge Surfing',
      description: 'Watch urges burn bright and naturally extinguish',
      backgroundColor: '#E17055', // Warm orange
      lottieAssetPath: 'assets/animations/candle.json',
      script: [
        'Imagine your urge as a candle flame.',
        'See it flickering to life in your awareness.',
        'Flames burn bright but always fade.',
        
        'Watch the flame grow taller and brighter.',
        'Feel its warmth without being burned.',
        'You are safely observing from a distance.',
        
        'The flame is burning at its brightest now.',
        'Notice its color, its movement, its energy.',
        'But remember, flames need fuel to survive.',
        
        'See how the flame begins to flicker.',
        'Without feeding it, it starts to dim.',
        'This is the natural way of all flames.',
        
        'Watch as the flame grows smaller and smaller.',
        'It\'s peacefully returning to stillness.',
        'Only a gentle warmth remains.',
        
        'The candle has taught you its wisdom.',
        'Urges burn bright but naturally fade.',
        'You have the power to simply observe.',
      ],
    ),

    // Urge Surfing - Bubble
    MeditationConfig.urgeSurfing(
      metaphor: 'bubble',
      title: 'Bubble Urge Surfing',
      description: 'Let urges form and pop like soap bubbles',
      backgroundColor: '#A29BFE', // Soft purple
      lottieAssetPath: 'assets/animations/bubble.json',
      script: [
        'Picture your urge as a soap bubble.',
        'See it forming in your mind\'s eye.',
        'Bubbles are beautiful but fragile.',
        
        'Watch the bubble grow larger and larger.',
        'Its surface shimmers with rainbow colors.',
        'But notice how delicate it really is.',
        
        'The bubble floats gently in your awareness.',
        'It\'s at its largest size now.',
        'Beautiful, translucent, and temporary.',
        
        'See how the bubble begins to tremble.',
        'Its surface becomes thinner and thinner.',
        'This is the natural way of all bubbles.',
        
        'With a gentle pop, the bubble disappears.',
        'Only tiny droplets remain in the air.',
        'The urge has dissolved just as naturally.',
        
        'You watched with curiosity and patience.',
        'You didn\'t try to pop or preserve it.',
        'This gentle observation is your strength.',
      ],
    ),

    // Body Scan Meditation
    MeditationConfig.mindfulness(
      id: 'body_scan',
      title: 'Body Scan',
      description: 'Release tension and connect with your body',
      durationMinutes: 5, // More realistic for 21 script items
      backgroundColor: '#00B894', // Healing green
      breathingPattern: 'calm',
      script: [
        'Settle into a comfortable position.',
        'Let your body sink into the support beneath you.',
        'We\'ll journey through your body with kindness.',
        
        'Start by noticing your feet.',
        'Feel any sensations in your toes.',
        'Send breath and relaxation to your feet.',
        
        'Move your attention to your legs.',
        'Notice your calves, your knees, your thighs.',
        'Let any tension melt away.',
        
        'Bring awareness to your abdomen.',
        'Feel it rise and fall with each breath.',
        'This is your center of calm.',
        
        'Notice your chest and heart area.',
        'Feel the gentle rhythm of your heartbeat.',
        'Appreciate how your body sustains you.',
        
        'Scan through your arms and hands.',
        'From shoulders down to fingertips.',
        'Let them rest completely.',
        
        'Finally, soften your face and head.',
        'Release your jaw, your eyes, your forehead.',
        'Your whole body is now relaxed and aware.',
      ],
    ),

    // Loving-Kindness Meditation
    MeditationConfig.mindfulness(
      id: 'loving_kindness',
      title: 'Loving-Kindness',
      description: 'Cultivate compassion for yourself and others',
      durationMinutes: 6,
      backgroundColor: '#FD79A8', // Compassionate pink
      script: [
        'Place one hand on your heart.',
        'Feel the warmth and gentle pressure.',
        'Begin with kindness toward yourself.',
        
        'Silently say: "May I be happy."',
        'Feel the intention behind these words.',
        'Let kindness flow toward yourself.',
        
        'Continue: "May I be healthy and strong."',
        'Wish yourself well-being and vitality.',
        'You deserve care and compassion.',
        
        'Now say: "May I be at peace."',
        'Imagine peace settling in your heart.',
        'Feel the gentleness you\'re offering yourself.',
        
        'Think of someone you love.',
        'Send them the same loving wishes.',
        'May they be happy, healthy, and at peace.',
        
        'Expand this to include all beings.',
        'May everyone be free from suffering.',
        'May all beings find happiness and peace.',
        
        'Return to yourself with this expanded heart.',
        'You are connected to all life through kindness.',
        'Carry this compassion with you.',
      ],
    ),

    // RAIN Technique
    MeditationConfig.mindfulness(
      id: 'rain_technique',
      title: 'RAIN Technique',
      description: 'Process emotions with mindful awareness',
      durationMinutes: 4,
      backgroundColor: '#74B9FF', // Calming sky blue
      breathingPattern: 'calm',
      script: [
        'Find a comfortable position and settle in.',
        'Bring to mind something that\'s troubling you.',
        'We\'ll use RAIN to work with this difficulty.',
        
        'First, RECOGNIZE what\'s happening.',
        'What emotions are present right now?',
        'Name them gently: anger, sadness, fear, frustration.',
        
        'Simply notice without trying to change anything.',
        'Recognition is the first step to healing.',
        'You\'re developing emotional awareness.',
        
        'Now, ALLOW the experience to be here.',
        'Stop fighting or pushing away these feelings.',
        'Let them exist in your awareness.',
        
        'Say to yourself: "This is what\'s here right now."',
        'Allow doesn\'t mean you like it or agree with it.',
        'It means you\'re not adding resistance to pain.',
        
        'Next, INVESTIGATE with kindness.',
        'Where do you feel this in your body?',
        'What thoughts are arising?',
        
        'Ask yourself: "What does this part of me need?"',
        'Investigate like a caring friend would.',
        'Be curious rather than judgmental.',
        
        'Finally, NON-ATTACHMENT or loving presence.',
        'This experience doesn\'t define who you are.',
        'You are the awareness that observes these feelings.',
        
        'Offer yourself the same compassion you\'d give a friend.',
        'These difficult moments are part of being human.',
        'You have the strength to be with whatever arises.',
        
        'Take a moment to appreciate your courage.',
        'You\'ve practiced being present with difficulty.',
        'This is the path of emotional wisdom.',
      ],
    ),

    // Quick Check-In
    MeditationConfig.mindfulness(
      id: 'quick_checkin',
      title: 'Quick Check-In',
      description: 'A brief moment to connect with yourself',
      durationMinutes: 2,
      backgroundColor: '#FDCB6E', // Warm yellow
      breathingPattern: 'standard',
      script: [
        'Take a moment to pause and arrive.',
        'This is your time to check in with yourself.',
        'How are you feeling right now?',
        
        'Notice your body first.',
        'Are you holding tension anywhere?',
        'Breathe into those areas and soften.',
        
        'What\'s your energy level?',
        'High, low, or somewhere in between?',
        'There\'s no right or wrong answer.',
        
        'How is your mind today?',
        'Busy, calm, scattered, focused?',
        'Just notice without judgment.',
        
        'What emotions are present?',
        'Happy, stressed, excited, worried?',
        'All feelings are welcome here.',
        
        'What do you need right now?',
        'Rest, movement, connection, space?',
        'Trust your inner wisdom.',
        
        'Take three deep breaths.',
        'Thank yourself for taking this moment.',
        'You are worth checking in with.',
        
        'Carry this awareness with you.',
        'You can return to this check-in anytime.',
        'Your well-being matters.',
      ],
    ),
  ];

  /// Get all available meditations
  static List<MeditationConfig> get allMeditations => _meditations;

  /// Get meditation by ID
  static MeditationConfig? getMeditationById(String id) {
    try {
      return _meditations.firstWhere((meditation) => meditation.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get urge surfing meditations
  static List<MeditationConfig> get urgeSurfingMeditations {
    return _meditations
        .where((meditation) => meditation.metadata['type'] == 'urge_surfing')
        .toList();
  }

  /// Get general mindfulness meditations
  static List<MeditationConfig> get mindfulnessMeditations {
    return _meditations
        .where((meditation) => meditation.metadata['type'] == 'mindfulness')
        .toList();
  }

  /// Get meditation by metaphor (for urge surfing)
  static MeditationConfig? getUrgeSurfingByMetaphor(String metaphor) {
    try {
      return _meditations.firstWhere(
        (meditation) => 
            meditation.metadata['type'] == 'urge_surfing' &&
            meditation.metadata['metaphor'] == metaphor,
      );
    } catch (e) {
      return null;
    }
  }

  /// Add new meditation (for future expansion)
  static void registerMeditation(MeditationConfig meditation) {
    // In a real app, this would update the registry
    // For now, we use the const list above
  }
}
