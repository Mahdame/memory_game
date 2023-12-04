import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();
  bool get isDarkMode => _currentTheme == ThemeData.dark();

  void toggleTheme() {
    if (isDarkMode) {
      _currentTheme = ThemeData.light();
    } else {
      _currentTheme = ThemeData.dark();
    }
    notifyListeners();
  }

  ThemeData get currentTheme => _currentTheme;
}
