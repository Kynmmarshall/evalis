import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/exam_scorebook.dart';
import '../../models/student_score.dart';
import '../../services/pdf_export_service.dart';
import '../../widgets/evalis_app_bar.dart';

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
  bool _isExporting = false;
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
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: _isExporting
                  ? null
                  : () {
                      _exportPdf();
                    },
              label: _isExporting
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(context.t(AppText.generatePdf)),
            ),
            const SizedBox(height: 24),
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
                  child: _ExamScoreCard(scorebook: book),
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

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      await _pdfService.generateSummary();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.pdfSuccess))));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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
  const _ExamScoreCard({required this.scorebook});

  final ExamScorebook scorebook;

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
            Divider(height: 1, color: colorScheme.surfaceVariant),
            const SizedBox(height: 16),
            if (scorebook.students.isEmpty)
              Text(
                context.t(AppText.resultsNoSubmissions),
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
              )
            else
              Column(
                children: [
                  for (final score in scorebook.students)
                    _StudentScoreRow(
                      score: score,
                      totalQuestions: scorebook.questionCount,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StudentScoreRow extends StatelessWidget {
  const _StudentScoreRow({required this.score, required this.totalQuestions});

  final StudentScore score;
  final int totalQuestions;

  double get _accuracy => totalQuestions == 0 ? 0 : score.correctAnswers / totalQuestions;
  double get _completion => totalQuestions == 0 ? 0 : score.answeredQuestions / totalQuestions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  score.name,
                  style:
                      theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${score.correctAnswers} / $totalQuestions',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: _accuracy,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.task_alt_rounded, size: 16, color: colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                '${context.t(AppText.examScoreAnswered)}: '
                '${score.answeredQuestions} / $totalQuestions',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
              const Spacer(),
              Text(
                '${(_accuracy * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _completion,
            minHeight: 4,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}
