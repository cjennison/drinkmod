import 'package:flutter/material.dart';
import '../models/onboarding_state.dart';
import '../services/script_manager.dart';
import '../widgets/typewriter_text.dart';
import '../widgets/shared_components.dart';
import '../widgets/onboarding_step_widgets.dart';
import '../../../core/services/onboarding_service.dart';
import 'package:go_router/go_router.dart';

/// Controls the onboarding flow and business logic
class OnboardingController {
  final OnboardingState state = OnboardingState();
  final List<Widget> messages = [];
  
  late VoidCallback _onStateChanged;
  late VoidCallback _scrollToBottom;
  BuildContext? _context;

  // JSON-driven content variables
  Map<String, String> _userVariables = {};
  String _currentFlow = '';
  int _currentFlowStep = 0;

  void initialize({
    required VoidCallback onStateChanged,
    required VoidCallback scrollToBottom,
    BuildContext? context,
  }) {
    _onStateChanged = onStateChanged;
    _scrollToBottom = scrollToBottom;
    _context = context;
  }

  /// Initialize onboarding flow
  Future<void> initializeOnboarding() async {
    try {
      await ScriptManager.instance.loadOnboardingScript();
      _startWelcomeFlow();
    } catch (e) {
      state.isLoading = false;
      _onStateChanged();
      throw Exception('Failed to load onboarding: $e');
    }
  }

  /// Start the welcome conversation flow using JSON content
  void _startWelcomeFlow() {
    state.isLoading = false;
    _onStateChanged();
    
    _currentFlow = 'welcome';
    _currentFlowStep = 0;
    _processNextFlowStep();
  }

  /// Process the next step in the current flow
  void _processNextFlowStep() {
    try {
      final flowSteps = ScriptManager.instance.getConversationFlow(_currentFlow);
      
      if (_currentFlowStep >= flowSteps.length) {
        // Flow completed, move to next flow
        _moveToNextFlow();
        return;
      }
      
      final step = flowSteps[_currentFlowStep];
      _currentFlowStep++;
      
      if (step.inputType != null) {
        // This step requires input, show the message then the input
        _addAgentMessageFromScript(step, onComplete: () {
          _showInputForStep(step);
        });
      } else {
        // Regular message, show it and continue to next after delay
        _addAgentMessageFromScript(step, onComplete: () {
          if (step.delayAfter != null && step.delayAfter! > 0) {
            Future.delayed(Duration(milliseconds: step.delayAfter!), () {
              _processNextFlowStep();
            });
          } else {
            _processNextFlowStep();
          }
        });
      }
    } catch (e) {
      print('Error processing flow step: $e');
      // Fallback to next flow or handle error
      _moveToNextFlow();
    }
  }

  /// Add agent message from script with variable substitution
  void _addAgentMessageFromScript(ChatMessage scriptMessage, {VoidCallback? onComplete}) {
    String message = scriptMessage.text;
    
    // Replace variables if this is a dynamic message
    if (scriptMessage.isDynamic) {
      _userVariables.forEach((key, value) {
        message = message.replaceAll('{$key}', value);
      });
    }
    
    _addAgentMessage(message, onComplete: onComplete);
  }

  /// Move to the next flow in sequence
  void _moveToNextFlow() {
    switch (_currentFlow) {
      case 'welcome':
        _currentFlow = 'motivation';
        break;
      case 'motivation':
        _currentFlow = 'drinking_patterns';
        break;
      case 'drinking_patterns':
        _currentFlow = 'drinking_amount';
        break;
      case 'drinking_amount':
        _currentFlow = 'favorite_drinks';
        break;
      case 'favorite_drinks':
        _currentFlow = 'summary';
        break;
      case 'summary':
        _completeOnboarding();
        return;
      default:
        _completeOnboarding();
        return;
    }
    
    _currentFlowStep = 0;
    _processNextFlowStep();
  }

  /// Show input widget for a step
  void _showInputForStep(ChatMessage step) {
    switch (step.inputType) {
      case 'name_input':
        showNameInput();
        break;
      case 'motivation_input':
        showMotivationInput();
        break;
      case 'frequency_input':
        showFrequencyInput();
        break;
      case 'amount_input':
        showAmountInput();
        break;
      case 'drinks_input':
        showDrinksInput();
        break;
      default:
        print('Unknown input type: ${step.inputType}');
        _processNextFlowStep();
    }
  }

  /// Add agent message with typewriter effect
  void _addAgentMessage(String message, {VoidCallback? onComplete}) {
    final messageId = 'message_${state.messageIdCounter++}';
    state.messageCompletionStates[messageId] = false;
    
    messages.add(
      ChatBubble(
        key: ValueKey(messageId),
        message: message,
        isAgent: true,
        showTypewriter: true,
        isTypewriterCompleted: state.messageCompletionStates[messageId] ?? false,
        onTypewriterComplete: () {
          state.messageCompletionStates[messageId] = true;
          _onStateChanged();
          onComplete?.call();
          _scrollToBottom();
        },
      ),
    );
    
    _onStateChanged();
    _scrollToBottom();
  }

  // Step 1: Name Input
  void showNameInput() {
    if (!state.nameSubmitted) {
      messages.add(OnboardingStepWidgets.buildNameInputCard(
        onSubmit: handleNameSubmission,
      ));
      _onStateChanged();
      _scrollToBottom();
    }
  }

  void handleNameSubmission(String name, String gender) {
    state.userName = name;
    state.userGender = gender;
    state.nameSubmitted = true;
    state.currentStep = 2;
    
    // Store variables for dynamic content
    _userVariables['name'] = name;
    if (gender.isNotEmpty) {
      _userVariables['gender'] = gender;
    }
    
    // Replace input card with compact response
    messages.removeLast();
    messages.add(CompactResponse(
      title: "Name",
      response: gender.isNotEmpty ? "$name ($gender)" : name,
      icon: Icons.person,
    ));
    
    _onStateChanged();

    // Continue with JSON flow
    _processNextFlowStep();
  }

  // Step 2: Motivation Input
  void showMotivationInput() {
    if (!state.motivationSubmitted) {
      messages.add(OnboardingStepWidgets.buildMotivationInputCard(
        onSubmit: handleMotivationSubmission,
      ));
      _onStateChanged();
      _scrollToBottom();
    }
  }

  void handleMotivationSubmission(String motivation) {
    state.userMotivation = motivation;
    state.motivationSubmitted = true;
    state.currentStep = 3;
    
    // Store motivation for future reference
    _userVariables['motivation'] = motivation;
    
    // Replace input card with compact response
    messages.removeLast();
    messages.add(CompactResponse(
      title: "My motivation",
      response: motivation,
      icon: Icons.favorite,
    ));
    
    _onStateChanged();

    // Continue with JSON flow
    _processNextFlowStep();
  }

  // Step 3: Drinking Patterns Input
  void showDrinkingPatternsInput() {
    if (!state.drinkingPatternsSubmitted) {
      messages.add(OnboardingStepWidgets.buildDrinkingPatternsInputCard(
        onSubmit: handleDrinkingPatternsSubmission,
      ));
      _onStateChanged();
      _scrollToBottom();
    }
  }

  void handleDrinkingPatternsSubmission(String frequency, String amount) {
    state.drinkingFrequency = frequency;
    state.drinkingAmount = amount;
    state.drinkingPatternsSubmitted = true;
    state.currentStep = 4;
    
    // Replace input card with compact response
    messages.removeLast();
    String response = frequency;
    if (frequency != 'I don\'t currently drink' && amount.isNotEmpty) {
      response += ", $amount";
    }
    
    messages.add(CompactResponse(
      title: "Drinking patterns",
      response: response,
      icon: Icons.analytics,
    ));
    
    _onStateChanged();

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
        Future.delayed(const Duration(milliseconds: 2000), () {
          _addAgentMessage("Now let's talk about the fun part - what do you love to drink?", onComplete: () {
            Future.delayed(const Duration(milliseconds: 1500), () {
              _addAgentMessage("I want you to still enjoy your drinks, we're just working on control.", onComplete: () {
                Future.delayed(const Duration(milliseconds: 1500), () {
                  _addAgentMessage("What's your go-to drink when you want to treat yourself?", onComplete: () {
                    showFavoriteDrinksInput();
                  });
                });
              });
            });
          });
        });
      });
    });
  }

  // Step 4: Favorite Drinks Input
  void showFavoriteDrinksInput() {
    if (!state.favoriteDrinksSubmitted) {
      messages.add(OnboardingStepWidgets.buildFavoriteDrinksInputCard(
        onSubmit: handleFavoriteDrinksSubmission,
      ));
      _onStateChanged();
      _scrollToBottom();
    }
  }

  void handleFavoriteDrinksSubmission(List<String> drinks) {
    state.favoriteDrinks = drinks;
    state.favoriteDrinksSubmitted = true;
    state.currentStep = 5;
    
    // Replace input card with compact response
    messages.removeLast();
    messages.add(CompactResponse(
      title: "Favorite drinks",
      response: drinks.length <= 3 ? drinks.join(", ") : "${drinks.take(2).join(", ")} +${drinks.length - 2} more",
      icon: Icons.local_bar,
    ));
    
    _onStateChanged();

    // Continue with schedule recommendation
    state.generateScheduleRecommendation();
    
    _addAgentMessage("Perfect! I love that you know what you enjoy.", onComplete: () {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _addAgentMessage("Based on what you've told me, I have some recommendations for your drinking schedule.", onComplete: () {
          Future.delayed(const Duration(milliseconds: 1500), () {
            _addAgentMessage("Currently you drink ${state.drinkingFrequency}. Let's aim for ${state.recommendedSchedule}.", onComplete: () {
              showScheduleInput();
            });
          });
        });
      });
    });
  }

  // Step 5: Schedule Input
  void showScheduleInput() {
    if (!state.scheduleSubmitted) {
      messages.add(OnboardingStepWidgets.buildScheduleInputCard(
        onSubmit: handleScheduleSubmission,
      ));
      _onStateChanged();
      _scrollToBottom();
    }
  }

  void handleScheduleSubmission(String schedule) {
    state.selectedSchedule = schedule.replaceAll(' [RECOMMENDED]', '');
    state.scheduleSubmitted = true;
    state.currentStep = 6;
    
    // Replace input card with compact response
    messages.removeLast();
    messages.add(CompactResponse(
      title: "Schedule",
      response: state.selectedSchedule,
      icon: Icons.calendar_today,
    ));
    
    _onStateChanged();

    // Continue with drink limit setting
    _addAgentMessage("Excellent choice! That schedule will help you stay in control while still enjoying your drinks.", onComplete: () {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _addAgentMessage("Now, how many drinks would you like to limit yourself to on drinking days?", onComplete: () {
          Future.delayed(const Duration(milliseconds: 1000), () {
            _addAgentMessage("I recommend 2 drinks based on your goals and health guidelines.", onComplete: () {
              showDrinkLimitInput();
            });
          });
        });
      });
    });
  }

  // Step 6: Drink Limit Input
  void showDrinkLimitInput() {
    if (!state.drinkLimitSubmitted) {
      messages.add(OnboardingStepWidgets.buildDrinkLimitInputCard(
        onSubmit: handleDrinkLimitSubmission,
      ));
      _onStateChanged();
      _scrollToBottom();
    }
  }

  void handleDrinkLimitSubmission(int limit) {
    state.drinkLimit = limit;
    state.drinkLimitSubmitted = true;
    state.currentStep = 7;
    
    // Replace input card with compact response
    messages.removeLast();
    messages.add(CompactResponse(
      title: "Daily limit",
      response: "$limit drink${limit == 1 ? '' : 's'} per drinking day",
      icon: Icons.local_drink,
    ));
    
    _onStateChanged();

    // Complete onboarding
    completeOnboarding();
  }

  // Step 7: Complete Onboarding
  void completeOnboarding() {
    _addAgentMessage("Perfect! We've created your personalized plan.", onComplete: () {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _addAgentMessage("Here's what we've set up:", onComplete: () {
          Future.delayed(const Duration(milliseconds: 1000), () {
            _addAgentMessage("• Schedule: ${state.selectedSchedule}", onComplete: () {
              Future.delayed(const Duration(milliseconds: 1000), () {
                _addAgentMessage("• Daily limit: ${state.drinkLimit} drink${state.drinkLimit == 1 ? '' : 's'}", onComplete: () {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    _addAgentMessage("• Motivation: ${state.userMotivation}", onComplete: () {
                      Future.delayed(const Duration(milliseconds: 2000), () {
                        _addAgentMessage("You're all set! I'm excited to be part of your journey towards a healthier relationship with alcohol.", onComplete: () {
                          Future.delayed(const Duration(milliseconds: 1500), () {
                            _addAgentMessage("Ready to get started?", onComplete: () {
                              showReadyButton();
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  }

  void showReadyButton() {
    messages.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: ActionButton(
            text: "I'm Ready!",
            onPressed: () => finishOnboarding(),
            isPrimary: true,
          ),
        ),
      ),
    );
    _onStateChanged();
    _scrollToBottom();
  }

  Future<void> finishOnboarding() async {
    // Save onboarding data
    await _saveOnboardingData();
    
    // Navigate to home page
    _navigateToHome();
  }

  Future<void> _saveOnboardingData() async {
    final summary = state.getSummary();
    await OnboardingService.completeOnboarding(summary);
  }

  void _navigateToHome() {
    if (_context != null) {
      _context!.go('/home');
    }
  }

  /// Rebuild chat bubble with current completion state
  Widget? rebuildChatBubble(Widget widget) {
    if (widget is ChatBubble && widget.showTypewriter) {
      final messageId = (widget.key as ValueKey?)?.value as String?;
      if (messageId != null) {
        return ChatBubble(
          key: ValueKey(messageId),
          message: widget.message,
          isAgent: widget.isAgent,
          showTypewriter: widget.showTypewriter,
          isTypewriterCompleted: state.messageCompletionStates[messageId] ?? false,
          onTypewriterComplete: widget.onTypewriterComplete,
        );
      }
    }
    return null;
  }

  /// Alias methods to map JSON input types to existing methods
  void showFrequencyInput() => showDrinkingPatternsInput();
  void showAmountInput() => showDrinkingPatternsInput(); // Combined in existing flow
  void showDrinksInput() => showFavoriteDrinksInput();

  /// Complete onboarding flow
  void _completeOnboarding() {
    showReadyButton();
  }
}
