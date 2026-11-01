import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'engine/engine.dart';
import 'engine/script_parser.dart';
import 'screens/game_screen.dart';
import 'services/game_settings.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final source = await rootBundle.loadString('assets/game/knarz.scr');
  final settings = GameSettings();
  await settings.load();
  runApp(AdventureApp(source: source, settings: settings));
}

class AdventureApp extends StatefulWidget {
  const AdventureApp({super.key, required this.source, required this.settings});

  final String source;
  final GameSettings settings;

  @override
  State<AdventureApp> createState() => _AdventureAppState();
}

class _AdventureAppState extends State<AdventureApp> {
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
        ChangeNotifierProvider<GameEngine>.value(value: _engine),
        ChangeNotifierProvider<GameSettings>.value(value: widget.settings),
      ],
      child: MaterialApp(
        title: 'Knarz Manor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const GameScreen(),
      ),
    );
  }
}
