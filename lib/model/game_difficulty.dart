import 'package:hive/hive.dart';

part 'game_difficulty.g.dart'; // This file will be generated

enum Difficulty { easy, medium, hard }

@HiveType(typeId: 0) // Choose a unique typeId for each TypeAdapter
class GameDifficulty {
  @HiveField(0)
  final Difficulty difficulty;

  GameDifficulty({required this.difficulty});
}
