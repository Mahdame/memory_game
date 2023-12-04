import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class ThemeToggleIcon extends StatelessWidget {
  const ThemeToggleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return IconButton(
      icon: Icon(themeNotifier.isDarkMode ? Icons.brightness_5 : Icons.brightness_3), // Sun for light, moon for dark
      onPressed: () => themeNotifier.toggleTheme(),
    );
  }
}
