import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/drink_entry.dart';
import '../../../core/services/hive_database_service.dart';

// States
abstract class DrinkLoggingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DrinkLoggingInitial extends DrinkLoggingState {}

class DrinkLoggingLoading extends DrinkLoggingState {}

class DrinkLoggingSuccess extends DrinkLoggingState {
  final DrinkEntry entry;

  DrinkLoggingSuccess(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DrinkLoggingError extends DrinkLoggingState {
  final String message;

  DrinkLoggingError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class DrinkLoggingCubit extends Cubit<DrinkLoggingState> {
  final HiveDatabaseService _databaseService;

  DrinkLoggingCubit(this._databaseService) : super(DrinkLoggingInitial());

  /// Log a new drink entry
  Future<void> logDrinkEntry(DrinkEntry entry) async {
    try {
      emit(DrinkLoggingLoading());
      
      // Calculate if within limits and schedule compliant
      final userData = _databaseService.getUserData();
      final isScheduleCompliant = userData != null 
          ? _databaseService.isDrinkingDay(date: entry.timestamp)
          : true;
      
      final dailyLimit = userData?['drinkLimit'] ?? 2;
      final todaysDrinks = _databaseService.getTotalDrinksForDate(entry.timestamp);
      final isWithinLimit = (todaysDrinks + entry.standardDrinks) <= dailyLimit;
      
      // Update entry with calculated values
      final updatedEntry = entry.copyWith(
        isWithinLimit: isWithinLimit,
        isScheduleCompliant: isScheduleCompliant,
      );
      
      // Save to database using the enhanced entry
      await _databaseService.createDrinkEntry(
        drinkDate: updatedEntry.timestamp,
        drinkName: updatedEntry.drinkName,
        standardDrinks: updatedEntry.standardDrinks,
        drinkType: 'logged',
        timeOfDay: updatedEntry.timeOfDay,
        reason: updatedEntry.triggerDescription,
        notes: updatedEntry.intention,
      );
      
      // For now, we'll save the enhanced data as metadata
      // In a future update, we'll extend the database schema
      if (await _shouldSaveEnhancedData(updatedEntry)) {
        await _saveEnhancedMetadata(updatedEntry);
      }
      
      print('DrinkLoggingCubit - About to emit DrinkLoggingSuccess');
      emit(DrinkLoggingSuccess(updatedEntry));
      print('DrinkLoggingCubit - DrinkLoggingSuccess emitted');
    } catch (e) {
      print('DrinkLoggingCubit - Error occurred: $e');
      emit(DrinkLoggingError('Failed to log drink: $e'));
    }
  }

  /// Update an existing drink entry
  Future<void> updateDrinkEntry(DrinkEntry entry) async {
    try {
      emit(DrinkLoggingLoading());
      
      // For now, delete the old entry and create a new one
      // In a future update, we'll implement proper update functionality
      await _databaseService.deleteDrinkEntry(entry.id);
      
      await logDrinkEntry(entry);
    } catch (e) {
      emit(DrinkLoggingError('Failed to update drink: $e'));
    }
  }

  /// Check if we should save enhanced therapeutic data
  Future<bool> _shouldSaveEnhancedData(DrinkEntry entry) async {
    // Save if any therapeutic fields are filled
    return entry.moodBefore != null ||
           entry.triggers?.isNotEmpty == true ||
           entry.triggerDescription?.isNotEmpty == true ||
           entry.intention?.isNotEmpty == true ||
           entry.urgeIntensity != null ||
           entry.location?.isNotEmpty == true ||
           entry.socialContext?.isNotEmpty == true;
  }

  /// Save enhanced metadata for therapeutic analysis
  Future<void> _saveEnhancedMetadata(DrinkEntry entry) async {
    try {
      // Save to a separate box for enhanced drink data
      final enhancedData = {
        'entryId': entry.id,
        'timestamp': entry.timestamp.toIso8601String(),
        'timeOfDay': entry.timeOfDay,
        'location': entry.location,
        'socialContext': entry.socialContext,
        'moodBefore': entry.moodBefore,
        'triggers': entry.triggers,
        'triggerDescription': entry.triggerDescription,
        'intention': entry.intention,
        'urgeIntensity': entry.urgeIntensity,
        'consideredAlternatives': entry.consideredAlternatives,
        'alternatives': entry.alternatives,
        'energyLevel': entry.energyLevel,
        'hungerLevel': entry.hungerLevel,
        'stressLevel': entry.stressLevel,
        'sleepQuality': entry.sleepQuality,
      };
      
      // For now, store as app setting with unique key
      await _databaseService.setSetting(
        'enhanced_drink_${entry.id}', 
        enhancedData,
      );
    } catch (e) {
      // Don't fail the whole operation if metadata save fails
      print('Warning: Failed to save enhanced drink metadata: $e');
    }
  }

  /// Get enhanced data for a drink entry
  Future<Map<String, dynamic>?> getEnhancedData(String entryId) async {
    try {
      return _databaseService.getSetting<Map<String, dynamic>>(
        'enhanced_drink_$entryId',
      );
    } catch (e) {
      print('Warning: Failed to load enhanced drink metadata: $e');
      return null;
    }
  }

  /// Delete enhanced data for a drink entry
  Future<void> deleteEnhancedData(String entryId) async {
    try {
      await _databaseService.removeSetting('enhanced_drink_$entryId');
    } catch (e) {
      print('Warning: Failed to delete enhanced drink metadata: $e');
    }
  }
}
