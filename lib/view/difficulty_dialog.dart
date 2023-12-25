import 'package:flutter/material.dart';
import 'package:memory_game/bloc/game/game_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_game/model/game_difficulty.dart';

class DifficultyDialog extends StatelessWidget {
  const DifficultyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione a Dificuldade'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: GameDifficulty.values.map((difficulty) {
          return ListTile(
            title: Text(
              difficulty.description,
            ),
            onTap: () {
              context.read<GameBloc>().add(ChangeDifficultyEvent(difficulty: difficulty));
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }
}
