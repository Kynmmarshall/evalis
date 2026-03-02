import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/exam_brief.dart';
import '../../services/assessment_service.dart';
import '../../widgets/evalis_app_bar.dart';

class LecturerCreateMcqScreen extends StatefulWidget {
  const LecturerCreateMcqScreen({super.key});

  static const routeName = '/lecturer/create-mcq';

  @override
  State<LecturerCreateMcqScreen> createState() => _LecturerCreateMcqScreenState();
}

class _LecturerCreateMcqScreenState extends State<LecturerCreateMcqScreen> {
  final AssessmentService _assessmentService = AssessmentService.instance;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  List<ExamBrief> _exams = const [];
  ExamBrief? _selectedExam;
  bool _hasSyncedArgs = false;
  ExamBrief? _argumentExam;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _questionController.removeListener(_onFormChanged);
    _questionController.dispose();
    _explanationController.dispose();
    for (final controller in _optionControllers) {
      controller.removeListener(_onFormChanged);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _questionController.addListener(_onFormChanged);
    for (final controller in _optionControllers) {
      controller.addListener(_onFormChanged);
    }
    _loadExams();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasSyncedArgs) return;
    _hasSyncedArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ExamBrief) {
      _argumentExam = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = _ErrorView(message: _error!, onRetry: _loadExams);
    } else if (_exams.isEmpty) {
      body = _EmptyState(onRefresh: _loadExams);
    } else {
      body = _QuestionForm(
        questionController: _questionController,
        explanationController: _explanationController,
        optionControllers: _optionControllers,
        selectedExam: _selectedExam,
        exams: _exams,
        onExamSelected: (exam) => setState(() => _selectedExam = exam),
        correctIndex: _correctIndex,
        onCorrectIndexChanged: (value) => setState(() => _correctIndex = value),
        onPreview: () => _showSnack(context, AppText.prototypeMessage),
        onPublish: _submitQuestion,
        isSubmitting: _isSubmitting,
      );
    }

    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.createMcqTitle)),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: body),
    );
  }

  void _onFormChanged() {
    setState(() {});
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final exams = await _assessmentService.fetchExams();
      if (!mounted) return;
      _syncExamSelection(exams);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _syncExamSelection(List<ExamBrief> fetched) {
    final resolved = List<ExamBrief>.from(fetched);
    final arg = _argumentExam;
    if (arg != null && resolved.every((exam) => exam.id != arg.id)) {
      resolved.insert(0, arg);
    }
    final currentSelection = _selectedExam;
    ExamBrief? selection;
    if (currentSelection != null && resolved.any((exam) => exam.id == currentSelection.id)) {
      selection = resolved.firstWhere((exam) => exam.id == currentSelection.id);
    } else if (arg != null && resolved.any((exam) => exam.id == arg.id)) {
      selection = resolved.firstWhere((exam) => exam.id == arg.id);
    } else if (resolved.isNotEmpty) {
      selection = resolved.first;
    }
    setState(() {
      _exams = resolved;
      _selectedExam = selection;
    });
  }

  Future<void> _submitQuestion() async {
    final exam = _selectedExam;
    final prompt = _questionController.text.trim();
    final options = _optionControllers.map((controller) => controller.text.trim()).toList();
    final hasIncompleteField = prompt.isEmpty || options.any((option) => option.isEmpty);
    if (exam == null || hasIncompleteField) {
      _showSnack(context, AppText.examNameRequired);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _assessmentService.addQuestion(
        examId: exam.id,
        prompt: prompt,
        options: options,
        correctIndex: _correctIndex,
        tip: _explanationController.text.trim(),
      );
      if (!mounted) return;
      _questionController.clear();
      for (final controller in _optionControllers) {
        controller.clear();
      }
      _explanationController.clear();
      setState(() => _correctIndex = 0);
      _showSnack(context, AppText.publishSnack);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnack(BuildContext context, AppText key) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t(key))),
    );
  }
}

class _QuestionForm extends StatelessWidget {
  const _QuestionForm({
    required this.questionController,
    required this.explanationController,
    required this.optionControllers,
    required this.selectedExam,
    required this.exams,
    required this.onExamSelected,
    required this.correctIndex,
    required this.onCorrectIndexChanged,
    required this.onPreview,
    required this.onPublish,
    required this.isSubmitting,
  });

  final TextEditingController questionController;
  final TextEditingController explanationController;
  final List<TextEditingController> optionControllers;
  final ExamBrief? selectedExam;
  final List<ExamBrief> exams;
  final ValueChanged<ExamBrief?> onExamSelected;
  final int correctIndex;
  final ValueChanged<int> onCorrectIndexChanged;
  final VoidCallback onPreview;
  final Future<void> Function() onPublish;
  final bool isSubmitting;

  bool get _canSubmit {
    final prompt = questionController.text.trim();
    final options = optionControllers.map((controller) => controller.text.trim());
    return !isSubmitting && selectedExam != null && prompt.isNotEmpty && options.every((option) => option.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    const alphabet = ['A', 'B', 'C', 'D'];
    return SingleChildScrollView(
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
            enabled: exams.isNotEmpty,
            initialSelection: selectedExam,
            label: Text(context.t(AppText.examPickerLabel)),
            dropdownMenuEntries: exams
                .map(
                  (exam) => DropdownMenuEntry<ExamBrief>(
                    value: exam,
                    label: '${exam.title} • ${exam.window}',
                  ),
                )
                .toList(),
            onSelected: onExamSelected,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: questionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.t(AppText.questionFieldLabel),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(optionControllers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: optionControllers[index],
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
            initialSelection: correctIndex,
            label: Text(context.t(AppText.correctAnswerLabel)),
            onSelected: (value) {
              if (value == null) return;
              onCorrectIndexChanged(value);
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
            controller: explanationController,
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
                onPressed: onPreview,
                child: Text(context.t(AppText.previewButton)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canSubmit
                      ? () {
                          onPublish();
                        }
                      : null,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.t(AppText.publishButton)),
                ),
              ),
            ],
          ),
        ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          Icon(Icons.library_add_check_rounded,
              size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            context.t(AppText.examManagerSubtitle),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
