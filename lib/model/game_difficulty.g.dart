// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_difficulty.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameDifficultyAdapter extends TypeAdapter<GameDifficulty> {
  @override
  final int typeId = 1;

  @override
  GameDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GameDifficulty.easy;
      case 1:
        return GameDifficulty.medium;
      case 2:
        return GameDifficulty.hard;
      default:
        return GameDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, GameDifficulty obj) {
    switch (obj) {
      case GameDifficulty.easy:
        writer.writeByte(0);
        break;
      case GameDifficulty.medium:
        writer.writeByte(1);
        break;
      case GameDifficulty.hard:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
