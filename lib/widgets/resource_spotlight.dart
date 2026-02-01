import 'package:flutter/material.dart';

import '../app_settings.dart';
import '../l10n/app_texts.dart';
import '../screens/lecturer/lecturer_resources_screen.dart';

class ResourceSpotlight extends StatelessWidget {
  const ResourceSpotlight({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t(AppText.resourcesSubtitle),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, LecturerResourcesScreen.routeName),
                    child: Text(context.t(AppText.addResource)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.auto_awesome, size: 48),
          ],
        ),
      ),
    );
  }
}
