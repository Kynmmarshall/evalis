import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/exam_scorebook.dart';
import '../../services/pdf_export_service.dart';
import '../../widgets/evalis_app_bar.dart';
import 'lecturer_exam_results_screen.dart';

class LecturerResultsScreen extends StatefulWidget {
  const LecturerResultsScreen({super.key});

  static const routeName = '/lecturer/results';

  @override
  State<LecturerResultsScreen> createState() => _LecturerResultsScreenState();
}

class _LecturerResultsScreenState extends State<LecturerResultsScreen> {
  final PdfExportService _pdfService = PdfExportService.instance;
  List<ExamScorebook> _scorebooks = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = _ErrorView(message: _error!, onRetry: _loadScores);
    } else {
      body = RefreshIndicator(
        onRefresh: _loadScores,
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              context.t(AppText.resultsSubtitle),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              context.t(AppText.resultsListTitle),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (_scorebooks.isEmpty)
              const _EmptyScores()
            else
              ..._scorebooks.map(
                (book) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _ExamScoreCard(
                    scorebook: book,
                    onTap: () => _openScorebook(book),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.resultsTitle)),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: body),
    );
  }

  Future<void> _loadScores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final scorebooks = await _pdfService.fetchScores();
      if (!mounted) return;
      setState(() => _scorebooks = scorebooks);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openScorebook(ExamScorebook scorebook) {
    Navigator.pushNamed(
      context,
      LecturerExamResultsScreen.routeName,
      arguments: LecturerExamResultsArgs(
        examId: scorebook.examId,
        initialScorebook: scorebook,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                onRetry();
              },
              child: Text(context.t(AppText.retryAction)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyScores extends StatelessWidget {
  const _EmptyScores();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            context.t(AppText.resultsNoSubmissions),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExamScoreCard extends StatelessWidget {
  const _ExamScoreCard({required this.scorebook, required this.onTap});

  final ExamScorebook scorebook;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final closedAt = scorebook.closedAt;
    final localizations = MaterialLocalizations.of(context);
    final windowLabel = closedAt != null
        ? '${localizations.formatMediumDate(closedAt)} · '
            '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(closedAt))}'
        : (scorebook.examWindow.isNotEmpty
            ? scorebook.examWindow
            : context.t(AppText.scheduleUnsetHint));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    scorebook.courseCode.toUpperCase(),
                    style: TextStyle(color: colorScheme.onSecondaryContainer),
                  ),
                ),
                const Spacer(),
                Icon(Icons.leaderboard_rounded, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  context.t(AppText.examScoreLabel),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              scorebook.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 18, color: colorScheme.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    windowLabel,
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${scorebook.students.length} ${context.t(AppText.resultsStudentCount)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.chevron_right_rounded),
              label: Text(context.t(AppText.resultsViewDetails)),
            ),
          ],
        ),
      ),
    );
  }
}
