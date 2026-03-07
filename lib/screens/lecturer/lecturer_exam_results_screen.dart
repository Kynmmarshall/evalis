import 'package:flutter/material.dart';

import 'package:open_filex/open_filex.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/exam_scorebook.dart';
import '../../services/pdf_export_service.dart';
import '../../widgets/evalis_app_bar.dart';
import '../../widgets/student_score_row.dart';

class LecturerExamResultsArgs {
  const LecturerExamResultsArgs({required this.examId, this.initialScorebook});

  final String examId;
  final ExamScorebook? initialScorebook;
}

class LecturerExamResultsScreen extends StatefulWidget {
  const LecturerExamResultsScreen({super.key, required this.examId, this.initialScorebook});

  static const routeName = '/lecturer/results/exam';

  final String examId;
  final ExamScorebook? initialScorebook;

  @override
  State<LecturerExamResultsScreen> createState() => _LecturerExamResultsScreenState();
}

class _LecturerExamResultsScreenState extends State<LecturerExamResultsScreen> {
  final PdfExportService _pdfService = PdfExportService.instance;

  ExamScorebook? _scorebook;
  bool _isLoading = true;
  bool _isExporting = false;
  String? _error;
  String? _downloadPath;

  @override
  void initState() {
    super.initState();
    _scorebook = widget.initialScorebook;
    if (_scorebook != null) {
      _isLoading = false;
    }
    _loadScorebook();
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.resultsTitle)),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: body),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _scorebook == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _scorebook == null) {
      return _ErrorView(message: _error!, onRetry: _loadScorebook);
    }

    final scorebook = _scorebook;
    if (scorebook == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: _loadScorebook,
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _ExamSummaryCard(
            scorebook: scorebook,
            isExporting: _isExporting,
            onExport: _exportPdf,
            downloadPath: _downloadPath,
            onViewPdf: _downloadPath == null ? null : () => _openDownloadedPdf(),
          ),
          const SizedBox(height: 24),
          Text(
            context.t(AppText.resultsStudentsSection),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (scorebook.students.isEmpty)
            Text(
              context.t(AppText.resultsNoSubmissions),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final score in scorebook.students)
                      StudentScoreRow(
                        score: score,
                        totalQuestions: scorebook.questionCount,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadScorebook() async {
    setState(() {
      _isLoading = _scorebook == null;
      _error = null;
    });
    try {
      final latest = await _pdfService.fetchScorebook(widget.examId);
      if (!mounted) return;
      setState(() => _scorebook = latest);
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
      final path = await _pdfService.downloadExamPdf(widget.examId);
      if (!mounted) return;
      setState(() => _downloadPath = path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.t(AppText.pdfSavedTo)} $path')),
      );
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

  Future<void> _openDownloadedPdf() async {
    final path = _downloadPath;
    if (path == null) {
      return;
    }
    final result = await OpenFilex.open(path);
    if (!mounted) {
      return;
    }
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t(AppText.pdfOpenFailed))),
      );
    }
  }
}

class _ExamSummaryCard extends StatelessWidget {
  const _ExamSummaryCard({
    required this.scorebook,
    required this.isExporting,
    required this.onExport,
    this.downloadPath,
    this.onViewPdf,
  });

  final ExamScorebook scorebook;
  final bool isExporting;
  final VoidCallback onExport;
  final String? downloadPath;
  final VoidCallback? onViewPdf;

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
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                final coursePill = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    scorebook.courseCode.toUpperCase(),
                    style: TextStyle(color: colorScheme.onSecondaryContainer),
                  ),
                );

                final exportButton = FilledButton.icon(
                  onPressed: isExporting ? null : onExport,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: isExporting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.t(AppText.generatePdf)),
                );

                if (!isCompact) {
                  return Row(
                    children: [
                      coursePill,
                      const Spacer(),
                      exportButton,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    coursePill,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: exportButton),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              scorebook.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              windowLabel,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 12),
            Text(
              '${context.t(AppText.resultsStudentCount)}: ${scorebook.students.length}',
            ),
            Text('${context.t(AppText.examScoreAnswered)}: ${scorebook.questionCount}'),
            if (downloadPath != null) ...[
              const SizedBox(height: 12),
              SelectableText(
                '${context.t(AppText.pdfSavedTo)} $downloadPath',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: onViewPdf,
                  icon: const Icon(Icons.visibility_rounded),
                  label: Text(context.t(AppText.viewPdf)),
                ),
              ),
            ],
          ],
        ),
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
            FilledButton(onPressed: onRetry, child: Text(context.t(AppText.retryAction))),
          ],
        ),
      ),
    );
  }
}
