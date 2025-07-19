import 'package:flutter/material.dart';

/// Drinkmod App Theme
/// Provides a consistent, calming, and supportive design system
class AppTheme {
  // Color palette focused on calm, supportive tones
  static const Color primaryColor = Color(0xFF4A90E2); // Calm blue
  static const Color primaryVariant = Color(0xFF357ABD);
  static const Color secondaryColor = Color(0xFF7ED321); // Success green
  static const Color secondaryVariant = Color(0xFF5BA818);
  
  // Neutral colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textDisabled = Color(0xFFBDC3C7);
  
  // Status colors
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color infoColor = Color(0xFF3498DB);
  
  // Goal tracking colors
  static const Color goalMet = Color(0xFF27AE60);
  static const Color goalWarning = Color(0xFFF39C12);
  static const Color goalExceeded = Color(0xFFE74C3C);
  
  // Additional semantic colors
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color overlayBackground = Color(0x0D000000); // Colors.black.withValues(alpha: 0.05)
  
  // Purple theme colors
  static const Color purpleColor = Color(0xFF9B59B6);
  static const Color purpleLight = Color(0xFFE8D5E8);
  static const Color purpleDark = Color(0xFF8E44AD);
  
  // Pink/Red theme colors  
  static const Color pinkColor = Color(0xFFE91E63);
  
  // Teal theme colors
  static const Color tealColor = Color(0xFF1ABC9C);
  static const Color tealLight = Color(0xFFD5F4F1);
  
  // Amber theme colors
  static const Color amberColor = Color(0xFFFFC107);
  
  // Dark text colors
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color mediumText = Color(0xFF666666);
  static const Color lightText = Color(0xFF999999);
  
  // Extended color palette for comprehensive coverage
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFEEEEEE);  // grey.shade200
  static const Color greyMedium = Color(0xFF757575); // grey.shade600
  static const Color greyDark = Color(0xFF616161);   // grey.shade500
  static const Color greyVeryLight = Color(0xFFBDBDBD); // grey.shade400
  static const Color greyExtraLight = Color(0xFFF5F5F5); // grey.shade100
  static const Color greyWithAlpha = Color(0x4D9E9E9E); // grey.withValues(alpha: 0.3)
  static const Color redColor = Color(0xFFF44336);
  static const Color redLight = Color(0xFFFFEBEE);   // red.withOpacity(0.1)
  static const Color redMedium = Color(0xFFEF5350);  // red.withOpacity(0.2) border
  static const Color redDark = Color(0xFFD32F2F);    // red.shade700
  static const Color redVeryLight = Color(0xFFFFCDD2); // red.shade100
  static const Color redVeryVeryLight = Color(0xFFFFF5F5); // red.shade50
  static const Color redMediumDark = Color(0xFFE53935); // red.shade600
  static const Color orangeColor = Color(0xFFFF9800);
  static const Color orangeMedium = Color(0xFFFFB74D); // orange.shade400
  static const Color orangeDark = Color(0xFFF57C00);   // orange.shade600
  static const Color orangeDarkest = Color(0xFFE65100); // orange.shade700
  static const Color orangeLight = Color(0xFFFFE0B2);  // orange.shade100
  static const Color orangeVeryLight = Color(0xFFFFF3E0); // orange.shade50
  static const Color orangeLightest = Color(0xFFFFCC80); // orange.shade200
  static const Color greenColor = Color(0xFF4CAF50);
  static const Color greenMedium = Color(0xFF66BB6A); // green.shade400
  static const Color greenDark = Color(0xFF388E3C);   // green.shade600
  static const Color greenLight = Color(0xFFC8E6C9); // green.shade100
  static const Color blueColor = Color(0xFF2196F3);
  static const Color blueLight = Color(0xFFE3F2FD);   // blue.withOpacity(0.05)
  static const Color blueMedium = Color(0xFFBBDEFB);  // blue.withOpacity(0.1)
  static const Color blueLighter = Color(0xFFF3F9FF); // blue.shade50
  static const Color blueLightShade = Color(0xFFE3F2FD); // blue.shade50
  static const Color blueMediumShade = Color(0xFFBBDEFB); // blue.shade200  
  static const Color blueDarkShade = Color(0xFF1976D2);   // blue.shade700
  static const Color greenLightShade = Color(0xFFE8F5E8); // green.shade50
  static const Color greenMediumShade = Color(0xFFC8E6C9); // green.shade200
  static const Color greenDarkShade = Color(0xFF388E3C);   // green.shade700
  
  // Additional utility colors
  static const Color transparentColor = Colors.transparent;
  static const Color blackColor = Color(0xFF000000);
  static const Color blackSemiTransparent = Color(0x14000000); // black.withValues(alpha: 0.05)
  static const Color blackMediumTransparent = Color(0x1A000000); // black.withValues(alpha: 0.1)
  static const Color blackText87 = Color(0xDD000000); // Colors.black87
  static const Color blackText54 = Color(0x8A000000); // Colors.black54
  static const Color indigoLight = Color(0xFFE8EAF6); // indigo.shade50
  static const Color greenVeryLight = Color(0xFFE8F5E8); // green.shade50 
  static const Color tealVeryLight = Color(0xFFE0F2F1); // teal.shade50
  static const Color redMediumLight = Color(0xFFEF5350); // red.shade400
  static const Color orangeTransparent = Color(0x1AFF9800); // orange.withValues(alpha: 0.1)
  static const Color orangeMediumTransparent = Color(0x4DFF9800); // orange.withValues(alpha: 0.3)
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textDisabled),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        selectedColor: primaryColor.withValues(alpha: 0.2),
        disabledColor: Colors.grey[200],
        labelStyle: const TextStyle(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Colors.grey,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Dark theme for future implementation
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
    );
  }
}

/// Text styles for consistent typography
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppTheme.textSecondary,
  );
  
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppTheme.textDisabled,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

/// Common spacing values
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Common border radius values
class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double round = 50.0;
}
