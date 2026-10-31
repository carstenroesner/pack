import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/game_screen.dart';
import 'services/game_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AdventureApp());
}

class AdventureApp extends StatelessWidget {
  const AdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Knarz Manor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const GameScreen(),
      ),
    );
  }
}
