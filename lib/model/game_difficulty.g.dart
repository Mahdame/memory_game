// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_difficulty.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameDifficultyAdapter extends TypeAdapter<GameDifficulty> {
  @override
  final int typeId = 0;

  @override
  GameDifficulty read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameDifficulty(
      difficulty: fields[0] as Difficulty,
    );
  }

  @override
  void write(BinaryWriter writer, GameDifficulty obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.difficulty);
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
