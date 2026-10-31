import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/feature_overview_screen.dart';

const String _repoOwner = 'carstenroesner';
const String _repoName = 'point_and_click_adventure';

/// Standard-Menü (⋮): Funktionsumfang, Problem melden, Über diese App.
class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menü',
      onSelected: (value) {
        switch (value) {
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
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'features', child: Text('Funktionsumfang')),
        PopupMenuItem(value: 'report', child: Text('Problem melden')),
        PopupMenuItem(value: 'about', child: Text('Über diese App')),
      ],
    );
  }
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Über Knarz Manor'),
      content: Text(
        'Ein Point-and-Click-Adventure im Halloween-Spukhaus.\n\n'
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
    final uri = Uri.https(
      'github.com',
      '/$_repoOwner/$_repoName/issues/new',
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
