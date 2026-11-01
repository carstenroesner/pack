import 'script_error.dart';

/// Ein Wort oder ein Text in Anführungszeichen einer Skriptzeile.
class Token {
  const Token(this.text, {this.quoted = false});

  final String text;
  final bool quoted;

  @override
  String toString() => quoted ? '"$text"' : text;
}

/// Zerlegt eine Zeile (ohne Einrückung) in Token.
///
/// - Texte stehen in Anführungszeichen und dürfen Leerzeichen enthalten.
/// - `//` beginnt einen Kommentar bis zum Zeilenende.
/// - Ein Doppelpunkt am Wortende wird als eigenes Token ":" abgetrennt.
List<Token> tokenizeLine(String line, int lineNo) {
  final tokens = <Token>[];
  var i = 0;
  final n = line.length;
  while (i < n) {
    final ch = line[i];
    if (ch == ' ' || ch == '\t' || ch == '\r') {
      i++;
      continue;
    }
    if (ch == '"') {
      final end = line.indexOf('"', i + 1);
      if (end < 0) {
        throw ScriptError('Text in Anführungszeichen ist nicht beendet', lineNo);
      }
      tokens.add(Token(line.substring(i + 1, end), quoted: true));
      i = end + 1;
      continue;
    }
    if (ch == '/' && i + 1 < n && line[i + 1] == '/') {
      break;
    }
    var j = i;
    while (j < n && line[j] != ' ' && line[j] != '\t' && line[j] != '\r' && line[j] != '"') {
      if (line[j] == '/' && j + 1 < n && line[j + 1] == '/') break;
      j++;
    }
    var word = line.substring(i, j);
    var colon = false;
    if (word.length > 1 && word.endsWith(':')) {
      word = word.substring(0, word.length - 1);
      colon = true;
    }
    tokens.add(Token(word));
    if (colon) tokens.add(const Token(':'));
    i = j;
  }
  return tokens;
}

/// Eine nicht leere Quellzeile mit Einrückung.
class SrcLine {
  const SrcLine(this.indent, this.tokens, this.lineNo);

  final int indent;
  final List<Token> tokens;
  final int lineNo;
}

/// Ein Knoten des Einrückungsbaums: eine Zeile mit ihren eingerückten Kindern.
class Node {
  Node(this.line);

  final SrcLine line;
  final List<Node> children = <Node>[];

  List<Token> get tokens => line.tokens;
  int get lineNo => line.lineNo;
}

List<SrcLine> readLines(String source) {
  final result = <SrcLine>[];
  final raw = source.split('\n');
  for (var i = 0; i < raw.length; i++) {
    final text = raw[i];
    var indent = 0;
    var k = 0;
    while (k < text.length && (text[k] == ' ' || text[k] == '\t')) {
      indent += text[k] == '\t' ? 2 : 1;
      k++;
    }
    final tokens = tokenizeLine(text.substring(k), i + 1);
    if (tokens.isEmpty) continue;
    result.add(SrcLine(indent, tokens, i + 1));
  }
  return result;
}

List<Node> buildTree(List<SrcLine> lines) {
  final root = Node(const SrcLine(-1, <Token>[], 0));
  final stack = <Node>[root];
  for (final l in lines) {
    while (stack.length > 1 && stack.last.line.indent >= l.indent) {
      stack.removeLast();
    }
    final node = Node(l);
    stack.last.children.add(node);
    stack.add(node);
  }
  return root.children;
}
