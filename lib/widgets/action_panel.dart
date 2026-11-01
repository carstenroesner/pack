import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/engine.dart';
import '../engine/game_data.dart';

const Color _panelBg = Color(0xFF0B0714);
const Color _verbColor = Color(0xFF3DDC84);
const Color _verbActive = Color(0xFFFFFF55);
const Color _sentenceColor = Color(0xFF55FFFF);
const Color _itemColor = Color(0xFFFF66FF);

TextStyle _style(Color c, {double size = 14}) => TextStyle(
      color: c,
      fontSize: size,
      fontWeight: FontWeight.w800,
      fontFamily: 'monospace',
      height: 1.15,
    );

/// Der untere Bereich im Stil der klassischen Adventures: Satzzeile,
/// Verbtafel und Inventar. Bei Dialogen zeigt er stattdessen die Antworten.
class ActionPanel extends StatelessWidget {
  const ActionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    Widget body;
    if (engine.finished) {
      body = _Ending(text: engine.endingText);
    } else if (engine.choices != null) {
      body = const _Choices();
    } else if (engine.busy) {
      body = const SizedBox.expand();
    } else {
      body = const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: _VerbGrid()),
          SizedBox(width: 8),
          Expanded(flex: 5, child: _InventoryList()),
        ],
      );
    }
    return Container(
      color: _panelBg,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Column(
        children: [
          SizedBox(
            height: 24,
            child: Center(
              child: Text(
                engine.sentence,
                key: const ValueKey('sentence'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _style(_sentenceColor, size: 16),
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _VerbGrid extends StatelessWidget {
  const _VerbGrid();

  static const int _rows = 4;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final verbs = engine.game.verbs;
    final cols = (verbs.length / _rows).ceil();
    return Row(
      children: [
        for (var c = 0; c < cols; c++)
          Expanded(
            child: Column(
              children: [
                for (var r = 0; r < _rows; r++)
                  Expanded(
                    child: c * _rows + r < verbs.length
                        ? _VerbButton(verb: verbs[c * _rows + r])
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _VerbButton extends StatelessWidget {
  const _VerbButton({required this.verb});

  final VerbDef verb;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final active = engine.verbId == verb.id;
    return InkWell(
      key: ValueKey('verb_${verb.id}'),
      onTap: () => context.read<GameEngine>().selectVerb(verb.id),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(verb.label, style: _style(active ? _verbActive : _verbColor)),
        ),
      ),
    );
  }
}

class _InventoryList extends StatefulWidget {
  const _InventoryList();

  @override
  State<_InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<_InventoryList> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _by(double delta) {
    if (!_scroll.hasClients) return;
    final target = (_scroll.offset + delta).clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.animateTo(
      target.toDouble(),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final inv = engine.inventory;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            IconButton(
              key: const ValueKey('inv_up'),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: const Icon(Icons.arrow_drop_up, color: _itemColor),
              onPressed: () => _by(-40),
            ),
            IconButton(
              key: const ValueKey('inv_down'),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: const Icon(Icons.arrow_drop_down, color: _itemColor),
              onPressed: () => _by(40),
            ),
          ],
        ),
        Expanded(
          child: inv.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Nichts dabei', style: _style(const Color(0xFF7A5A7A), size: 12)),
                )
              : ListView(
                  controller: _scroll,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final id in inv)
                      InkWell(
                        key: ValueKey('item_$id'),
                        onTap: () => context.read<GameEngine>().target(id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            engine.nameOf(id),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _style(
                              engine.firstId == id ? _verbActive : _itemColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Choices extends StatelessWidget {
  const _Choices();

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final opts = engine.choices ?? const [];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (var i = 0; i < opts.length; i++)
          InkWell(
            key: ValueKey('choice_$i'),
            onTap: () => context.read<GameEngine>().chooseOption(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(opts[i].text, style: _style(_itemColor, size: 15)),
            ),
          ),
      ],
    );
  }
}

class _Ending extends StatelessWidget {
  const _Ending({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(text, style: _style(_verbActive, size: 14)),
          ),
        ),
        const SizedBox(height: 6),
        FilledButton(
          key: const ValueKey('restart'),
          onPressed: () => context.read<GameEngine>().newGame(),
          child: const Text('Neu starten'),
        ),
      ],
    );
  }
}
