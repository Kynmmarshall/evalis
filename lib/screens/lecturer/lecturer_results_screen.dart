import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../services/pdf_export_service.dart';
import '../../widgets/evalis_app_bar.dart';

class LecturerResultsScreen extends StatelessWidget {
  const LecturerResultsScreen({super.key});

  static const routeName = '/lecturer/results';

  @override
  Widget build(BuildContext context) {
    final pdfService = PdfExportService();
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.resultsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t(AppText.resultsSubtitle),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: () async {
                await pdfService.generateSummary();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(context.t(AppText.pdfSuccess))));
                }
              },
              label: Text(context.t(AppText.generatePdf)),
            ),
            const SizedBox(height: 24),
            Text(
              context.t(AppText.resultsListTitle),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: mockScores.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final score = mockScores[index];
                  final colorScheme = Theme.of(context).colorScheme;
                  final badgeColor = score.sent ? colorScheme.secondary : colorScheme.tertiary;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  score.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Chip(
                                backgroundColor: badgeColor.withValues(alpha: 0.12),
                                label: Text(
                                  score.sent
                                      ? context.t(AppText.pdfReady)
                                      : context.t(AppText.pdfPending),
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: score.score / 100,
                                  backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('${score.score} / 100'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
