import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_game/bloc/game/game_bloc.dart';
import 'package:memory_game/bloc/medal/medal_bloc.dart';
import 'package:memory_game/config/theme_toggle_icon.dart';
import 'package:memory_game/model/game_card.dart';
import 'package:memory_game/view/card_theme.dart';
import 'package:memory_game/view/difficulty_dialog.dart';
import 'package:memory_game/view/instructions_dialog.dart';
import 'package:memory_game/widgets/medal_painter.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final gameBloc = context.read<GameBloc>();
        final inMainMenu = state is GameInitialState;
        final inGameOver = state is GameOverState;
        final inScoreboard = state is ScoreboardState;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal[300],
            leading: inMainMenu
                ? null
                : BackButton(
                    onPressed: () => gameBloc.add(GameInitialMenu()),
                  ),
            actions: _buildActions(context),
          ),
          body: inMainMenu
              ? _buildInitialView(context)
              : inScoreboard
                  ? _buildScoreboardView(context)
                  : inGameOver
                      ? _buildGameOverView(context)
                      : _buildGameView(context),
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    final inMainMenu = gameBloc.state is GameInitialState;
    final inGame =
        gameBloc.state is GameDisplayState || gameBloc.state is MatchCheckState || gameBloc.state is CardFlipState;

    return [
      inMainMenu
          ? TextButton(
              onPressed: () => _showDifficultySelectionDialog(context),
              child: const Text(
                'Dificuldade',
                style: TextStyle(color: Colors.white),
              ),
            )
          : const SizedBox.shrink(),
      inMainMenu
          ? const VerticalDivider(
              width: 50.0,
              color: Colors.white,
              indent: 10.0,
              endIndent: 10.0,
            )
          : const SizedBox.shrink(),
      inGame
          ? TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => context.read<GameBloc>().add(ResetGameEvent()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reiniciar Jogo'),
            )
          : const SizedBox.shrink(),
      inMainMenu
          ? const SizedBox.shrink()
          : const VerticalDivider(
              width: 50.0,
              color: Colors.white,
              indent: 10.0,
              endIndent: 10.0,
            ),
      inMainMenu
          ? TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => _showThemeSelectionDialog(context),
              child: const Text('Trocar Tema'),
            )
          : const SizedBox.shrink(),
      inMainMenu
          ? const VerticalDivider(
              width: 50.0,
              color: Colors.white,
              indent: 10.0,
              endIndent: 10.0,
            )
          : const SizedBox.shrink(),
      inMainMenu
          ? TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => _showInstructionsDialog(context),
              child: const Text('Instruções'),
            )
          : const SizedBox.shrink(),
      inMainMenu
          ? const VerticalDivider(
              width: 50.0,
              color: Colors.white,
              indent: 10.0,
              endIndent: 10.0,
            )
          : const SizedBox.shrink(),
      const ThemeToggleIcon(),
    ];
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Jogo da Memória',
            style: TextStyle(
              fontSize: 56.0,
              fontFamily: GoogleFonts.pacifico().fontFamily,
              color: Colors.teal[300],
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            'Versão 1.0',
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: GoogleFonts.aBeeZee().fontFamily,
            ),
          ),
          const SizedBox(height: 25.0),
          const Text(
            '(em breve a versão 2.0)',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40.0),
          SizedBox(
            width: 200.0,
            height: 50.0,
            child: ElevatedButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[300],
                elevation: 10.0,
                shadowColor: Colors.blue[300],
              ),
              onPressed: () => context.read<GameBloc>().add(GameStartEvent()),
              child: const Text('Iniciar Jogo', style: TextStyle(fontSize: 20.0)),
            ),
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: 200.0,
            height: 50.0,
            child: ElevatedButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal[300],
                elevation: 10.0,
                shadowColor: Colors.teal[300],
              ),
              onPressed: () => context.read<GameBloc>().add(ScoreboardEvent()),
              child: const Text('Pontuações', style: TextStyle(fontSize: 20.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pontos: ${context.read<GameBloc>().score}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(width: 20.0),
            Text(
              'Tempo: ${context.read<GameBloc>().elapsedTime} segundos',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
        Expanded(
          child: _buildGameGrid(context, context.read<GameBloc>().cards!),
        ),
      ],
    );
  }

  Widget _buildGameGrid(BuildContext context, List<GameCard> cards) {
    // Determine the width of the screen
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the number of columns based on the screen width
    final crossAxisCount = (screenWidth / 150).floor();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return GestureDetector(
          onTap: () {
            context.read<GameBloc>().add(FlipCardEvent(index));
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Jogo Terminado!', style: TextStyle(fontSize: 24.0)),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<MedalBloc, MedalState>(
                builder: (context, state) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: state.shinePosition),
                    duration: const Duration(seconds: 3),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: const Size(200, 150),
                        painter: MedalPainter(shinePosition: state.shinePosition),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Text(
            'Pontos: ${context.read<GameBloc>().score}',
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Tempo: ${context.read<GameBloc>().elapsedTime} segundos',
            style: const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 50.0),
          SizedBox(
            width: 250.0,
            height: 50.0,
            child: ElevatedButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.pink[300],
                elevation: 10.0,
                shadowColor: Colors.pink[300],
              ),
              onPressed: () => context.read<GameBloc>().add(GameStartEvent()),
              child: const Text('Jogar novamente', style: TextStyle(fontSize: 20.0)),
            ),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            width: 200.0,
            height: 50.0,
            child: ElevatedButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal[300],
                elevation: 10.0,
                shadowColor: Colors.teal[300],
              ),
              onPressed: () => context.read<GameBloc>().add(ScoreboardEvent()),
              child: const Text('Pontuações', style: TextStyle(fontSize: 20.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboardView(BuildContext context) {
    final gameBloc = context.read<GameBloc>();

    if (gameBloc.gameResults.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20.0),
          const Text('Pontuações', style: TextStyle(fontSize: 20.0)),
          Expanded(
            child: ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text('Sem pontuações.'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20.0),
        const Text('Pontuações', style: TextStyle(fontSize: 20.0)),
        Expanded(
          child: ListView.builder(
            itemCount: gameBloc.gameResults.length,
            itemBuilder: (context, index) {
              final result = gameBloc.gameResults[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  title: Text('Pontos: ${result.score!}'),
                  subtitle: Text('Tempo: ${result.elapsedTime} segundos'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

void _showDifficultySelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const DifficultyDialog();
    },
  );
}

void _showInstructionsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return InstructionsDialog(
        instructions:
            'Carregue nas cartas para as virar e encontrar um par.\nO jogo termina quando todas as cartas estiverem viradas.',
        onClose: () => Navigator.of(context).pop(),
      );
    },
  );
}

void _showThemeSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CardThemeDialog();
    },
  );
}
