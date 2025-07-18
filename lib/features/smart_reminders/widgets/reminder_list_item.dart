import 'package:flutter/material.dart';
import '../models/smart_reminder.dart';

/// Individual list item widget for displaying a smart reminder
class ReminderListItem extends StatelessWidget {
  final SmartReminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTest;

  const ReminderListItem({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: reminder.isActive ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reminder.isActive 
              ? reminder.type.color.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Type icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: reminder.type.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        reminder.type.icon,
                        color: reminder.type.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Title and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: reminder.isActive ? Colors.black : Colors.grey,
                            ),
                          ),
                          Text(
                            reminder.type.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: reminder.isActive ? reminder.type.color : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Active toggle
                    Switch(
                      value: reminder.isActive,
                      onChanged: (_) => onToggle(),
                      activeColor: reminder.type.color,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                
                // Schedule info
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: reminder.isActive 
                        ? Colors.grey.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: reminder.isActive ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatSchedule(),
                          style: TextStyle(
                            fontSize: 13,
                            color: reminder.isActive ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Message preview if available
                if (reminder.message?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"${reminder.message}"',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: reminder.isActive ? Colors.grey[700] : Colors.grey[500],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Action buttons row
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Test button (only if notifications enabled)
                    if (onTest != null && reminder.isActive) ...[
                      TextButton.icon(
                        onPressed: onTest,
                        icon: const Icon(Icons.notifications_outlined, size: 16),
                        label: const Text('Test'),
                        style: TextButton.styleFrom(
                          foregroundColor: reminder.type.color,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // Edit button
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Delete button
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSchedule() {
    final timeStr = _formatTime(reminder.timeOfDay);
    final daysStr = _formatDays(reminder.weekDays);
    
    return '$timeStr • $daysStr';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    
    return '$hour:$minute $period';
  }

  String _formatDays(List<int> weekDays) {
    if (weekDays.length == 7) {
      return 'Every day';
    }
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = List<int>.from(weekDays)..sort();
    
    // Check for common patterns
    if (sortedDays.length == 5 && 
        sortedDays.every((day) => day >= 1 && day <= 5)) {
      return 'Weekdays';
    }
    
    if (sortedDays.length == 2 && 
        sortedDays.contains(6) && sortedDays.contains(7)) {
      return 'Weekends';
    }
    
    // Check for consecutive days
    if (sortedDays.length > 2 && _areConsecutive(sortedDays)) {
      return '${dayNames[sortedDays.first - 1]} - ${dayNames[sortedDays.last - 1]}';
    }
    
    // Individual days
    if (sortedDays.length <= 3) {
      return sortedDays.map((day) => dayNames[day - 1]).join(', ');
    }
    
    // Too many individual days, show count
    return '${sortedDays.length} days per week';
  }

  bool _areConsecutive(List<int> days) {
    for (int i = 1; i < days.length; i++) {
      if (days[i] != days[i - 1] + 1) {
        return false;
      }
    }
    return true;
  }
}
