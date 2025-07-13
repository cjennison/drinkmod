import 'package:flutter/material.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/shared_components.dart';

/// Main onboarding screen with agentic conversational experience
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final ScrollController _scrollController = ScrollController();
  final OnboardingController _controller = OnboardingController();

  @override
  void initState() {
    super.initState();
    _controller.initialize(
      onStateChanged: () => setState(() {}),
      scrollToBottom: _scrollToBottom,
      context: context,
    );
    _initializeOnboarding();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeOnboarding() async {
    try {
      await _controller.initializeOnboarding();
    } catch (e) {
      _showErrorMessage(e.toString());
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to DrinkMod'),
        elevation: 0,
      ),
      body: Column(
        children: [
          OnboardingProgress(
            currentStep: _controller.state.currentStep,
            totalSteps: _controller.state.totalSteps,
          ),
          Expanded(
            child: _controller.state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, screenHeight * 0.33),
                    itemCount: _controller.messages.length,
                    itemBuilder: (context, index) {
                      final widget = _controller.messages[index];
                      // Rebuild ChatBubble with current completion state if needed
                      final rebuiltWidget = _controller.rebuildChatBubble(widget);
                      return rebuiltWidget ?? widget;
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
