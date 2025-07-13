import 'package:flutter/material.dart';
import '../services/script_manager.dart';
import '../widgets/typewriter_text.dart';
import '../widgets/shared_components.dart';

/// Main onboarding screen with agentic conversational experience
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<Widget> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  int _currentStep = 1;
  final int _totalSteps = 7;
  
  // Store user responses
  String _userName = '';
  String _userGender = '';
  String _userMotivation = '';
  String _drinkingFrequency = '';
  String _drinkingAmount = '';
  
  // Track which inputs have been submitted
  bool _nameSubmitted = false;
  bool _motivationSubmitted = false;
  bool _drinkingPatternsSubmitted = false;
  
  // Track typewriter completion states by message ID
  final Map<String, bool> _messageCompletionStates = {};
  int _messageIdCounter = 0;

  @override
  void initState() {
    super.initState();
    _initializeOnboarding();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeOnboarding() async {
    try {
      await ScriptManager.instance.loadOnboardingScript();
      _startWelcomeFlow();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to load onboarding: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startWelcomeFlow() {
    setState(() {
      _isLoading = false;
    });

    // Start with the introduction
    _addAgentMessage("Hello! I'm Mara, your personal guide here at DrinkMod.", onComplete: () {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _addAgentMessage("I'm here to help you build a healthier relationship with alcohol.", onComplete: () {
          Future.delayed(const Duration(milliseconds: 1500), () {
            _addAgentMessage("This is a safe, private space where we'll work together to create a plan that works for you.", onComplete: () {
              Future.delayed(const Duration(milliseconds: 2000), () {
                _addAgentMessage("Let's start by getting to know each other a bit. What's your name, or what would you like me to call you?", onComplete: () {
                  _showNameInput();
                });
              });
            });
          });
        });
      });
    });
  }

  void _addAgentMessage(String message, {VoidCallback? onComplete}) {
    final messageId = 'message_${_messageIdCounter++}';
    setState(() {
      _messageCompletionStates[messageId] = false; // Start as not completed
      _messages.add(
        ChatBubble(
          key: ValueKey(messageId), // Use ValueKey for consistent widget identity
          message: message,
          isAgent: true,
          showTypewriter: true,
          isTypewriterCompleted: _messageCompletionStates[messageId] ?? false,
          onTypewriterComplete: () {
            // Mark this message as completed
            setState(() {
              _messageCompletionStates[messageId] = true;
            });
            onComplete?.call();
            _scrollToBottom();
          },
        ),
      );
    });
    _scrollToBottom();
  }

  void _showNameInput() {
    if (!_nameSubmitted) {
      setState(() {
        _messages.add(_buildNameInputCard());
      });
      _scrollToBottom();
    }
  }

  void _showMotivationInput() {
    if (!_motivationSubmitted) {
      setState(() {
        _messages.add(_buildMotivationInputCard());
      });
      _scrollToBottom();
    }
  }

  void _showDrinkingPatternsInput() {
    if (!_drinkingPatternsSubmitted) {
      setState(() {
        _messages.add(_buildDrinkingPatternsInputCard());
      });
      _scrollToBottom();
    }
  }

  Widget _buildNameInputCard() {
    final nameController = TextEditingController();
    String selectedGender = '';

    return InputCard(
      title: "Tell me about yourself",
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Your name or preferred name",
                hintText: "What should I call you?",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text(
              "How do you identify? (Optional)",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['She/her', 'He/him', 'They/them', 'Prefer not to say']
                  .map((gender) => FilterChip(
                        label: Text(gender),
                        selected: selectedGender == gender,
                        onSelected: (selected) {
                          setState(() {
                            selectedGender = selected ? gender : '';
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            ActionButton(
              text: "Continue",
              onPressed: nameController.text.trim().isNotEmpty
                  ? () => _handleNameSubmission(nameController.text.trim(), selectedGender)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNameSubmission(String name, String gender) {
    setState(() {
      _userName = name;
      _userGender = gender;
      _nameSubmitted = true;
      _currentStep = 2;
      
      // Replace input card with compact response
      _messages.removeLast();
      _messages.add(CompactResponse(
        title: "Name",
        response: gender.isNotEmpty ? "$name ($gender)" : name,
        icon: Icons.person,
      ));
    });

    // Continue with next step
    _addAgentMessage("Nice to meet you, $name! Thank you for sharing that with me.", onComplete: () {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _addAgentMessage("Now, I'd love to understand what's driving your journey with DrinkMod. What's your main motivation for wanting to make changes?", onComplete: () {
          _showMotivationInput();
        });
      });
    });
  }

  Widget _buildMotivationInputCard() {
    String selectedMotivation = '';
    final customController = TextEditingController();

    final motivationOptions = [
      'Health concerns',
      'Financial reasons',
      'Relationship impact',
      'Work/productivity',
      'Personal control',
      'Family concerns',
      'Sleep quality',
      'Mental clarity',
      'Other'
    ];

    return InputCard(
      title: "What's driving your journey?",
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select what resonates most with you:"),
            const SizedBox(height: 12),
            ...motivationOptions.map((motivation) => RadioListTile<String>(
                  title: Text(motivation),
                  value: motivation,
                  groupValue: selectedMotivation,
                  onChanged: (value) {
                    setState(() {
                      selectedMotivation = value!;
                      if (value != 'Other') {
                        customController.clear();
                      }
                    });
                  },
                )),
            if (selectedMotivation == 'Other') ...[
              const SizedBox(height: 8),
              TextField(
                controller: customController,
                decoration: const InputDecoration(
                  labelText: "Please describe",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ],
            const SizedBox(height: 20),
            ActionButton(
              text: "Continue",
              onPressed: selectedMotivation.isNotEmpty &&
                      (selectedMotivation != 'Other' || customController.text.trim().isNotEmpty)
                  ? () => _handleMotivationSubmission(
                        selectedMotivation == 'Other' 
                            ? customController.text.trim() 
                            : selectedMotivation
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMotivationSubmission(String motivation) {
    setState(() {
      _userMotivation = motivation;
      _motivationSubmitted = true;
      _currentStep = 3;
      
      // Replace input card with compact response
      _messages.removeLast();
      _messages.add(CompactResponse(
        title: "My motivation",
        response: motivation,
        icon: Icons.favorite,
      ));
    });

    // Continue with next step
    _addAgentMessage("Thank you for sharing that with me. That's a meaningful reason, and it shows real self-awareness.", onComplete: () {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _addAgentMessage("Now let's talk about where you're at right now. Can you tell me about your current drinking patterns?", onComplete: () {
          _showDrinkingPatternsInput();
        });
      });
    });
  }

  Widget _buildDrinkingPatternsInputCard() {
    String selectedFrequency = '';
    String selectedAmount = '';

    final frequencyOptions = [
      'Daily',
      'Several times a week',
      'Once or twice a week',
      'A few times a month',
      'Once a month or less',
      'I don\'t currently drink'
    ];

    final amountOptions = [
      '1-2 drinks',
      '3-4 drinks',
      '5-6 drinks',
      'More than 6 drinks',
      'It varies a lot'
    ];

    return InputCard(
      title: "Your current drinking patterns",
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How often do you typically drink?", 
                       style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...frequencyOptions.map((frequency) => RadioListTile<String>(
                  title: Text(frequency),
                  value: frequency,
                  groupValue: selectedFrequency,
                  onChanged: (value) {
                    setState(() {
                      selectedFrequency = value!;
                    });
                  },
                )),
            if (selectedFrequency.isNotEmpty && selectedFrequency != 'I don\'t currently drink') ...[
              const SizedBox(height: 16),
              const Text("When you do drink, how much do you typically have?", 
                         style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ...amountOptions.map((amount) => RadioListTile<String>(
                    title: Text(amount),
                    value: amount,
                    groupValue: selectedAmount,
                    onChanged: (value) {
                      setState(() {
                        selectedAmount = value!;
                      });
                    },
                  )),
            ],
            const SizedBox(height: 20),
            ActionButton(
              text: "Continue",
              onPressed: selectedFrequency.isNotEmpty &&
                      (selectedFrequency == 'I don\'t currently drink' || selectedAmount.isNotEmpty)
                  ? () => _handleDrinkingPatternsSubmission(selectedFrequency, selectedAmount)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleDrinkingPatternsSubmission(String frequency, String amount) {
    setState(() {
      _drinkingFrequency = frequency;
      _drinkingAmount = amount;
      _drinkingPatternsSubmitted = true;
      _currentStep = 4;
      
      // Replace input card with compact response
      _messages.removeLast();
      String response = frequency;
      if (frequency != 'I don\'t currently drink' && amount.isNotEmpty) {
        response += ", $amount";
      }
      
      _messages.add(CompactResponse(
        title: "Drinking patterns",
        response: response,
        icon: Icons.analytics,
      ));
    });

    // Continue with acknowledgment
    if (frequency == 'I don\'t currently drink') {
      _addAgentMessage("I appreciate you sharing that. It's great that you're being proactive about maintaining healthy habits.", onComplete: () {
        _continueToNextStep();
      });
    } else {
      _addAgentMessage("Thank you for being honest about your current patterns. Understanding where you are now helps us create the right plan for you.", onComplete: () {
        _continueToNextStep();
      });
    }
  }

  void _continueToNextStep() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      _addAgentMessage("Great! We're making good progress. Based on what you've shared, I'll help you create a personalized plan that fits your goals and lifestyle.", onComplete: () {
        // This is where we would continue to step 4, 5, 6, 7
        // For now, let's acknowledge completion of this section
        Future.delayed(const Duration(milliseconds: 2000), () {
          _addAgentMessage("We'll continue building your plan in the next steps. You're doing great!");
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to DrinkMod'),
        elevation: 0,
      ),
      body: Column(
        children: [
          OnboardingProgress(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final widget = _messages[index];
                      // If it's a ChatBubble, rebuild it with current completion state
                      if (widget is ChatBubble && widget.showTypewriter) {
                        final messageId = (widget.key as ValueKey?)?.value as String?;
                        if (messageId != null) {
                          return ChatBubble(
                            key: widget.key,
                            message: widget.message,
                            isAgent: widget.isAgent,
                            showTypewriter: widget.showTypewriter,
                            isTypewriterCompleted: _messageCompletionStates[messageId] ?? false,
                            onTypewriterComplete: widget.onTypewriterComplete,
                          );
                        }
                      }
                      return widget;
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
