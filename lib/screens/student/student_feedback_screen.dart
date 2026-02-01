import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../widgets/evalis_app_bar.dart';

class StudentFeedbackScreen extends StatelessWidget {
  const StudentFeedbackScreen({super.key});

  static const routeName = '/student/feedback';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.feedbackTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.t(AppText.feedbackSnack)))),
        icon: const Icon(Icons.share_rounded),
        label: Text(context.t(AppText.viewMaterials)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockFeedback.length,
        itemBuilder: (context, index) {
          final item = mockFeedback[index];
          final colorScheme = Theme.of(context).colorScheme;
          final icon = item.isCorrect ? Icons.check_circle : Icons.error_outline;
          final color = item.isCorrect ? colorScheme.secondary : colorScheme.tertiary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: ListTile(
                leading:
                    CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(item.detail),
                trailing: Text(item.status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        },
      ),
    );
  }
}
