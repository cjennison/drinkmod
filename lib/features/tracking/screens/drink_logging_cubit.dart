import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/models/drink_entry.dart';
import '../../../core/models/app_event.dart';
import '../../../core/services/hive_database_service.dart';
import '../../../core/services/app_events_service.dart';

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
  final AppEventsService _eventsService = AppEventsService.instance;

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
      
      // Save to database with all enhanced therapeutic data
      final databaseEntryId = await _databaseService.createDrinkEntry(
        drinkDate: updatedEntry.timestamp,
        drinkName: updatedEntry.drinkName,
        standardDrinks: updatedEntry.standardDrinks,
        drinkType: 'logged',
        timeOfDay: updatedEntry.timeOfDay,
        reason: updatedEntry.triggerDescription,
        notes: updatedEntry.intention,
        // Enhanced therapeutic fields
        location: updatedEntry.location,
        socialContext: updatedEntry.socialContext,
        moodBefore: updatedEntry.moodBefore,
        triggers: updatedEntry.triggers,
        triggerDescription: updatedEntry.triggerDescription,
        intention: updatedEntry.intention,
        urgeIntensity: updatedEntry.urgeIntensity,
        consideredAlternatives: updatedEntry.consideredAlternatives,
        alternatives: updatedEntry.alternatives,
        energyLevel: updatedEntry.energyLevel,
        hungerLevel: updatedEntry.hungerLevel,
        stressLevel: updatedEntry.stressLevel,
        sleepQuality: updatedEntry.sleepQuality,
        interventionData: updatedEntry.interventionData?.toHive(),
      );
      
      // Update the entry with the database-generated ID
      final finalEntry = updatedEntry.copyWith(id: databaseEntryId);
      
      // Record app event for achievement tracking
      await _eventsService.recordEvent(AppEvent.drinkLogged(
        timestamp: finalEntry.timestamp,
        drinkId: databaseEntryId,
        drinkName: finalEntry.drinkName,
        standardDrinks: finalEntry.standardDrinks,
        isScheduleCompliant: isScheduleCompliant,
        isWithinLimit: isWithinLimit,
        wasIntervention: finalEntry.interventionData != null,
        interventionType: finalEntry.interventionData?.interventionType.toString(),
        additionalData: {
          'timeOfDay': finalEntry.timeOfDay,
          'location': finalEntry.location,
          'socialContext': finalEntry.socialContext,
          'moodBefore': finalEntry.moodBefore,
        },
      ));
      
      emit(DrinkLoggingSuccess(finalEntry));
    } catch (e) {
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

}
