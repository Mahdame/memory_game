part of 'game_bloc.dart';

abstract class GameState extends Equatable {
  @override
  List<Object> get props => [];
}

final class GameInitialState extends GameState {}

class GameDisplayState extends GameState {
  final List<GameCard> cards;
  final int score;
  final int elapsedTime;

  GameDisplayState({required this.cards, required this.score, required this.elapsedTime});

  @override
  List<Object> get props => [cards, score, elapsedTime];
}

class CardFlipState extends GameState {
  final List<GameCard> cards;
  final int flippedCardIndex;

  CardFlipState(this.cards, this.flippedCardIndex);

  @override
  List<Object> get props => [cards, flippedCardIndex];
}

class MatchCheckState extends GameState {
  final List<GameCard> cards;
  final bool isMatch;

  MatchCheckState(this.cards, this.isMatch);

  @override
  List<Object> get props => [cards, isMatch];
}

class GameOverState extends GameState {}

class ScoreboardState extends GameState {
  final List gameResults;

  ScoreboardState(this.gameResults);

  @override
  List<Object> get props => [gameResults];
}
