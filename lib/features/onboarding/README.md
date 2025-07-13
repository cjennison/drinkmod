# Onboarding Module Structure

This document outlines the modular structure of the onboarding feature in DrinkMod.

## File Organization

### 📁 `/lib/features/onboarding/`

#### 🎭 `/models/`
- **`onboarding_state.dart`** - Data model containing user responses and state management
  - Stores all user inputs (name, motivation, drinking patterns, etc.)
  - Tracks step progression and submission states
  - Provides utility methods for recommendations and data summary

#### 🎮 `/controllers/`
- **`onboarding_controller.dart`** - Business logic and conversation flow control
  - Manages the 7-step onboarding flow
  - Handles message sequencing and timing
  - Controls input card display and submission handling
  - Maintains typewriter completion states

#### 🖼️ `/screens/`
- **`onboarding_screen.dart`** - Main UI screen (simplified)
  - Lightweight StatefulWidget focused on UI rendering
  - Delegates all business logic to OnboardingController
  - Handles scrolling and error display

#### 🧩 `/widgets/`
- **`onboarding_step_widgets.dart`** - All input card builders for each step
  - Static factory methods for each input card type
  - Self-contained UI components with callbacks
  - Consistent styling and behavior patterns

- **`shared_components.dart`** - Reusable UI components
  - InputCard, ActionButton, OnboardingProgress, CompactResponse
  - Consistent styling across the onboarding flow

- **`typewriter_text.dart`** - Typewriter animation and chat bubbles
  - Character-by-character animation with persistence
  - GPT-style message display without avatars

#### ⚙️ `/services/`
- **`script_manager.dart`** - JSON conversation script management
  - Loads and manages conversation flow configurations

## Benefits of This Structure

### 🎯 **Separation of Concerns**
- **State Management**: Isolated in `OnboardingState`
- **Business Logic**: Centralized in `OnboardingController`
- **UI Components**: Modular in `OnboardingStepWidgets`
- **Main Screen**: Clean and focused

### 📏 **Code Organization**
- Each file is under 400 lines (following project guidelines)
- Related functionality grouped together
- Clear import dependencies

### 🔧 **Maintainability**
- Easy to modify individual steps without affecting others
- Clear data flow between components
- Testable business logic separated from UI

### 🔄 **Reusability**
- Step widgets can be reused or rearranged
- State model can be used for data persistence
- Controller patterns can be applied to other flows

## Data Flow

```
OnboardingScreen 
    ↓ (delegates to)
OnboardingController 
    ↓ (manages)
OnboardingState + OnboardingStepWidgets
    ↓ (callbacks to)
OnboardingController
    ↓ (updates)
OnboardingScreen (via setState)
```

## Key Components

### OnboardingState
- Central data store for all user responses
- Step tracking and submission states
- Smart recommendation algorithms

### OnboardingController
- 7-step conversation flow management
- Message timing and sequencing
- Input handling and validation

### OnboardingStepWidgets
- Factory methods for each input card:
  - `buildNameInputCard()` - Name and gender collection
  - `buildMotivationInputCard()` - Motivation selection
  - `buildDrinkingPatternsInputCard()` - Current habits assessment
  - `buildFavoriteDrinksInputCard()` - Preferences collection
  - `buildScheduleInputCard()` - Schedule recommendations
  - `buildDrinkLimitInputCard()` - Daily limit setting

This structure ensures the onboarding remains maintainable and scalable while preserving all existing functionality.
