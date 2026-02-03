import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../models/exam_brief.dart';
import '../../widgets/evalis_app_bar.dart';

class LecturerCreateMcqScreen extends StatefulWidget {
  const LecturerCreateMcqScreen({super.key});

  static const routeName = '/lecturer/create-mcq';

  @override
  State<LecturerCreateMcqScreen> createState() => _LecturerCreateMcqScreenState();
}

class _LecturerCreateMcqScreenState extends State<LecturerCreateMcqScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  late List<ExamBrief> _exams;
  late ExamBrief _selectedExam;
  bool _hasSyncedArgs = false;

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _exams = List<ExamBrief>.from(mockExams);
    _selectedExam = _exams.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasSyncedArgs) return;
    _hasSyncedArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ExamBrief) {
      if (!_exams.any((exam) => exam.id == args.id)) {
        _exams.insert(0, args);
      }
      _selectedExam = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    const alphabet = ['A', 'B', 'C', 'D'];
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.createMcqTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t(AppText.createMcqSubtitle),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            DropdownMenu<ExamBrief>(
              initialSelection: _selectedExam,
              label: Text(context.t(AppText.examPickerLabel)),
              dropdownMenuEntries: _exams
                  .map(
                    (exam) => DropdownMenuEntry<ExamBrief>(
                      value: exam,
                      label: '${exam.title} • ${exam.window}',
                    ),
                  )
                  .toList(),
              onSelected: (value) {
                if (value == null) return;
                setState(() => _selectedExam = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.t(AppText.questionFieldLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(_optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _optionControllers[index],
                  decoration: InputDecoration(
                    labelText: '${context.t(AppText.answerOptionLabel)} ${alphabet[index]}',
                    prefixIcon: CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
                      child: Text(alphabet[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            DropdownMenu<int>(
              initialSelection: _correctIndex,
              label: Text(context.t(AppText.correctAnswerLabel)),
              onSelected: (value) {
                if (value == null) return;
                setState(() => _correctIndex = value);
              },
              dropdownMenuEntries: List.generate(
                4,
                (index) => DropdownMenuEntry<int>(
                  value: index,
                  label: '${context.t(AppText.answerOptionLabel)} ${alphabet[index]}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _explanationController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: context.t(AppText.explanationLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                FilledButton(
                  onPressed: () => _showSnack(context, AppText.prototypeMessage),
                  child: Text(context.t(AppText.previewButton)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSnack(context, AppText.publishSnack),
                    child: Text(context.t(AppText.publishButton)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, AppText key) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t(key))),
    );
  }
}
