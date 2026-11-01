/// Ein Bedingungsbestandteil: Flag oder Gegenstand im Inventar, optional verneint.
class CondTerm {
  const CondTerm(this.name, {this.item = false, this.negate = false});

  final String name;
  final bool item;
  final bool negate;
}

/// Alle Bestandteile müssen zutreffen (UND). Leer heißt: immer wahr.
class Cond {
  const Cond(this.terms);

  final List<CondTerm> terms;

  static const Cond always = Cond(<CondTerm>[]);

  bool get isAlways => terms.isEmpty;
}

sealed class Stmt {
  const Stmt();
}

/// Sprechblase. [actor] null steht für die Spielfigur.
class Say extends Stmt {
  const Say(this.actor, this.text);

  final String? actor;
  final String text;
}

class Pause extends Stmt {
  const Pause(this.seconds);

  final double seconds;
}

class GiveItem extends Stmt {
  const GiveItem(this.item);

  final String item;
}

class RemoveItem extends Stmt {
  const RemoveItem(this.item);

  final String item;
}

class SetFlag extends Stmt {
  const SetFlag(this.name, this.value);

  final String name;
  final bool value;
}

class If extends Stmt {
  const If(this.cond, this.then, this.otherwise);

  final Cond cond;
  final List<Stmt> then;
  final List<Stmt> otherwise;
}

/// Die Spielfigur geht zu einer Marke des aktuellen Raums.
class WalkMark extends Stmt {
  const WalkMark(this.mark);

  final String mark;
}

/// Intern: Die Spielfigur geht zu einem Objekt im Raum.
class WalkObject extends Stmt {
  const WalkObject(this.objectId);

  final String objectId;
}

class GotoRoom extends Stmt {
  const GotoRoom(this.room, this.mark);

  final String room;
  final String? mark;
}

/// Objekt ein- oder ausblenden. [id] null steht für das aktuelle Objekt.
class ShowHide extends Stmt {
  const ShowHide(this.show, this.id);

  final bool show;
  final String? id;
}

class StartDialog extends Stmt {
  const StartDialog(this.dialogId);

  final String dialogId;
}

class ChoiceOption {
  const ChoiceOption(this.text, this.cond, this.body);

  final String text;
  final Cond cond;
  final List<Stmt> body;
}

class Choice extends Stmt {
  const Choice(this.options);

  final List<ChoiceOption> options;
}

/// Springt innerhalb eines Dialogs zu einem anderen Thema.
class Jump extends Stmt {
  const Jump(this.topic);

  final String topic;
}

class EndDialog extends Stmt {
  const EndDialog();
}

/// Zwischensequenz: kann übersprungen werden.
class Cutscene extends Stmt {
  const Cutscene(this.body);

  final List<Stmt> body;
}

class EndGame extends Stmt {
  const EndGame(this.text);

  final String text;
}

class RunScript extends Stmt {
  const RunScript(this.name);

  final String name;
}

/// Durchläuft alle Anweisungen samt verschachtelter Blöcke.
void forEachStmt(List<Stmt> list, void Function(Stmt) visit) {
  for (final s in list) {
    visit(s);
    if (s is If) {
      forEachStmt(s.then, visit);
      forEachStmt(s.otherwise, visit);
    } else if (s is Choice) {
      for (final o in s.options) {
        forEachStmt(o.body, visit);
      }
    } else if (s is Cutscene) {
      forEachStmt(s.body, visit);
    }
  }
}
