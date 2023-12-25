import 'package:flutter/material.dart';
import 'package:memory_game/bloc/game/game_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CardTheme {
  amongus,
  minecraft;

  String get description {
    switch (this) {
      case CardTheme.amongus:
        return 'Among Us';
      case CardTheme.minecraft:
        return 'Minecraft';
      default:
        return '';
    }
  }

  String get theme {
    switch (this) {
      case CardTheme.amongus:
        return 'amongus';
      case CardTheme.minecraft:
        return 'minecraft';
      default:
        return '';
    }
  }
}

class CardThemeDialog extends StatelessWidget {
  const CardThemeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione um tema'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: CardTheme.values.map((cardTheme) {
          return ListTile(
            title: Text(
              cardTheme.description,
            ),
            onTap: () {
              context.read<GameBloc>().add(ChangeCardThemeEvent(cardThemeName: cardTheme.theme));
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }
}
