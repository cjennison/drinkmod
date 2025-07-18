import 'package:flutter/material.dart';
import '../models/smart_reminder.dart';
import '../services/smart_reminder_service.dart';
import '../services/notification_scheduling_service.dart';
import '../widgets/reminder_type_selector.dart';
import '../widgets/reminder_form_fields.dart';
import '../widgets/reminder_schedule_fields.dart';
import '../widgets/reminder_preview_card.dart';

/// Screen for creating a new smart reminder
class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _reminderService = SmartReminderService.instance;
  final _notificationService = NotificationSchedulingService.instance;

  SmartReminderType _selectedType = SmartReminderType.friendlyCheckin;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  List<int> _selectedWeekDays = [1, 2, 3, 4, 5]; // Monday to Friday
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _updateDefaultTitle();
  }

  Future<void> _initializeServices() async {
    try {
      await _reminderService.initialize();
      await _notificationService.initialize();
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _updateDefaultTitle() {
    if (_titleController.text.isEmpty || 
        _titleController.text == SmartReminderType.friendlyCheckin.defaultTitle ||
        _titleController.text == SmartReminderType.scheduleReminder.defaultTitle) {
      _titleController.text = _selectedType.defaultTitle;
    }
  }

  Future<void> _createReminder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWeekDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day of the week'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final reminder = SmartReminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        title: _titleController.text.trim(),
        message: _messageController.text.trim().isEmpty 
            ? null 
            : _messageController.text.trim(),
        timeOfDay: _selectedTime,
        weekDays: _selectedWeekDays,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Save to local storage
      final success = await _reminderService.saveReminder(reminder);
      
      if (success) {
        // Schedule notifications with error handling
        try {
          await _notificationService.scheduleReminder(reminder);
        } catch (e) {
          print('Warning: Could not schedule notification: $e');
          // Continue anyway - the reminder is saved, just notifications might not work
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Failed to save reminder');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating reminder: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Reminder'),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createReminder,
            child: _isCreating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reminder type selection
              const Text(
                'Reminder Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ReminderTypeSelector(
                selectedType: _selectedType,
                onTypeChanged: (type) {
                  setState(() {
                    _selectedType = type;
                    _updateDefaultTitle();
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Title and Message Fields
              ReminderFormFields(
                titleController: _titleController,
                messageController: _messageController,
              ),
              
              const SizedBox(height: 24),
              
              // Time and Days Selection
              ReminderScheduleFields(
                selectedTime: _selectedTime,
                selectedWeekDays: _selectedWeekDays,
                onTimeChanged: (time) {
                  setState(() {
                    _selectedTime = time;
                  });
                },
                onDaysChanged: (days) {
                  setState(() {
                    _selectedWeekDays = days;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Preview Card
              ReminderPreviewCard(
                selectedType: _selectedType,
                titleController: _titleController,
                messageController: _messageController,
              ),
              
              // Save button at bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Reminder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
