import 'package:memory_game/model/game_difficulty.dart';

class DifficultySettings {
  static Map<Difficulty, int> cardCount = {
    Difficulty.easy: 8, // 4 pares
    Difficulty.medium: 16, // 8 pares
    Difficulty.hard: 24, // 12 pares
  };
}
