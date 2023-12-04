part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GameInitialMenu extends GameEvent {}

class ChangeThemeEvent extends GameEvent {
  final String themeName;

  ChangeThemeEvent({required this.themeName});

  @override
  List<Object> get props => [themeName];
}

class ChangeDifficultyEvent extends GameEvent {
  final Difficulty difficulty;

  ChangeDifficultyEvent({required this.difficulty});

  @override
  List<Object> get props => [difficulty];
}

class GameStartEvent extends GameEvent {}

class TimerTickEvent extends GameEvent {
  final int elapsedTime;

  TimerTickEvent(this.elapsedTime);

  @override
  List<Object> get props => [elapsedTime];
}

class FlipCardEvent extends GameEvent {
  final int cardIndex;

  FlipCardEvent(this.cardIndex);

  @override
  List<Object> get props => [cardIndex];
}

class CheckMatchEvent extends GameEvent {
  final int firstCardIndex;
  final int secondCardIndex;

  CheckMatchEvent(this.firstCardIndex, this.secondCardIndex);

  @override
  List<Object> get props => [firstCardIndex, secondCardIndex];
}

class ResetGameEvent extends GameEvent {}

class GameOverEvent extends GameEvent {}

class ScoreboardEvent extends GameEvent {}
