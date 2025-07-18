import 'package:flutter/material.dart';
import '../models/smart_reminder.dart';
import '../services/smart_reminder_service.dart';
import '../services/notification_scheduling_service.dart';
import '../widgets/reminder_type_selector.dart';
import '../widgets/time_picker_field.dart';
import '../widgets/weekday_selector.dart';

/// Screen for editing an existing smart reminder
class EditReminderScreen extends StatefulWidget {
  final SmartReminder reminder;
  
  const EditReminderScreen({
    super.key, 
    required this.reminder,
  });

  @override
  State<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _reminderService = SmartReminderService.instance;
  final _notificationService = NotificationSchedulingService.instance;

  late SmartReminderType _selectedType;
  late TimeOfDay _selectedTime;
  late List<int> _selectedWeekDays;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadReminderData();
  }

  Future<void> _initializeServices() async {
    try {
      await _reminderService.initialize();
      await _notificationService.initialize();
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  void _loadReminderData() {
    // Load existing reminder data into form fields
    _titleController.text = widget.reminder.title;
    _messageController.text = widget.reminder.message ?? '';
    _selectedType = widget.reminder.type;
    _selectedTime = widget.reminder.timeOfDay;
    _selectedWeekDays = List.from(widget.reminder.weekDays);
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

  Future<void> _updateReminder() async {
    if (!_formKey.currentState!.validate() || _selectedWeekDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields and select at least one day'),
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      // Create updated reminder with same ID
      final updatedReminder = widget.reminder.copyWith(
        type: _selectedType,
        title: _titleController.text.trim(),
        message: _messageController.text.trim().isEmpty 
            ? null 
            : _messageController.text.trim(),
        timeOfDay: _selectedTime,
        weekDays: _selectedWeekDays,
      );

      // Update in database
      await _reminderService.updateSmartReminder(updatedReminder);
      
      // Reschedule notifications with error handling
      try {
        await _notificationService.cancelReminder(widget.reminder.id);
        await _notificationService.scheduleReminder(updatedReminder);
      } catch (e) {
        print('Warning: Could not reschedule notification: $e');
        // Continue anyway - the reminder is updated, just notifications might not work
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      print('Error updating reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Reminder'),
        actions: [
          TextButton(
            onPressed: _isUpdating ? null : _updateReminder,
            child: _isUpdating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reminder Type Selector
              const Text(
                'Reminder Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              
              const SizedBox(height: 24),
              
              // Title Field
              const Text(
                'Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter reminder title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Custom Message Field
              const Text(
                'Custom Message (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Leave empty to use smart, personalized messages',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Enter custom notification message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 150,
              ),
              
              const SizedBox(height: 16),
              
              // Time Selector
              const Text(
                'Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TimePickerField(
                selectedTime: _selectedTime,
                onTimeChanged: (time) {
                  setState(() {
                    _selectedTime = time;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Days Selector
              const Text(
                'Days of the Week',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              WeekdaySelector(
                selectedDays: _selectedWeekDays,
                onDaysChanged: (days) {
                  setState(() {
                    _selectedWeekDays = days;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Preview Card
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
              
              // Update button at bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updateReminder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Update Reminder',
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
