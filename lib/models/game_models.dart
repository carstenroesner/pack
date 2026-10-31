import 'package:flutter/material.dart';

/// Die vier Aktionen der Verb-Leiste.
enum Verb { look, take, use, talk }

extension VerbLabel on Verb {
  String get label {
    switch (this) {
      case Verb.look:
        return 'Ansehen';
      case Verb.take:
        return 'Nehmen';
      case Verb.use:
        return 'Benutzen';
      case Verb.talk:
        return 'Reden';
    }
  }
}

/// Ein Gegenstand, der ins Inventar wandern kann.
class GameItem {
  const GameItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
}

/// Eine anklickbare Stelle in einer Szene. Koordinaten sind Anteile (0..1)
/// der Szenenfläche.
class Hotspot {
  const Hotspot({
    required this.id,
    required this.scene,
    required this.label,
    required this.emoji,
    required this.x,
    required this.y,
    required this.lookText,
    this.requiresFlag,
    this.hiddenByFlag,
  });

  final String id;
  final String scene;
  final String label;
  final String emoji;
  final double x;
  final double y;
  final String lookText;

  /// Hotspot ist nur sichtbar, wenn dieses Flag gesetzt ist.
  final String? requiresFlag;

  /// Hotspot verschwindet, sobald dieses Flag gesetzt ist.
  final String? hiddenByFlag;
}

/// Regel: Was passiert, wenn ein Verb oder ein Inventar-Gegenstand auf einen
/// Hotspot angewendet wird. Die erste passende Regel gewinnt.
///
/// - [item] gesetzt: Regel gilt für "Gegenstand auf Hotspot benutzen".
/// - [item] null und [verb] gesetzt: Regel gilt für genau dieses Verb.
/// - [item] und [verb] null: Regel gilt für jedes Verb außer "Ansehen"
///   (praktisch für Türen und Ausgänge).
class Interaction {
  const Interaction({
    required this.hotspot,
    required this.text,
    this.verb,
    this.item,
    this.requiresFlag,
    this.requiresNotFlag,
    this.giveItem,
    this.consumeItem = false,
    this.setFlag,
    this.gotoScene,
    this.startDialog,
    this.ends = false,
  });

  final String hotspot;
  final String text;
  final Verb? verb;
  final String? item;
  final String? requiresFlag;
  final String? requiresNotFlag;
  final String? giveItem;
  final bool consumeItem;
  final String? setFlag;
  final String? gotoScene;
  final String? startDialog;
  final bool ends;
}

class DialogOption {
  const DialogOption({required this.text, this.next, this.setFlag});

  final String text;

  /// Nächster Dialogknoten; null beendet das Gespräch.
  final String? next;
  final String? setFlag;
}

class DialogNode {
  const DialogNode({
    required this.speaker,
    required this.line,
    required this.options,
  });

  final String speaker;
  final String line;
  final List<DialogOption> options;
}

class SceneData {
  const SceneData({
    required this.id,
    required this.name,
    required this.skyTop,
    required this.skyBottom,
    required this.ground,
    this.hasMoon = false,
  });

  final String id;
  final String name;
  final Color skyTop;
  final Color skyBottom;
  final Color ground;
  final bool hasMoon;
}
