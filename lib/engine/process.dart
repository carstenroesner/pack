import 'ast.dart';

enum WaitKind { none, time, speech, walk, choice }

/// Ein Block auslaufender Anweisungen auf dem Stapel eines Skripts.
class Frame {
  Frame(this.stmts, {this.dialogId, this.onExit});

  final List<Stmt> stmts;

  /// Gesetzt, wenn dieser Block ein Dialogthema ist.
  final String? dialogId;
  final void Function()? onExit;
  int index = 0;
}

/// Ein laufendes Skript. Mehrere Skripte laufen kooperativ nebeneinander und
/// geben mit Wartebefehlen (sage, warte, gehe) die Kontrolle ab.
class ScriptProcess {
  ScriptProcess(List<Stmt> body, {this.contextObject}) {
    frames.add(Frame(body));
  }

  /// Das Objekt, auf dem die Aktion ausgeführt wird ("verstecke" ohne Id).
  final String? contextObject;
  final List<Frame> frames = <Frame>[];
  WaitKind wait = WaitKind.none;
  double timeLeft = 0;
  int cutscene = 0;
  bool fast = false;
  bool done = false;

  Stmt? next() {
    while (frames.isNotEmpty) {
      final f = frames.last;
      if (f.index < f.stmts.length) return f.stmts[f.index++];
      frames.removeLast();
      f.onExit?.call();
    }
    return null;
  }
}
