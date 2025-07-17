import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/achievements/achievement_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DrinkmodApp());
}

class DrinkmodApp extends StatelessWidget {
  const DrinkmodApp({super.key});

  // Global navigator key for achievement modals
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Initialize achievement system with global navigator
    AchievementHelper.initialize(navigatorKey);
    
    return MaterialApp.router(
      title: 'Drinkmod',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
