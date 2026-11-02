import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../app/game_info.dart';

/// In-App-Ansicht des Funktionsumfangs (spiegelt FUNKTIONSUMFANG.md).
class FeatureOverviewScreen extends StatelessWidget {
  const FeatureOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final info = context.read<GameInfo>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Funktionsumfang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Stand: ${info.featureStand}', style: textTheme.labelMedium),
          const SizedBox(height: 12),
          for (final section in info.featureSections)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title, style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    for (final item in section.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  '),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
