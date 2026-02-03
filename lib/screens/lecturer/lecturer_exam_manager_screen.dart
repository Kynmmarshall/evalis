import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../models/exam_brief.dart';
import '../../widgets/evalis_app_bar.dart';
import 'lecturer_create_mcq_screen.dart';

class LecturerExamManagerScreen extends StatefulWidget {
  const LecturerExamManagerScreen({super.key});

  static const routeName = '/lecturer/exams';

  @override
  State<LecturerExamManagerScreen> createState() => _LecturerExamManagerScreenState();
}

class _LecturerExamManagerScreenState extends State<LecturerExamManagerScreen> {
  final TextEditingController _nameController = TextEditingController();
  late List<ExamBrief> _exams;

  @override
  void initState() {
    super.initState();
    _exams = List<ExamBrief>.from(mockExams);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.examManagerTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.t(AppText.examManagerSubtitle),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: context.t(AppText.examNameLabel),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _createExam,
                      child: Text(context.t(AppText.createExamButton)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ..._exams.map((exam) => _ExamCard(
                exam: exam,
                onManage: () => _openBuilder(exam),
                onRemove: () => _removeExam(exam),
              )),
        ],
      ),
    );
  }

  void _createExam() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.examNameRequired))));
      return;
    }
    final id = 'ex-${DateTime.now().millisecondsSinceEpoch}';
    final generatedCode = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(3)
        .join()
        .toUpperCase();
    final exam = ExamBrief(
      id: id,
      title: name,
      courseCode: generatedCode.isEmpty ? 'GEN' : generatedCode,
      window: 'Draft window',
    );
    setState(() {
      _exams.insert(0, exam);
      _nameController.clear();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.t(AppText.examCreated))));
  }

  void _openBuilder(ExamBrief exam) {
    Navigator.pushNamed(
      context,
      LecturerCreateMcqScreen.routeName,
      arguments: exam,
    );
  }

  void _removeExam(ExamBrief exam) {
    setState(() => _exams.remove(exam));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.t(AppText.examRemoved))));
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.onManage, required this.onRemove});

  final ExamBrief exam;
  final VoidCallback onManage;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text('${exam.courseCode} • ${exam.window}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onManage,
                      child: Text(context.t(AppText.manageExamButton)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRemove,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      child: Text(context.t(AppText.removeExamButton)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
