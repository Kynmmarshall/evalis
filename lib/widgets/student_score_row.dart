import 'package:flutter/material.dart';

import '../app_settings.dart';
import '../l10n/app_texts.dart';
import '../models/student_score.dart';

class StudentScoreRow extends StatelessWidget {
  const StudentScoreRow({super.key, required this.score, required this.totalQuestions});

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
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
