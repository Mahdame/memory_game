import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class ThemeToggleIcon extends StatelessWidget {
  const ThemeToggleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: IconButton(
        icon: themeNotifier.isDarkMode
            ? const Icon(
                Icons.brightness_5,
                color: Colors.amber,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              )
            : const Icon(Icons.brightness_3), // Sun for light, moon for dark
        onPressed: () => themeNotifier.toggleTheme(),
      ),
    );
  }
}
