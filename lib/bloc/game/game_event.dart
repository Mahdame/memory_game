part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GameInitialMenu extends GameEvent {}

class ChangeCardThemeEvent extends GameEvent {
  final String cardThemeName;

  ChangeCardThemeEvent({required this.cardThemeName});

  @override
  List<Object> get props => [cardThemeName];
}

class ChangeDifficultyEvent extends GameEvent {
  final GameDifficulty difficulty;

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
