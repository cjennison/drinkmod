import 'package:flutter/material.dart';

/// Global spacing constants for consistent app-wide margins and padding
class AppSpacing {
  AppSpacing._();
  
  /// Standard horizontal screen padding for consistent margins across all screens
  static const double screenHorizontal = 16.0;
  
  /// Standard vertical screen padding
  static const double screenVertical = 16.0;
  
  /// Standard screen padding for all directions
  static const EdgeInsets screenPadding = EdgeInsets.all(screenHorizontal);
  
  /// Horizontal-only screen padding for components that need consistent side margins
  static const EdgeInsets screenHorizontalPadding = EdgeInsets.symmetric(horizontal: screenHorizontal);
  
  /// Vertical-only screen padding
  static const EdgeInsets screenVerticalPadding = EdgeInsets.symmetric(vertical: screenVertical);
  
  /// Custom screen padding with optional top/bottom override
  static EdgeInsets screenPaddingWithTop(double top) =>
      EdgeInsets.fromLTRB(screenHorizontal, top, screenHorizontal, screenVertical);
  
  static EdgeInsets screenPaddingWithBottom(double bottom) =>
      EdgeInsets.fromLTRB(screenHorizontal, screenVertical, screenHorizontal, bottom);
}
