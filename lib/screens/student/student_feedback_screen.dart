import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/feedback_entry.dart';
import '../../services/assessment_service.dart';
import '../../widgets/evalis_app_bar.dart';

class StudentFeedbackScreen extends StatefulWidget {
  const StudentFeedbackScreen({super.key});

  static const routeName = '/student/feedback';

  @override
  State<StudentFeedbackScreen> createState() => _StudentFeedbackScreenState();
}

class _StudentFeedbackScreenState extends State<StudentFeedbackScreen> {
  final AssessmentService _service = AssessmentService.instance;
  late Future<List<FeedbackEntry>> _feedbackFuture;

  @override
  void initState() {
    super.initState();
    _feedbackFuture = _service.fetchFeedbackEntries();
  }

  Future<void> _refresh() async {
    setState(() {
      _feedbackFuture = _service.fetchFeedbackEntries();
    });
    await _feedbackFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.feedbackTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.t(AppText.feedbackSnack)))),
        icon: const Icon(Icons.share_rounded),
        label: Text(context.t(AppText.viewFeedback)),
      ),
      body: FutureBuilder<List<FeedbackEntry>>(
        future: _feedbackFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refresh,
                      child: Text(context.t(AppText.retryAction)),
                    ),
                  ],
                ),
              ),
            );
          }
          final entries = snapshot.data ?? const [];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: entries.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _FeedbackBanner(),
                      const SizedBox(height: 60),
                      Text(
                        context.t(AppText.feedbackSubtitle),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.outline),
                      ),
                    ],
                  )
                : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: entries.length + 1,
                    itemBuilder: (context, index) {
                      final colorScheme = Theme.of(context).colorScheme;
                      if (index == 0) {
                        return const _FeedbackBanner();
                      }

                      final entry = entries[index - 1];
                final badgeColor = entry.isCorrect ? colorScheme.secondary : colorScheme.error;
                final badgeIcon = entry.isCorrect ? Icons.thumb_up_alt_rounded : Icons.warning_amber_rounded;

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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: badgeColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(badgeIcon, color: badgeColor, size: 18),
                                          const SizedBox(width: 6),
                                          Text(entry.status, style: TextStyle(color: badgeColor)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  entry.detail,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.tertiary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.upcoming_rounded, color: colorScheme.tertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.t(AppText.correctionsBanner),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
