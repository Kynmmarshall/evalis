import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../widgets/evalis_app_bar.dart';
import 'student_feedback_screen.dart';

class StudentExamScreen extends StatefulWidget {
  const StudentExamScreen({super.key});

  static const routeName = '/student/exam';

  @override
  State<StudentExamScreen> createState() => _StudentExamScreenState();
}

class _StudentExamScreenState extends State<StudentExamScreen> {
  final List<int?> _answers = List<int?>.filled(mockQuestions.length, null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.examTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockQuestions.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t(AppText.examSubtitle),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_rounded, color: colorScheme.tertiary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.t(AppText.examLockedHint),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          if (index == mockQuestions.length + 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 32),
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, StudentFeedbackScreen.routeName),
                child: Text(context.t(AppText.resumeExam)),
              ),
            );
          }

          final question = mockQuestions[index - 1];
          final answer = _answers[index - 1];
          final isLocked = answer != null;
          final isCorrect = answer == question.correctIndex;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q$index — ${question.prompt}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(question.options.length, (optionIndex) {
                      final isSelected = answer == optionIndex;
                      final borderColor = isSelected
                          ? colorScheme.primary
                          : Theme.of(context).dividerColor.withValues(alpha: 0.5);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: isLocked
                              ? null
                              : () => setState(() => _answers[index - 1] = optionIndex),
                          borderRadius: BorderRadius.circular(14),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.08)
                                  : Theme.of(context).cardColor,
                              border: Border.all(color: borderColor, width: 1.4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: borderColor.withValues(alpha: 0.15),
                                    child: Text(String.fromCharCode(65 + optionIndex)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(question.options[optionIndex])),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: borderColor,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    if (isLocked)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              (isCorrect ? colorScheme.secondary : colorScheme.tertiary).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.verified_rounded : Icons.tips_and_updates_rounded,
                                  color: isCorrect ? colorScheme.secondary : colorScheme.tertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.t(AppText.responseLocked),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isCorrect
                                  ? context.t(AppText.responseCorrect)
                                  : context.t(AppText.responseIncorrect),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question.tip,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
