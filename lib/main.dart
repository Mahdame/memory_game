import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memory_game/bloc/medal/medal_bloc.dart';
import 'package:memory_game/config/theme_notifier.dart';
import 'package:memory_game/generate_assets.dart';
import 'package:memory_game/model/game_difficulty.dart';
import 'package:memory_game/model/game_result.dart';
import 'package:memory_game/view/game_screen.dart';
import 'bloc/game/game_bloc.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Generate the asset file list
  generateAssets();

  await Hive.initFlutter();

  Hive.registerAdapter(GameResultAdapter());
  Hive.registerAdapter(GameDifficultyAdapter());

  await Hive.openBox('settingsBox');
  await Hive.openBox('gameResultsBox');
  await Hive.openBox<GameDifficulty>('gameDifficultyBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        BlocProvider(create: (context) => GameBloc()),
        BlocProvider(create: (context) => MedalBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      theme: themeNotifier.currentTheme,
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => GameBloc(),
        child: const GameScreen(),
      ),
    );
  }
}
