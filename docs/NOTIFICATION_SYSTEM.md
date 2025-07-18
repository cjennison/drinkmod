# Drinkmod Notification System Documentation

## Overview

The Drinkmod notification system provides cross-platform local notifications for Smart Reminders, designed to help users maintain their alcohol moderation goals through timely, personalized reminders. The system supports iOS, Android, and Linux platforms with platform-specific optimizations.

## Architecture Overview

### Core Components

1. **NotificationSchedulingService**: Main service for scheduling, managing, and delivering notifications
2. **ReminderContentGenerator**: Generates personalized, context-aware content for notifications
3. **NotificationConfigurationService**: Manages user preferences and notification settings
4. **NotificationAnalyticsService**: Tracks notification effectiveness and user engagement

### Technology Stack

- **Flutter Local Notifications**: v19.3.1 - Cross-platform notification plugin
- **Timezone**: For accurate scheduling across timezones
- **Shared Preferences**: User preference storage
- **Platform-specific APIs**: Native notification channels and permissions

## Platform-Specific Implementation

### iOS Implementation

#### Permission Model
- **Request Flow**: Explicit permission request using `DarwinInitializationSettings`
- **Permission Types**: Alert, Badge, Sound permissions requested individually
- **Default Behavior**: Notifications present alerts, sounds, and update badge count by default
- **User Control**: Users can modify permissions in iOS Settings app

#### Notification Features
```dart
const iosInit = DarwinInitializationSettings(
  requestSoundPermission: true,
  requestBadgePermission: true,
  requestAlertPermission: true,
  defaultPresentAlert: true,
  defaultPresentSound: true,
  defaultPresentBadge: true,
);
```

#### iOS-Specific Behavior
- **Delivery**: Notifications delivered through iOS Notification Center
- **Scheduling**: Uses `UNUserNotificationCenter` with `DateTimeComponents.dayOfWeekAndTime`
- **Background Delivery**: Reliable delivery when app is backgrounded or closed
- **User Interaction**: Tapping notification opens app with payload data
- **Customization**: Limited styling options due to iOS design guidelines

#### iOS Configuration Requirements
- **Info.plist**: No additional notification-specific entries required for local notifications
- **Bundle Identifier**: Must be properly configured for notification delivery
- **App Store Review**: Local notifications typically approved without additional review

### Android Implementation

#### Permission Model
- **Request Flow**: Dynamic permission request using `AndroidFlutterLocalNotificationsPlugin`
- **Permission Check**: `areNotificationsEnabled()` checks current permission status
- **Request Method**: `requestNotificationsPermission()` prompts user for permission
- **Fallback**: Graceful degradation when permissions denied

#### Notification Channels
```dart
const androidDetails = AndroidNotificationDetails(
  'smart_reminders',                    // Channel ID
  'Smart Reminders',                    // Channel Name
  channelDescription: 'Personalized reminders for your wellness journey',
  importance: Importance.defaultImportance,
  priority: Priority.defaultPriority,
  showWhen: true,
  enableVibration: true,
  playSound: true,
  styleInformation: BigTextStyleInformation(...),
);
```

#### Android-Specific Features
- **Rich Content**: Support for `BigTextStyleInformation` for expandable notifications
- **Custom Icons**: Uses `@mipmap/ic_launcher` as notification icon
- **Scheduling Mode**: `AndroidScheduleMode.exactAllowWhileIdle` for reliable delivery
- **Vibration & Sound**: Configurable vibration patterns and custom sounds
- **Action Buttons**: Support for interactive notification actions (future feature)

#### Android Configuration Requirements
- **Minimum SDK**: Android API level support based on Flutter requirements
- **Permissions**: No explicit notification permissions in AndroidManifest.xml (handled at runtime)
- **Background Execution**: Uses exact alarm permissions for precise scheduling
- **Battery Optimization**: Notifications work with Doze mode and battery optimization

## Technical Implementation Details

### Notification Scheduling Flow

1. **Initialization**
   ```dart
   await NotificationSchedulingService.instance.initialize();
   ```
   - Initialize timezone data with multiple fallback strategies
   - Configure platform-specific notification settings
   - Check and cache notification permissions

2. **Permission Management**
   ```dart
   final enabled = await notificationService.areNotificationsEnabled();
   if (!enabled) {
     final granted = await notificationService.requestPermissions();
   }
   ```
   - Cached permission checks (5-minute cache expiry)
   - Platform-specific permission request flows
   - Graceful handling of permission denial

3. **Reminder Scheduling**
   ```dart
   await notificationService.scheduleReminder(reminder);
   ```
   - Cancel existing notifications for the reminder
   - Generate personalized content using ReminderContentGenerator
   - Schedule notifications for each enabled weekday
   - Use `zonedSchedule()` with timezone-aware scheduling

### Timezone Handling

The system implements a robust timezone strategy with multiple fallbacks:

1. **Primary Strategy**: Device timezone detection
   ```dart
   final deviceTimeZone = DateTime.now().timeZoneName;
   final location = tz.getLocation(deviceTimeZone);
   tz.setLocalLocation(location);
   ```

2. **Fallback Strategy**: Common timezone patterns based on UTC offset
   ```dart
   final offset = DateTime.now().timeZoneOffset;
   final hourOffset = offset.inHours;
   // Map to common timezones (America/Los_Angeles, America/New_York, etc.)
   ```

3. **Final Fallback**: UTC timezone
   ```dart
   tz.setLocalLocation(tz.UTC);
   ```

### Content Generation

Notifications use the `ReminderContentGenerator` to create personalized, engaging content:

- **Context-Aware**: Content varies based on time of day, reminder type, and user patterns
- **Personalization**: User preferences influence message tone and style
- **Variety**: Multiple message templates prevent notification fatigue
- **Motivational**: Positive, encouraging language aligned with therapeutic principles

### Error Handling and Reliability

#### Retry Logic
```dart
Future<void> _cancelNotificationWithRetry(int notificationId, [int retries = 2]) async {
  for (int attempt = 0; attempt <= retries; attempt++) {
    try {
      await _notificationsPlugin.cancel(notificationId);
      return;
    } catch (e) {
      if (attempt == retries) {
        // Log final failure
      } else {
        await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
      }
    }
  }
}
```

#### Permission Caching
- Reduces API calls by caching permission status
- 5-minute cache expiry ensures up-to-date status
- Automatic refresh on permission state changes

#### Graceful Degradation
- App continues to function when notifications disabled
- Clear user feedback about notification status
- Alternative reminder mechanisms (in-app alerts) as fallback

## User Experience Considerations

### Therapeutic Design Principles

1. **Non-Intrusive**: Notifications respect user's daily routine
2. **Empowering Language**: Messages focus on user control and positive choices
3. **Customizable**: Users can adjust frequency, timing, and content style
4. **Privacy-Focused**: All notifications processed locally, no cloud dependency

### Accessibility Features

- **High Contrast**: Notification content readable in all system themes
- **Screen Reader Support**: Proper semantic markup for accessibility
- **Customizable Timing**: Quiet hours prevent notifications during sleep
- **Multiple Modalities**: Visual, auditory, and haptic feedback options

### Battery and Performance Optimization

- **Efficient Scheduling**: Minimal CPU usage through native platform APIs
- **Batched Operations**: Multiple notifications scheduled in single operation
- **Smart Caching**: Reduced redundant permission checks and service calls
- **Background Optimization**: Works with platform battery optimization features

## Testing and Debugging

### Development Tools

1. **Test Notifications**: `showTestNotification()` for immediate feedback
2. **Pending Notifications**: `getPendingNotifications()` for debugging scheduled notifications
3. **Debug Logging**: Comprehensive logging with severity levels
4. **Permission Status**: Real-time permission status checking

### Platform Testing Considerations

#### iOS Testing
- Test on physical devices for accurate notification timing
- Verify behavior across iOS versions and device types
- Test permission flows in both granted and denied states
- Validate timezone handling across different regions

#### Android Testing
- Test across different Android versions and manufacturers
- Verify behavior with battery optimization settings
- Test notification channels and importance levels
- Validate exact alarm scheduling permissions

## Configuration and Customization

### User Preferences

Users can customize notification behavior through `NotificationConfigurationService`:

- **Sound & Vibration**: Enable/disable audio and haptic feedback
- **Quiet Hours**: Define time periods for silent notifications
- **Content Style**: Choose between minimal, standard, or detailed notifications
- **Personalization Level**: Control how personalized notification content should be
- **Smart Timing**: Enable AI-optimized notification timing based on user patterns

### Developer Configuration

Developers can modify notification behavior through:

- **Channel Configuration**: Update notification channels for different reminder types
- **Content Templates**: Modify message templates in ReminderContentGenerator
- **Scheduling Logic**: Adjust timing algorithms and retry policies
- **Permission Handling**: Customize permission request flows and fallback behavior

## Future Enhancements

### Planned Features

1. **Rich Media**: Support for images and custom sounds in notifications
2. **Interactive Actions**: Quick actions directly from notification (snooze, complete, etc.)
3. **Smart Bundling**: Group related notifications to reduce notification fatigue
4. **Adaptive Timing**: Machine learning-optimized delivery times based on user engagement
5. **Cross-Device Sync**: Synchronize notification preferences across user devices

### Platform-Specific Roadmap

#### iOS Enhancements
- **Notification Extensions**: Rich media and interactive content
- **Siri Integration**: Voice-activated reminder management
- **Shortcuts Integration**: Quick actions through iOS Shortcuts app
- **Focus Modes**: Integration with iOS Focus modes for context-aware delivery

#### Android Enhancements
- **Adaptive Notifications**: Dynamic importance based on user interaction
- **Notification Bubbles**: Floating reminders for urgent situations
- **Digital Wellbeing**: Integration with Android's usage tracking
- **Wear OS Support**: Notification delivery to Android smartwatches

## Troubleshooting

### Common Issues

1. **Notifications Not Appearing**
   - Check notification permissions in device settings
   - Verify timezone configuration
   - Ensure app has background execution permissions

2. **Incorrect Timing**
   - Check device timezone settings
   - Verify user's configured reminder times
   - Review timezone fallback logs

3. **Permission Denied**
   - Guide users to device notification settings
   - Provide clear instructions for re-enabling permissions
   - Offer alternative reminder mechanisms

### Debugging Steps

1. Enable debug logging in `NotificationSchedulingService`
2. Use `getPendingNotifications()` to verify scheduled notifications
3. Test with `showTestNotification()` for immediate feedback
4. Check platform-specific permission status
5. Verify timezone initialization logs

## Security and Privacy

### Data Protection
- All notification content generated locally
- No personal data transmitted to external services
- User preferences stored locally with device encryption
- Notification payloads contain only reminder IDs, no sensitive data

### Platform Security
- Leverages platform-native security features
- Respects system-level notification privacy settings
- Compatible with device encryption and secure boot
- No network dependencies for core notification functionality

This documentation serves as a comprehensive guide for understanding, maintaining, and extending the Drinkmod notification system across iOS and Android platforms.
