import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../services/resource_service.dart';
import '../../widgets/evalis_app_bar.dart';

class LecturerResourcesScreen extends StatelessWidget {
  const LecturerResourcesScreen({super.key});

  static const routeName = '/lecturer/resources';

  @override
  Widget build(BuildContext context) {
    final resourceService = ResourceService();
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.resourcesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          resourceService.addResource();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(context.t(AppText.addedResource))));
        },
        icon: const Icon(Icons.add_circle_outline),
        label: Text(context.t(AppText.addResource)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockResources.length,
        itemBuilder: (context, index) {
          final resource = mockResources[index];
          final accent = Theme.of(context).colorScheme.secondary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.folder_open_rounded, color: accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(resource.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              Text(resource.description,
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: [
                        Chip(label: Text(resource.format)),
                        Chip(label: Text(resource.eta)),
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
