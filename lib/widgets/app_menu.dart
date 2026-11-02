import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/game_info.dart';
import '../engine/engine.dart';
import '../screens/feature_overview_screen.dart';
import '../services/game_settings.dart';


/// Standard-Menü (⋮): Funktionsumfang, Problem melden, Über diese App.
class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  Future<void> _save(BuildContext context) async {
    final engine = context.read<GameEngine>();
    final saveKey = '${context.read<GameInfo>().storageKey}_savegame';
    final messenger = ScaffoldMessenger.of(context);
    if (!engine.canSave) {
      messenger.showSnackBar(const SnackBar(content: Text('Gerade nicht möglich.')));
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(saveKey, jsonEncode(engine.toJson()));
      messenger.showSnackBar(const SnackBar(content: Text('Gespeichert.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Speichern ist fehlgeschlagen.')));
    }
  }

  Future<void> _load(BuildContext context) async {
    final engine = context.read<GameEngine>();
    final saveKey = '${context.read<GameInfo>().storageKey}_savegame';
    final messenger = ScaffoldMessenger.of(context);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(saveKey);
      if (raw == null) {
        messenger.showSnackBar(const SnackBar(content: Text('Kein Spielstand vorhanden.')));
        return;
      }
      final ok = engine.loadJson(jsonDecode(raw) as Map<String, dynamic>);
      messenger.showSnackBar(
        SnackBar(content: Text(ok ? 'Spielstand geladen.' : 'Spielstand passt nicht zum Spiel.')),
      );
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Laden ist fehlgeschlagen.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = context.watch<GameSettings>().retro;
    return PopupMenuButton<String>(
      tooltip: 'Menü',
      onSelected: (value) {
        switch (value) {
          case 'save':
            _save(context);
            break;
          case 'load':
            _load(context);
            break;
          case 'restart':
            context.read<GameEngine>().newGame();
            break;
          case 'retro':
            context.read<GameSettings>().toggleRetro();
            break;
          case 'features':
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const FeatureOverviewScreen(),
              ),
            );
            break;
          case 'report':
            showDialog<void>(
              context: context,
              builder: (_) => const _ReportDialog(),
            );
            break;
          case 'about':
            showDialog<void>(
              context: context,
              builder: (_) => const _AboutDialog(),
            );
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'save', child: Text('Spiel speichern')),
        const PopupMenuItem(value: 'load', child: Text('Spiel laden')),
        const PopupMenuItem(value: 'restart', child: Text('Neu starten')),
        PopupMenuItem(
          value: 'retro',
          child: Text(retro ? 'Retro-Ansicht: aus' : 'Retro-Ansicht: an'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'features', child: Text('Funktionsumfang')),
        const PopupMenuItem(value: 'report', child: Text('Problem melden')),
        const PopupMenuItem(value: 'about', child: Text('Über diese App')),
      ],
    );
  }
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    final info = context.read<GameInfo>();
    return AlertDialog(
      title: Text('Über ${info.title}'),
      content: Text(
        '${info.about}\n\n'
        '© ${DateTime.now().year} Carsten Rösner',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  bool _isProblem = true;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _openIssue() async {
    final navigator = Navigator.of(context);
    final info = context.read<GameInfo>();
    final uri = Uri.https(
      'github.com',
      '/${info.repoOwner}/${info.repoName}/issues/new',
      {
        'title': _title.text.trim(),
        'body': _body.text.trim(),
        'labels': _isProblem ? 'bug' : 'enhancement',
      },
    );
    navigator.pop();
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Problem melden'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Problem')),
                ButtonSegment(value: false, label: Text('Anregung')),
              ],
              selected: {_isProblem},
              onSelectionChanged: (s) => setState(() => _isProblem = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titel'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _body,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Beschreibung'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _openIssue,
          child: const Text('Issue öffnen'),
        ),
      ],
    );
  }
}
