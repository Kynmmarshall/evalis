import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
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
  List<StudentScore> _scores = const [];
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
            if (_scores.isEmpty)
              const _EmptyScores()
            else
              ..._scores.map(
                (score) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ScoreCard(score: score),
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
      final scores = await _pdfService.fetchScores();
      if (!mounted) return;
      setState(() => _scores = scores);
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
            context.t(AppText.resultsSubtitle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});

  final StudentScore score;

  @override
  Widget build(BuildContext context) {
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
                    score.sent ? context.t(AppText.pdfReady) : context.t(AppText.pdfPending),
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600),
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
  }
}
