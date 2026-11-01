import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/engine.dart';
import '../widgets/action_panel.dart';
import '../widgets/app_menu.dart';
import '../widgets/scene_view.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    return Scaffold(
      appBar: AppBar(
        title: Text(engine.room.name),
        actions: const [AppMenu()],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final panelHeight = (constraints.maxHeight * 0.36).clamp(180.0, 300.0).toDouble();
            return Column(
              children: [
                const Expanded(child: SceneView()),
                SizedBox(height: panelHeight, child: const ActionPanel()),
              ],
            );
          },
        ),
      ),
    );
  }
}
