import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:memory_game/bloc/game_bloc.dart';
import 'package:memory_game/config/theme_toggle_icon.dart';
import 'package:memory_game/model/game_card.dart';
import 'package:memory_game/model/game_difficulty.dart';
import 'package:memory_game/view/instructions.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => BlocProvider.of<GameBloc>(context).add(GameInitialMenu())),
        actions: [
          TextButton(
            onPressed: () => _showDifficultySelectionDialog(context),
            child: const Text(
              'Dificuldade',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const VerticalDivider(
            width: 50.0,
            color: Colors.white,
            indent: 10.0,
            endIndent: 10.0,
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => BlocProvider.of<GameBloc>(context).add(ResetGameEvent()),
            child: const Text('Reiniciar Jogo'),
          ),
          const VerticalDivider(
            width: 50.0,
            color: Colors.white,
            indent: 10.0,
            endIndent: 10.0,
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => _showThemeSelectionDialog(context),
            child: const Text('Trocar Tema'),
          ),
          const VerticalDivider(
            width: 50.0,
            color: Colors.white,
            indent: 10.0,
            endIndent: 10.0,
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return InstructionsWidget(
                  instructions:
                      'Carregue nas cartas para as virar e encontrar um par.\nO jogo termina quando todas as cartas estiverem viradas.',
                  onClose: () => Navigator.of(context).pop(),
                );
              },
            ),
            child: const Text('Instruções'),
          ),
          const VerticalDivider(
            width: 50.0,
            color: Colors.white,
            indent: 10.0,
            endIndent: 10.0,
          ),
          const ThemeToggleIcon(),
          const SizedBox(width: 30.0),
          // Optionally add more widgets like instructions, settings, etc.
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          // Accessing GameBloc to get score and time
          final gameBloc = context.read<GameBloc>();

          if (state is GameInitialState) {
            return buildInitialView(context);
          } else if (state is GameDisplayState || state is CardFlipState || state is MatchCheckState) {
            return Column(
              children: [
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pontos: ${gameBloc.score}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(width: 20.0),
                    Text(
                      'Tempo: ${gameBloc.elapsedTime} segundos',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Expanded(
                  child: buildGameGrid(context, gameBloc.cards!),
                ),
              ],
            );
          } else if (state is GameOverState || state is ScoreboardState) {
            return _buildGameOverView(context);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildInitialView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Jogo da Memória', style: TextStyle(fontSize: 36.0)),
          const SizedBox(height: 10.0),
          const Text('Versão 1.0', style: TextStyle(fontSize: 20.0)),
          const SizedBox(height: 25.0),
          const Text('(em breve a versão 2.0)', style: TextStyle(fontSize: 12.0)),
          const SizedBox(height: 40.0),
          SizedBox(
            width: 200.0,
            height: 50.0,
            child: ElevatedButton(
              onPressed: () => BlocProvider.of<GameBloc>(context).add(GameStartEvent()),
              child: const Text('Iniciar Jogo', style: TextStyle(fontSize: 24.0)),
            ),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            width: 200.0,
            height: 50.0,
            child: ElevatedButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => BlocProvider.of<GameBloc>(context).add(ScoreboardEvent()),
              child: const Text('Pontuações', style: TextStyle(fontSize: 24.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGameGrid(BuildContext context, List<GameCard> cards) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cards.length ~/ 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return GestureDetector(
          onTap: () {
            BlocProvider.of<GameBloc>(context).add(FlipCardEvent(index));
          },
          child: GameCard(
            key: ValueKey(card.content.split('/').last),
            content: card.content,
            isFlipped: card.isFlipped,
            isMatched: card.isMatched,
          ),
        );
      },
    );
  }

  Widget _buildGameOverView(BuildContext context) {
    var box = Hive.box('gameResultsBox');
    List results = box.get('results', defaultValue: []);

    // Sort results in descending order of score
    results.sort((a, b) => b.score.compareTo(a.score));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20.0),
        const Text('Pontuações', style: TextStyle(fontSize: 20.0)),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  title: Text('Pontos: ${result.score}'),
                  subtitle: Text('Tempo: ${result.elapsedTime} segundos'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDifficultySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione a Dificuldade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: Difficulty.values.map((difficulty) {
              return ListTile(
                title: Text(describeDifficulty(difficulty)),
                onTap: () {
                  BlocProvider.of<GameBloc>(context).add(ChangeDifficultyEvent(difficulty: difficulty));
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String describeDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Fácil';
      case Difficulty.medium:
        return 'Médio';
      case Difficulty.hard:
        return 'Difícil';
      default:
        return '';
    }
  }

  void _showThemeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione um tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Among Us'),
                onTap: () {
                  BlocProvider.of<GameBloc>(context).add(ChangeThemeEvent(themeName: 'amongus'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Minecraft'),
                onTap: () {
                  BlocProvider.of<GameBloc>(context).add(ChangeThemeEvent(themeName: 'minecraft'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Minecraft 2'),
                onTap: () {
                  BlocProvider.of<GameBloc>(context).add(ChangeThemeEvent(themeName: 'minecraft_2'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
