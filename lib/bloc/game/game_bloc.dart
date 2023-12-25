import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:memory_game/asset_files.dart';
import 'package:memory_game/model/game_difficulty.dart';
import 'package:memory_game/model/game_card.dart';
import 'package:memory_game/model/game_result.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final log = Logger();

  List<GameCard>? cards; // List of all game cards
  List<int> selectedCardsIndices = []; // Indices of selected cards
  List<int> matchedCardsIndices = []; // Indices of matched cards
  Timer? _gameTimer;
  int _elapsedTime = 0; // Time in seconds
  int _score = 0;
  String get score => _score == 0 ? "0" : "❤️" * _score;
  int get elapsedTime => _elapsedTime;
  int finalScore = 0;
  int finalTime = 0;

  List<GameResult> gameResults = [];

  GameBloc({this.cards}) : super(GameInitialState()) {
    on<GameInitialMenu>(_onGameMenu);
    on<ChangeCardThemeEvent>(_onChangeCardTheme);
    on<ChangeDifficultyEvent>(_onChangeDifficulty);
    on<GameStartEvent>(_onGameStarted);
    on<TimerTickEvent>(_onTimerTick);
    on<FlipCardEvent>(_onFlipCardEvent);
    on<CheckMatchEvent>(_onCheckMatchEvent);
    on<ResetGameEvent>(_onResetGameEvent);
    on<GameOverEvent>(_onGameOver);
    on<ScoreboardEvent>(_onScoreboardEvent);
  }

  void _onGameMenu(GameInitialMenu event, Emitter<GameState> emit) {
    _gameTimer?.cancel();

    emit(GameInitialState());
  }

  void _onTimerTick(TimerTickEvent event, Emitter<GameState> emit) {
    _elapsedTime = event.elapsedTime;
    emit(GameDisplayState(cards: cards!, score: _score, elapsedTime: _elapsedTime));
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Dispatch an event instead of directly emitting a state
      add(TimerTickEvent(_elapsedTime + 1));
    });
  }

  Future<void> _onChangeDifficulty(ChangeDifficultyEvent event, Emitter<GameState> emit) async {
    var savedTheme = Hive.box('settingsBox').get('selectedTheme', defaultValue: 'amongus');
    await Hive.box<GameDifficulty>('gameDifficultyBox').put('difficulty', event.difficulty);

    List<String> imagePaths = GeneratedAssets.allLists[savedTheme] ?? [];

    cards = await _initializeCards(imagePaths, event.difficulty);
    emit(GameDisplayState(cards: cards!, score: _score, elapsedTime: _elapsedTime));
  }

  Future<void> _onChangeCardTheme(ChangeCardThemeEvent event, Emitter<GameState> emit) async {
    var difficulty = Hive.box<GameDifficulty>('gameDifficultyBox').get('difficulty');
    await Hive.box('settingsBox').put('selectedTheme', event.cardThemeName);

    List<String> selectedImageSet = GeneratedAssets.allLists[event.cardThemeName] ?? [];

    cards = await _initializeCards(selectedImageSet, difficulty ?? GameDifficulty.easy);

    emit(GameDisplayState(cards: cards!, score: _score, elapsedTime: _elapsedTime));
  }

  Future<List<GameCard>> _initializeCards(List<String> imagePaths, GameDifficulty difficulty) async {
    List<GameCard> newCards = [];
    int numberOfCards = difficulty.numberOfCards;

    if (imagePaths.length < GameDifficulty.easy.numberOfCards) {
      log.w('Não há imagens suficientes para o nível ${difficulty.description}.');
      await Hive.box('settingsBox').put('selectedTheme', 'amongus');
      await Hive.box<GameDifficulty>('gameDifficultyBox').put('difficulty', difficulty);
      return [];
    }

    if (imagePaths.length < numberOfCards ~/ 2) {
      log.w('Não há imagens suficientes para o nível ${difficulty.description}.');
      numberOfCards = GameDifficulty.easy.numberOfCards;
    }

    imagePaths = imagePaths.sublist(0, numberOfCards ~/ 2);

    // Create pairs of matching cards
    for (var imagePath in imagePaths) {
      var card1 = GameCard(
        content: imagePath,
        isFlipped: false,
        isMatched: false,
      );
      var card2 = GameCard(
        content: imagePath, // Duplicate for matching
        isFlipped: false,
        isMatched: false,
      );

      newCards.add(card1);
      newCards.add(card2);
    }

    // Shuffle the cards for randomness
    newCards.shuffle();

    return newCards;
  }

  Future<void> _onGameStarted(GameStartEvent event, Emitter<GameState> emit) async {
    var savedTheme = Hive.box('settingsBox').get('selectedTheme', defaultValue: 'amongus');
    var difficulty = Hive.box<GameDifficulty>('gameDifficultyBox').get('difficulty');

    // Initialize the cards with the chosen theme
    List<String> imagePaths = GeneratedAssets.allLists[savedTheme] ?? [];
    cards = await _initializeCards(imagePaths, difficulty ?? GameDifficulty.easy);

    add(ResetGameEvent());
  }

  void _onFlipCardEvent(FlipCardEvent event, Emitter<GameState> emit) {
    cards![event.cardIndex] = cards![event.cardIndex].copyWith(isFlipped: true);
    selectedCardsIndices.add(event.cardIndex);

    // Emit state to flip card
    emit(CardFlipState(List.from(cards!), event.cardIndex));

    // Check if two cards are selected to compare
    if (selectedCardsIndices.length == 2) {
      add(CheckMatchEvent(selectedCardsIndices[0], selectedCardsIndices[1]));
    }
  }

  void _onCheckMatchEvent(CheckMatchEvent event, Emitter<GameState> emit) async {
    bool isMatch = cards![event.firstCardIndex].content == cards![event.secondCardIndex].content;

    await Future.delayed(const Duration(milliseconds: 500)); // Wait before checking match

    if (isMatch) {
      matchedCardsIndices.addAll([event.firstCardIndex, event.secondCardIndex]);
      emit(MatchCheckState(List.from(cards!), true));
    } else {
      cards![event.firstCardIndex] = cards![event.firstCardIndex].copyWith(isFlipped: false);
      cards![event.secondCardIndex] = cards![event.secondCardIndex].copyWith(isFlipped: false);
      emit(MatchCheckState(List.from(cards!), false));
    }

    selectedCardsIndices.clear();

    if (isMatch) {
      _score += 1;
    } else {
      // _score -= 1;
      // if (_score < 0) _score = 0;
    }

    // Check for game over
    if (matchedCardsIndices.length == cards!.length) {
      add(GameOverEvent());
    }
  }

  Future<void> _onGameOver(GameOverEvent event, Emitter<GameState> emit) async {
    if (!Hive.box('gameResultsBox').isOpen) await Hive.openBox('gameResultsBox');
    var box = Hive.box('gameResultsBox');
    var results = box.get('results');

    finalScore = _score;
    finalTime = _elapsedTime;

    if (results == null) {
      results = [];
      await box.put('results', results);
    } else {
      results.add(GameResult(score: finalScore, elapsedTime: finalTime));
      await box.put('results', results);
    }

    // Stop the timer
    _gameTimer?.cancel();

    emit(GameOverState());
  }

  Future<void> _onScoreboardEvent(ScoreboardEvent event, Emitter<GameState> emit) async {
    if (!Hive.box('gameResultsBox').isOpen) await Hive.openBox('gameResultsBox');
    var box = Hive.box('gameResultsBox');
    var results = box.get('results');

    if (results == null) {
      results = [];
      await box.put('results', results);
    } else {
      gameResults = results.cast<GameResult>();
    }

    emit(ScoreboardState(gameResults));
  }

  void _onResetGameEvent(ResetGameEvent event, Emitter<GameState> emit) {
    selectedCardsIndices.clear();
    matchedCardsIndices.clear();

    _score = 0;
    _elapsedTime = 0;
    _gameTimer?.cancel();

    _startTimer();

    emit(GameDisplayState(cards: cards!, score: _score, elapsedTime: _elapsedTime));
  }
}
