import 'package:flutter/material.dart';
import '../models/smart_reminder.dart';
import '../services/smart_reminder_service.dart';
import '../services/notification_scheduling_service.dart';
import '../widgets/reminder_type_selector.dart';
import '../widgets/time_picker_field.dart';
import '../widgets/weekday_selector.dart';

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
              
              // Title field
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter reminder title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
                maxLength: 50,
              ),
              
              const SizedBox(height: 24),
              
              // Custom message field
              const Text(
                'Custom Message (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Leave empty to use smart, personalized messages',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Enter custom notification message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                maxLines: 3,
                maxLength: 150,
              ),
              
              const SizedBox(height: 24),
              
              // Time selection
              const Text(
                'Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TimePickerField(
                selectedTime: _selectedTime,
                onTimeChanged: (time) {
                  setState(() {
                    _selectedTime = time;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Weekday selection
              const Text(
                'Days of the Week',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              WeekdaySelector(
                selectedDays: _selectedWeekDays,
                onDaysChanged: (days) {
                  setState(() {
                    _selectedWeekDays = days;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Preview card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedType.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedType.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.preview,
                          color: _selectedType.color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedType.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedType.icon,
                            color: _selectedType.color,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _titleController.text.isEmpty
                                      ? _selectedType.defaultTitle
                                      : _titleController.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _messageController.text.isEmpty
                                      ? 'Smart message based on your current progress'
                                      : _messageController.text,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
