import 'dart:convert';
import 'package:flutter/services.dart';

/// Manages loading and parsing conversation scripts from JSON files
class ScriptManager {
  static ScriptManager? _instance;
  static ScriptManager get instance => _instance ??= ScriptManager._();
  ScriptManager._();

  Map<String, dynamic>? _scriptData;

  /// Load the onboarding script from assets
  Future<void> loadOnboardingScript() async {
    try {
      final String jsonString = await rootBundle.loadString('scripts/onboarding_script.json');
      _scriptData = json.decode(jsonString);
    } catch (e) {
      throw Exception('Failed to load onboarding script: $e');
    }
  }

  /// Get a conversation flow by name
  List<ChatMessage> getConversationFlow(String flowName) {
    if (_scriptData == null) {
      throw Exception('Script data not loaded. Call loadOnboardingScript() first.');
    }

    final flowData = _scriptData!['onboarding_flow'][flowName] as List<dynamic>?;
    if (flowData == null) {
      throw Exception('Conversation flow "$flowName" not found');
    }

    return flowData.map((item) => ChatMessage.fromJson(item)).toList();
  }

  /// Get typewriter configuration
  TypewriterConfig get typewriterConfig {
    if (_scriptData == null) {
      throw Exception('Script data not loaded');
    }
    
    final config = _scriptData!['typewriter_config'] as Map<String, dynamic>;
    return TypewriterConfig.fromJson(config);
  }

  /// Get recommendation logic configuration
  Map<String, dynamic> get recommendationLogic {
    if (_scriptData == null) {
      throw Exception('Script data not loaded');
    }
    
    return _scriptData!['recommendation_logic'] as Map<String, dynamic>;
  }
}

/// Represents a single chat message in the conversation
class ChatMessage {
  final String id;
  final String speaker;
  final String text;
  final int? delayAfter;
  final String? inputType;
  final Map<String, dynamic>? inputConfig;
  final bool isDynamic;

  ChatMessage({
    required this.id,
    required this.speaker,
    required this.text,
    this.delayAfter,
    this.inputType,
    this.inputConfig,
    this.isDynamic = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      delayAfter: json['delay_after'] as int?,
      inputType: json['input_type'] as String?,
      inputConfig: json['input_config'] as Map<String, dynamic>?,
      isDynamic: json['dynamic'] as bool? ?? false,
    );
  }
}

/// Configuration for typewriter text animation
class TypewriterConfig {
  final int typingSpeed;
  final Map<String, int> punctuationPauses;

  TypewriterConfig({
    required this.typingSpeed,
    required this.punctuationPauses,
  });

  factory TypewriterConfig.fromJson(Map<String, dynamic> json) {
    final pauseData = json['pause_on_punctuation'] as Map<String, dynamic>;
    final pauses = <String, int>{};
    
    for (final entry in pauseData.entries) {
      pauses[entry.key] = entry.value as int;
    }

    return TypewriterConfig(
      typingSpeed: json['typing_speed'] as int,
      punctuationPauses: pauses,
    );
  }
}
