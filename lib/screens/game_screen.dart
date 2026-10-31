import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/game_content.dart';
import '../models/game_models.dart';
import '../services/game_state.dart';
import '../widgets/app_menu.dart';
import '../widgets/scene_view.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(state.scene.name),
        actions: const [AppMenu()],
      ),
      body: const SafeArea(
        child: Column(
          children: [
            Expanded(child: SceneView()),
            _BottomPanel(),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final scheme = Theme.of(context).colorScheme;

    Widget content;
    if (state.finished) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MessageBox(text: state.message),
          const SizedBox(height: 8),
          FilledButton(
            key: const ValueKey('restart'),
            onPressed: () => context.read<GameState>().restart(),
            child: const Text('Neu starten'),
          ),
        ],
      );
    } else if (state.dialogNode != null) {
      content = _DialogPanel(node: state.dialogNode!);
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MessageBox(
            text: state.selectedItem != null
                ? '${items[state.selectedItem]!.name} benutzen mit ...'
                : state.message,
          ),
          const SizedBox(height: 8),
          const _VerbBar(),
          const SizedBox(height: 4),
          const _InventoryBar(),
        ],
      );
    }

    return Container(
      width: double.infinity,
      color: scheme.surfaceContainer,
      padding: const EdgeInsets.all(8),
      child: content,
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('message'),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(8),
      child: Text(text, maxLines: 6, overflow: TextOverflow.ellipsis),
    );
  }
}

class _VerbBar extends StatelessWidget {
  const _VerbBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      children: [
        for (final v in Verb.values)
          ChoiceChip(
            key: ValueKey('verb_${v.name}'),
            label: Text(v.label),
            selected: state.verb == v && state.selectedItem == null,
            onSelected: (_) => context.read<GameState>().setVerb(v),
          ),
      ],
    );
  }
}

class _InventoryBar extends StatelessWidget {
  const _InventoryBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 70,
      child: state.inventory.isEmpty
          ? const Center(child: Text('Inventar leer'))
          : ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final id in state.inventory)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      key: ValueKey('item_$id'),
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.read<GameState>().tapItem(id),
                      child: Container(
                        width: 84,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: state.selectedItem == id
                                ? scheme.primary
                                : scheme.outlineVariant,
                            width: state.selectedItem == id ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(items[id]!.emoji,
                                style: const TextStyle(fontSize: 26)),
                            Text(
                              items[id]!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _DialogPanel extends StatelessWidget {
  const _DialogPanel({required this.node});

  final DialogNode node;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                node.speaker,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(node.line),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < node.options.length; i++)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: ValueKey('dialog_option_$i'),
                  onPressed: () =>
                      context.read<GameState>().chooseDialogOption(i),
                  child: Text(node.options[i].text),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
