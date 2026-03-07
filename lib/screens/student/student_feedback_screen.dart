import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/exam_brief.dart';
import '../../models/mock_question.dart';
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
  late Future<List<ExamBrief>> _closedExamsFuture;
  final Map<String, List<MockQuestion>> _questionCache = {};

  @override
  void initState() {
    super.initState();
    _closedExamsFuture = _service.fetchClosedExams();
  }

  Future<void> _refresh() async {
    setState(() {
      _closedExamsFuture = _service.fetchClosedExams();
    });
    await _closedExamsFuture;
  }

  Future<List<MockQuestion>> _loadQuestions(String examId) async {
    final cached = _questionCache[examId];
    if (cached != null) {
      return cached;
    }
    final questions = await _service.fetchQuestions(examId);
    _questionCache[examId] = questions;
    return questions;
  }

  Future<void> _openAnswerSheet(ExamBrief exam) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ExamAnswersSheet(
        exam: exam,
        windowLabel: _formatExamWindow(context, exam),
        loadQuestions: () => _loadQuestions(exam.id),
      ),
    );
  }

  String _formatExamWindow(BuildContext context, ExamBrief exam) {
    if (exam.startAt == null || exam.endAt == null) {
      return exam.window.isNotEmpty
          ? exam.window
          : context.t(AppText.scheduleUnsetHint);
    }
    final localizations = MaterialLocalizations.of(context);
    final start = exam.startAt!;
    final end = exam.endAt!;
    final startDate = localizations.formatMediumDate(start);
    final startTime = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(start));
    final endDate = localizations.formatMediumDate(end);
    final endTime = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(end));
    final sameDay = startDate == endDate;
    return sameDay
        ? '$startDate · $startTime → $endTime'
        : '$startDate · $startTime → $endDate · $endTime';
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
      body: FutureBuilder<List<ExamBrief>>(
        future: _closedExamsFuture,
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
          final exams = snapshot.data ?? const [];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const _FeedbackBanner(),
                if (exams.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        Icon(Icons.lock_clock_rounded,
                            size: 56, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          context.t(AppText.feedbackSubtitle),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                else
                  ...[
                    for (final exam in exams)
                      _ExamCard(
                        exam: exam,
                        windowLabel: _formatExamWindow(context, exam),
                        onView: () => _openAnswerSheet(exam),
                      ),
                  ],
              ],
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

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.windowLabel, required this.onView});

  final ExamBrief exam;
  final String windowLabel;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onView,
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
                        exam.courseCode.toUpperCase(),
                        style: TextStyle(color: colorScheme.onSecondaryContainer),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.checklist_rtl_rounded, color: colorScheme.secondary),
                  ],
                ),
                const SizedBox(height: 12),
                Text(exam.title, style: titleStyle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 18, color: colorScheme.outline.withValues(alpha: 0.9)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        windowLabel,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.outline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_rounded),
                  label: Text(context.t(AppText.resumeExam)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamScoreBanner extends StatelessWidget {
  const _ExamScoreBanner({
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
  });

  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final accuracy = totalQuestions == 0 ? 0.0 : correctAnswers / totalQuestions;
    final completion = totalQuestions == 0 ? 0.0 : answeredQuestions / totalQuestions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.military_tech_rounded, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  context.t(AppText.examScoreLabel),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '$correctAnswers / $totalQuestions',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: accuracy,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.task_alt_rounded, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  '${context.t(AppText.examScoreAnswered)}: $answeredQuestions / $totalQuestions',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                ),
                const Spacer(),
                Text('${(accuracy * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: completion,
              minHeight: 4,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamAnswersSheet extends StatefulWidget {
  const _ExamAnswersSheet({
    required this.exam,
    required this.windowLabel,
    required this.loadQuestions,
  });

  final ExamBrief exam;
  final String windowLabel;
  final Future<List<MockQuestion>> Function() loadQuestions;

  @override
  State<_ExamAnswersSheet> createState() => _ExamAnswersSheetState();
}

class _ExamAnswersSheetState extends State<_ExamAnswersSheet> {
  late Future<List<MockQuestion>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loadQuestions();
  }

  void _retry() {
    setState(() {
      _future = widget.loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, media.viewInsets.bottom + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              widget.exam.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              widget.windowLabel,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<MockQuestion>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(snapshot.error.toString(), textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _retry,
                            child: Text(context.t(AppText.retryAction)),
                          ),
                        ],
                      ),
                    );
                  }
                  final questions = snapshot.data ?? const [];
                  if (questions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          context.t(AppText.feedbackSubtitle),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  }
                  final total = questions.length;
                  final answered =
                      questions.where((q) => q.selectedIndex != null).length;
                  final correct = questions
                      .where((q) => q.selectedIndex != null && q.selectedIndex == q.correctIndex)
                      .length;
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: questions.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ExamScoreBanner(
                          totalQuestions: total,
                          answeredQuestions: answered,
                          correctAnswers: correct,
                        );
                      }
                      final question = questions[index - 1];
                      return _QuestionCard(
                        question: question,
                        questionNumber: index,
                      );
                    },
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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.questionNumber});

  final MockQuestion question;
  final int questionNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final promptStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question $questionNumber', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(question.prompt, style: promptStyle),
            const SizedBox(height: 16),
            Text(
              context.t(AppText.correctAnswerLabel),
              style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < question.options.length; i++)
              _AnswerOptionTile(
                optionLabel: String.fromCharCode(65 + i),
                text: question.options[i],
                isCorrect: i == question.correctIndex,
                isSelected: question.selectedIndex == i,
              ),
            if (question.tip.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_rounded, color: colorScheme.tertiary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.tip.trim(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({
    required this.optionLabel,
    required this.text,
    required this.isCorrect,
    required this.isSelected,
  });

  final String optionLabel;
  final String text;
  final bool isCorrect;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final background = isCorrect
        ? colorScheme.secondaryContainer
        : isSelected
            ? colorScheme.errorContainer
            : colorScheme.surfaceVariant;
    final borderColor = isCorrect
        ? colorScheme.secondary
        : isSelected
            ? colorScheme.error
            : colorScheme.outline;
    final indicatorColor = isCorrect
        ? colorScheme.secondary
        : isSelected
            ? colorScheme.error
            : colorScheme.surface;
    final indicatorTextColor = isCorrect
        ? colorScheme.onSecondary
        : isSelected
            ? colorScheme.onError
            : colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor.withValues(alpha: 0.6)),
            ),
            alignment: Alignment.center,
            child: Text(
              optionLabel,
              style: TextStyle(color: indicatorTextColor, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isCorrect ? FontWeight.w600 : null,
                  ),
                ),
                if (isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          context.t(AppText.responseCorrect),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_pin_circle_rounded,
                          size: 16,
                          color: isCorrect ? colorScheme.secondary : colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.t(AppText.studentAnswerLabel),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isCorrect ? colorScheme.secondary : colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
