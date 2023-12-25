import 'package:hive/hive.dart';

part 'game_result.g.dart'; // This file will be generated

@HiveType(typeId: 0) // Choose a unique typeId for each TypeAdapter
class GameResult {
  @HiveField(0)
  final int? score;

  @HiveField(1)
  final int? elapsedTime;

  GameResult({this.score, this.elapsedTime});
}
