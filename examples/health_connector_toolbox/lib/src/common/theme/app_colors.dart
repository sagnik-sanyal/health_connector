import 'package:flutter/material.dart';

/// Centralized collection of color constants used throughout the application.
///
/// This class provides a consistent color palette for success, error, warning,
/// info, and neutral states, ensuring a cohesive visual design.
abstract final class AppColors {
  // Success colors
  static const Color success = Colors.green;
  static const Color successDark = Color(0xFF388E3C); // Colors.green[700]
  static Color successLight = Colors.green.withValues(alpha: 0.1);

  // Error colors
  static const Color error = Colors.red;
  static const Color errorLight = Color(0xFFEF5350); // Colors.red[300]
  static const Color errorDark = Color(0xFFC62828); // Colors.red[700]
  static Color errorLightBackground = Colors.red.withValues(alpha: 0.1);

  // Warning colors
  static const Color warning = Colors.orange;
  static const Color amber = Colors.amber;
  static const Color amber700 = Color(0xFFF57C00); // Colors.amber[700]
  static const Color amber900 = Color(0xFFE65100); // Colors.amber[900]
  static Color amberLight = Colors.amber.withValues(alpha: 0.1);
  static Color amberBorder = Colors.amber.withValues(alpha: 0.3);

  // Info/Feature colors
  static const Color info = Colors.blue;
  static const Color infoDark = Color(0xFF1976D2); // Colors.blue[700]
  static Color infoLight = Colors.blue.withValues(alpha: 0.1);

  // Neutral/Grey colors
  static const Color grey = Colors.grey;
  static const Color grey300 = Color(0xFFE0E0E0); // Colors.grey[300]
  static const Color grey400 = Color(0xFFBDBDBD); // Colors.grey[400]
  static const Color grey600 = Color(0xFF757575); // Colors.grey[600]
  static const Color grey700 = Color(0xFF616161); // Colors.grey[700]
  static Color greyLight = Colors.grey.withValues(alpha: 0.1);

  // Text colors
  static const Color textOnColored = Colors.white;

  // Shadow colors
  static Color shadow = Colors.black.withValues(alpha: 0.1);

  // Theme colors
  static const Color themeSeed = Colors.blue;
}
