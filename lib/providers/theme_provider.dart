import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  final lightTheme = ThemeData(
    primarySwatch: Colors.pink,
    primaryColor: const Color(0xFFFF69B4),
    scaffoldBackgroundColor: const Color(0xFFFFF0F5),
    appBarTheme: AppBarTheme(
      elevation: 8,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFFFF69B4),
      // FIXED: Used withOpacity() instead of withValues()
      shadowColor: Colors.pink.withOpacity(0.3),
    ),
    // FIXED: Used CardThemeData instead of CardTheme
    cardTheme: CardThemeData(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSansJP',
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'NotoSansJP',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontFamily: 'NotoSansJP',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontFamily: 'NotoSansJP',
      ),
    ),
  );

  final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.pink,
    primaryColor: const Color(0xFFFF69B4),
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    appBarTheme: AppBarTheme(
      elevation: 8,
      backgroundColor: const Color(0xFF0F0F1E),
      foregroundColor: const Color(0xFFFF69B4),
      // FIXED: Used withOpacity() instead of withValues()
      shadowColor: Colors.black.withOpacity(0.5),
    ),
    // FIXED: Used CardThemeData instead of CardTheme
    cardTheme: CardThemeData(
      color: const Color(0xFF2A2A3E),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 6,
        backgroundColor: const Color(0xFFFF69B4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSansJP',
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'NotoSansJP',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontFamily: 'NotoSansJP',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontFamily: 'NotoSansJP',
      ),
    ),
  );

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveTheme();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
            (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.toString());
  }
}
