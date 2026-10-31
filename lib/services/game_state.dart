import 'package:flutter/foundation.dart';

import '../content/game_content.dart';
import '../models/game_models.dart';

/// Zentraler Spielzustand (Szene, Inventar, Flags, Dialog).
class GameState extends ChangeNotifier {
  String sceneId = 'garden';
  final Set<String> flags = <String>{};
  final List<String> inventory = <String>[];
  Verb verb = Verb.look;
  String? selectedItem;
  String message = introText;
  String? dialogId;
  bool finished = false;

  SceneData get scene => scenes[sceneId]!;

  DialogNode? get dialogNode => dialogId == null ? null : dialogs[dialogId];

  bool hasFlag(String flag) => flags.contains(flag);

  List<Hotspot> get visibleHotspots => hotspots.where((h) {
        if (h.scene != sceneId) return false;
        if (h.requiresFlag != null && !flags.contains(h.requiresFlag)) {
          return false;
        }
        if (h.hiddenByFlag != null && flags.contains(h.hiddenByFlag)) {
          return false;
        }
        return true;
      }).toList();

  void restart() {
    sceneId = 'garden';
    flags.clear();
    inventory.clear();
    verb = Verb.look;
    selectedItem = null;
    message = introText;
    dialogId = null;
    finished = false;
    notifyListeners();
  }

  void setVerb(Verb newVerb) {
    if (finished || dialogId != null) return;
    verb = newVerb;
    selectedItem = null;
    notifyListeners();
  }

  /// Tippen auf einen Inventar-Gegenstand: im Modus "Ansehen" beschreiben,
  /// sonst als Gegenstand für "Benutzen mit ..." auswählen bzw. abwählen.
  void tapItem(String itemId) {
    if (finished || dialogId != null) return;
    final item = items[itemId];
    if (item == null || !inventory.contains(itemId)) return;
    if (verb == Verb.look && selectedItem == null) {
      message = item.description;
    } else if (selectedItem == itemId) {
      selectedItem = null;
    } else {
      selectedItem = itemId;
      verb = Verb.use;
    }
    notifyListeners();
  }

  void tapHotspot(Hotspot hotspot) {
    if (finished || dialogId != null) return;
    final item = selectedItem;
    final match = _findInteraction(hotspot.id, item);
    if (match != null) {
      _apply(match);
      return;
    }
    if (item != null) {
      message = 'Mit ${items[item]!.name} lässt sich hier nichts anfangen.';
      selectedItem = null;
    } else {
      switch (verb) {
        case Verb.look:
          message = hotspot.lookText;
          break;
        case Verb.take:
          message = 'Das kannst du nicht mitnehmen.';
          break;
        case Verb.use:
          message = 'Damit lässt sich nichts anfangen.';
          break;
        case Verb.talk:
          message = '${hotspot.label} antwortet nicht.';
          break;
      }
    }
    notifyListeners();
  }

  void chooseDialogOption(int index) {
    final node = dialogNode;
    if (node == null || index < 0 || index >= node.options.length) return;
    final option = node.options[index];
    if (option.setFlag != null) flags.add(option.setFlag!);
    dialogId = option.next;
    if (option.next == null) {
      message = 'Das Gespräch ist beendet.';
    }
    notifyListeners();
  }

  Interaction? _findInteraction(String hotspotId, String? item) {
    for (final rule in interactions) {
      if (rule.hotspot != hotspotId) continue;
      if (rule.requiresFlag != null && !flags.contains(rule.requiresFlag)) {
        continue;
      }
      if (rule.requiresNotFlag != null && flags.contains(rule.requiresNotFlag)) {
        continue;
      }
      if (item != null) {
        if (rule.item == item) return rule;
      } else if (rule.item == null) {
        if (rule.verb == verb || (rule.verb == null && verb != Verb.look)) {
          return rule;
        }
      }
    }
    return null;
  }

  void _apply(Interaction rule) {
    message = rule.text;
    if (rule.consumeItem && rule.item != null) {
      inventory.remove(rule.item);
    }
    if (rule.giveItem != null && !inventory.contains(rule.giveItem)) {
      inventory.add(rule.giveItem!);
    }
    if (rule.setFlag != null) flags.add(rule.setFlag!);
    if (rule.gotoScene != null) sceneId = rule.gotoScene!;
    if (rule.startDialog != null) dialogId = rule.startDialog;
    if (rule.ends) finished = true;
    if (rule.item != null) selectedItem = null;
    notifyListeners();
  }
}
