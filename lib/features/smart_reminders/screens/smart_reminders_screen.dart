import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart' as theme;
import '../models/smart_reminder.dart';
import '../services/smart_reminder_service.dart';
import '../services/notification_scheduling_service.dart';
import '../widgets/reminder_list_item.dart';
import 'create_reminder_screen.dart';
import 'edit_reminder_screen.dart';

/// Main screen for managing smart reminders
class SmartRemindersScreen extends StatefulWidget {
  const SmartRemindersScreen({super.key});

  @override
  State<SmartRemindersScreen> createState() => _SmartRemindersScreenState();
}

class _SmartRemindersScreenState extends State<SmartRemindersScreen> {
  final _reminderService = SmartReminderService.instance;
  final _notificationService = NotificationSchedulingService.instance;
  
  List<SmartReminder> _reminders = [];
  bool _isLoading = true;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize services
      await _reminderService.initialize();
      await _notificationService.initialize();
      
      // Check notification permissions
      _notificationsEnabled = await _notificationService.areNotificationsEnabled();
      
      // Load reminders
      await _loadReminders();
    } catch (e) {
      print('Error initializing smart reminders: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadReminders() async {
    try {
      final reminders = _reminderService.getAllSmartReminders();
      print('Loading ${reminders.length} reminders from database');
      if (mounted) {
        setState(() {
          _reminders = reminders;
          _isLoading = false;
        });
        print('UI updated with ${_reminders.length} reminders');
      }
    } catch (e) {
      print('Error loading reminders: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestNotificationPermissions() async {
    final granted = await _notificationService.requestPermissions();
    if (mounted) {
      setState(() {
        _notificationsEnabled = granted;
      });
      
      if (granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifications enabled! Your reminders will now work.'),
            backgroundColor: theme.AppTheme.greenColor,
          ),
        );
        // Reschedule all reminders now that permissions are granted
        await _notificationService.rescheduleAllReminders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifications are required for reminders to work.'),
            backgroundColor: theme.AppTheme.orangeColor,
          ),
        );
      }
    }
  }

  Future<void> _toggleReminder(SmartReminder reminder) async {
    final success = await _reminderService.toggleReminderActive(reminder.id);
    if (success) {
      // Get the updated reminder to check its new state
      final updatedReminder = _reminderService.getSmartReminderById(reminder.id);
      if (updatedReminder != null) {
        if (updatedReminder.isActive) {
          // Reminder was turned on
          if (_notificationsEnabled) {
            await _notificationService.scheduleReminder(updatedReminder);
          }
        } else {
          // Reminder was turned off
          await _notificationService.cancelReminder(reminder.id);
        }
      }
      await _loadReminders();
    }
  }

  Future<void> _deleteReminder(SmartReminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.AppTheme.redColor,
              foregroundColor: theme.AppTheme.whiteColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        print('Deleting reminder with ID: ${reminder.id}');
        await _notificationService.cancelReminder(reminder.id);
        final success = await _reminderService.deleteReminder(reminder.id);
        print('Delete result: $success');
        
        if (success) {
          await _loadReminders();
          print('Reminders reloaded, count: ${_reminders.length}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminder deleted')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete reminder')),
            );
          }
        }
      } catch (e) {
        print('Error during deletion: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting reminder: $e')),
          );
        }
      }
    }
  }

  Future<void> _createNewReminder() async {
    if (!_notificationsEnabled) {
      await _requestNotificationPermissions();
      if (!_notificationsEnabled) return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateReminderScreen(),
      ),
    );

    if (result == true) {
      await _loadReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(title: const Text('Smart Reminders')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Reminders'),
        actions: [
          if (_notificationsEnabled)
            IconButton(
              icon: const Icon(Icons.notifications_active),
              onPressed: () async {
                try {
                  await _notificationService.showSimpleTestNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification sent!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Notification error: $e')),
                    );
                  }
                }
              },
              tooltip: 'Test Notifications',
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewReminder,
          ),
        ],
      ),
      body: _reminders.isEmpty ? _buildEmptyState() : _buildRemindersList(),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.AppTheme.blueMedium,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.notifications_none,
              size: 80,
              color: theme.AppTheme.blueColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Stay on Track with Smart Reminders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Get gentle nudges at the right moments to help you stay mindful of your goals. Smart reminders adapt to your schedule and provide personalized support.',
            style: TextStyle(
              fontSize: 16,
              color: theme.AppTheme.greyColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Reminder type examples
          _buildReminderTypeExample(
            SmartReminderType.friendlyCheckin,
            'Perfect for evening reflection or stress-prone times',
          ),
          const SizedBox(height: 16),
          _buildReminderTypeExample(
            SmartReminderType.scheduleReminder,
            'Helps you stay aware of your daily drinking plan',
          ),
          
          const SizedBox(height: 40),
          
          // Permission notice
          if (!_notificationsEnabled)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.AppTheme.orangeTransparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.AppTheme.orangeMediumTransparent),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.AppTheme.orangeColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notifications are required for reminders to work. We\'ll ask for permission when you create your first reminder.',
                      style: TextStyle(color: theme.AppTheme.orangeColor),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Create first reminder button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createNewReminder,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.AppTheme.blueColor,
                foregroundColor: theme.AppTheme.whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTypeExample(SmartReminderType type, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: type.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(type.icon, color: type.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type.description,
                  style: TextStyle(
                    color: theme.AppTheme.greyMedium,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: type.color,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    return Column(
      children: [
        // Permission warning if disabled
        if (!_notificationsEnabled)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.AppTheme.orangeTransparent,
            child: Row(
              children: [
                Icon(Icons.notifications_off, color: theme.AppTheme.orangeColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notifications are disabled. Your reminders won\'t work.',
                    style: TextStyle(color: theme.AppTheme.orangeColor),
                  ),
                ),
                TextButton(
                  onPressed: _requestNotificationPermissions,
                  child: const Text('Enable'),
                ),
              ],
            ),
          ),
        
        // Stats header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_reminders.where((r) => r.isActive).length} active reminder${_reminders.where((r) => r.isActive).length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _createNewReminder,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.AppTheme.blueColor,
                  foregroundColor: theme.AppTheme.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Reminders list
        Expanded(
          child: ListView.builder(
            itemCount: _reminders.length,
            itemBuilder: (context, index) {
              final reminder = _reminders[index];
              return ReminderListItem(
                reminder: reminder,
                onToggle: () => _toggleReminder(reminder),
                onEdit: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (context) => EditReminderScreen(reminder: reminder),
                    ),
                  );
                  
                  // Reload reminders if edit was successful
                  if (result == true) {
                    await _loadReminders();
                  }
                },
                onDelete: () => _deleteReminder(reminder),
                onTest: _notificationsEnabled ? () async {
                  await _notificationService.showTestNotification(reminder);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification sent!')),
                    );
                  }
                } : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
