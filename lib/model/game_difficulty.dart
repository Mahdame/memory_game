import 'package:hive/hive.dart';

part 'game_difficulty.g.dart'; // This file will be generated

@HiveType(typeId: 1) // Choose a unique typeId for each TypeAdapter
enum GameDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard;

  bool get isEasy => this == GameDifficulty.easy;

  bool get isMedium => this == GameDifficulty.medium;

  bool get isHard => this == GameDifficulty.hard;

  String get description {
    switch (this) {
      case GameDifficulty.easy:
        return 'Fácil';
      case GameDifficulty.medium:
        return 'Médio';
      case GameDifficulty.hard:
        return 'Difícil';
      default:
        return '';
    }
  }

  int get numberOfCards {
    switch (this) {
      case GameDifficulty.easy:
        return 6;
      case GameDifficulty.medium:
        return 12;
      case GameDifficulty.hard:
        return 24;
      default:
        return 6;
    }
  }
}
