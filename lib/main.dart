import 'dart:async';
import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/achievements/achievement_helper.dart';

void main() {
  // Add error handling and debugging
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Add error handling for unhandled exceptions
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };
    
    runApp(const DrinkmodApp());
  }, (error, stack) {
    debugPrint('Unhandled error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class DrinkmodApp extends StatelessWidget {
  const DrinkmodApp({super.key});

  // Global navigator key for achievement modals
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    try {
      // Initialize achievement system with global navigator
      AchievementHelper.initialize(navigatorKey);
      
      return MaterialApp.router(
        title: 'Drinkmod',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      );
    } catch (e, stack) {
      debugPrint('Error in DrinkmodApp build: $e');
      debugPrint('Stack trace: $stack');
      
      // Return a basic error screen if something goes wrong
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('App Initialization Error'),
                const SizedBox(height: 8),
                Text('$e'),
              ],
            ),
          ),
        ),
      );
    }
  }
}
