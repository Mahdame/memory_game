import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:memory_game/asset_files.dart';
import 'package:memory_game/model/game_card.dart';
import 'package:memory_game/model/game_difficulty.dart';
import 'package:memory_game/model/game_result.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  List<GameCard>? cards; // List of all game cards
  List<int> selectedCardsIndices = []; // Indices of selected cards
  List<int> matchedCardsIndices = []; // Indices of matched cards
  Timer? _gameTimer;
  int _elapsedTime = 0; // Time in seconds
  int _score = 0;
  int get score => _score;
  int get elapsedTime => _elapsedTime;
  int finalScore = 0;
  int finalTime = 0;

  GameBloc({this.cards}) : super(GameInitialState()) {
    on<GameInitialMenu>(_onGameMenu);
    on<ChangeThemeEvent>(_onChangeTheme);
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

  void _onGameStarted(GameStartEvent event, Emitter<GameState> emit) {
    // Retrieve the saved theme from the settings box
    var box = Hive.box('settingsBox');
    String savedTheme = box.get('selectedTheme', defaultValue: 'amongus');

    // Initialize the cards with the chosen theme
    List<String> imagePaths = GeneratedAssets.allLists[savedTheme] ?? [];
    cards = _initializeCardsWithTheme(imagePaths);

    // Reset any other game-related state if needed
    selectedCardsIndices.clear();
    matchedCardsIndices.clear();

    _startTimer();

    // Emit the state to display the game with initialized cards
    emit(GameDisplayState(cards: cards!, score: _score, elapsedTime: _elapsedTime));
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
    var box = Hive.box('gameResultsBox');
    List results = box.get('results', defaultValue: []);
    finalScore = _score;
    finalTime = _elapsedTime;
    results.add(GameResult(score: finalScore, elapsedTime: finalTime));
    await box.put('results', results);

    // Stop the timer
    _gameTimer?.cancel();

    emit(GameOverState());
  }

  Future<void> _onScoreboardEvent(ScoreboardEvent event, Emitter<GameState> emit) async {
    var box = Hive.box('gameResultsBox');
    if (box.get('results') == null || box.get('results').isEmpty) {
      GameResult result = GameResult(score: 0, elapsedTime: 0);
      await box.put('results', [result]);
      List results = box.get('results', defaultValue: []);
      results.sort((a, b) => b.score.compareTo(a.score));
      emit(ScoreboardState(results));
    } else {
      List results = box.get('results', defaultValue: []);
      results.sort((a, b) => b.score.compareTo(a.score));
      emit(ScoreboardState(results));
    }
  }

  void _onResetGameEvent(ResetGameEvent event, Emitter<GameState> emit) {
    // Reset all states and lists
    selectedCardsIndices.clear();
    matchedCardsIndices.clear();

    _score = 0;
    _elapsedTime = 0;
    _gameTimer?.cancel();

    emit(GameInitialState());
  }

  Future<void> _onChangeDifficulty(ChangeDifficultyEvent event, Emitter<GameState> emit) async {
    var box = Hive.box('settingsBox');
    await box.put('gameDifficulty', event.difficulty);

    List<String> selectedImageSet = Difficulty.values[event.difficulty.index] == Difficulty.easy
        ? _getShuffledImagesForDifficulty(12)
        : Difficulty.values[event.difficulty.index] == Difficulty.medium
            ? _getShuffledImagesForDifficulty(16)
            : _getShuffledImagesForDifficulty(20);

    // Initialize new cards with the selected image set
    cards = _initializeCardsWithTheme(selectedImageSet);
    emit(GameDisplayState(cards: cards!, score: _score, elapsedTime: _elapsedTime));
  }

  List<String> _getShuffledImagesForDifficulty(int cardCount) {
    // Retrieve the saved theme from the settings box
    var box = Hive.box('settingsBox');
    String savedTheme = box.get('selectedTheme', defaultValue: 'amongus');

    // Initialize the cards with the chosen theme
    List<String> imagePaths = GeneratedAssets.allLists[savedTheme] ?? [];
    cards = _initializeCardsWithTheme(imagePaths);

    // Check if there are enough images for the difficulty
    assert(imagePaths.length >= cardCount ~/ 2, 'Não há imagens suficientes para o nível selecionado.');

    Random random = Random();
    List<String> selectedImages = [];

    // Select random images from the list of images
    while (selectedImages.length < cardCount ~/ 2) {
      var randomImage = imagePaths[random.nextInt(imagePaths.length)];
      if (!selectedImages.contains(randomImage)) {
        selectedImages.add(randomImage);
      }
    }

    // Duplicate the selected images to create matching pairs
    selectedImages.addAll(selectedImages);
    selectedImages.shuffle();

    return selectedImages;
  }

  Future<void> _onChangeTheme(ChangeThemeEvent event, Emitter<GameState> emit) async {
    var box = Hive.box('settingsBox');
    await box.put('selectedTheme', event.themeName);

    // Retrieve the specific list of images based on the setName property
    List<String> selectedImageSet = GeneratedAssets.allLists[event.themeName] ?? [];

    // Initialize new cards with the selected image set
    cards = _initializeCardsWithTheme(selectedImageSet);
    emit(GameDisplayState(cards: cards!, score: _score, elapsedTime: _elapsedTime));
  }

  List<GameCard> _initializeCardsWithTheme(List<String> imagePaths) {
    List<GameCard> newCards = [];

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
}
