import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/engine.dart';
import '../engine/script_parser.dart';
import '../screens/game_screen.dart';
import '../services/game_settings.dart';
import '../theme/app_theme.dart';
import 'game_info.dart';

/// Die fertige App-Hülle: lädt ein Spiel aus seinem Skripttext und zeigt es an.
class PackApp extends StatefulWidget {
  const PackApp({
    super.key,
    required this.info,
    required this.source,
    required this.settings,
  });

  final GameInfo info;
  final String source;
  final GameSettings settings;

  @override
  State<PackApp> createState() => _PackAppState();
}

class _PackAppState extends State<PackApp> {
  late final GameEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine(parseGame(widget.source));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<GameInfo>.value(value: widget.info),
        ChangeNotifierProvider<GameEngine>.value(value: _engine),
        ChangeNotifierProvider<GameSettings>.value(value: widget.settings),
      ],
      child: MaterialApp(
        title: widget.info.title,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const GameScreen(),
      ),
    );
  }
}
