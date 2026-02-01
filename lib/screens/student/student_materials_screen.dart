import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../widgets/evalis_app_bar.dart';

class StudentMaterialsScreen extends StatelessWidget {
  const StudentMaterialsScreen({super.key});

  static const routeName = '/student/materials';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.materialsTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: pastMaterials.length,
        itemBuilder: (context, index) {
          final material = pastMaterials[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(material.topic, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: [
                        Chip(label: Text(material.duration)),
                        Chip(label: Text(material.difficulty)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
