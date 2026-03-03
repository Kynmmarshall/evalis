import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/course_info.dart';
import '../../models/exam_brief.dart';
import '../../services/assessment_service.dart';
import '../../services/enrollment_service.dart';
import '../../widgets/evalis_app_bar.dart';
import 'lecturer_create_mcq_screen.dart';

class LecturerExamManagerScreen extends StatefulWidget {
  const LecturerExamManagerScreen({super.key});

  static const routeName = '/lecturer/exams';

  @override
  State<LecturerExamManagerScreen> createState() => _LecturerExamManagerScreenState();
}

class _LecturerExamManagerScreenState extends State<LecturerExamManagerScreen> {
  final AssessmentService _assessmentService = AssessmentService.instance;
  final EnrollmentService _enrollmentService = EnrollmentService.instance;
  final TextEditingController _nameController = TextEditingController();
  List<ExamBrief> _exams = const [];
  List<CourseInfo> _courses = const [];
  CourseInfo? _selectedCourse;
  bool _isLoading = true;
  bool _isCreating = false;
  bool _isCoursesLoading = true;
  String? _error;
  String? _courseError;
  String? _pendingDeletionId;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = _ErrorView(message: _error!, onRetry: _refreshAll);
    } else {
      body = RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
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
                    if (_isCoursesLoading)
                      const LinearProgressIndicator(minHeight: 4)
                    else if (_courseError != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_courseError!, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _loadCourses,
                            child: Text(context.t(AppText.retryAction)),
                          ),
                        ],
                      )
                    else if (_courses.isEmpty)
                      Text(
                        context.t(AppText.noCoursesAvailable),
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      DropdownButtonFormField<CourseInfo>(
                        value: _selectedCourse,
                        items: _courses
                            .map(
                              (course) => DropdownMenuItem<CourseInfo>(
                                value: course,
                                child: Text('${course.code} • ${course.title}'),
                              ),
                            )
                            .toList(),
                        onChanged: (course) => setState(() => _selectedCourse = course),
                        decoration: InputDecoration(
                          labelText: context.t(AppText.coursePickerLabel),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isCreating || _selectedCourse == null
                            ? null
                            : () {
                                _createExam();
                              },
                        child: _isCreating
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(context.t(AppText.createExamButton)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_exams.isEmpty)
              _EmptyList()
            else
              ..._exams.map(
                (exam) => _ExamCard(
                  exam: exam,
                  onManage: () => _openBuilder(exam),
                  onRemove: () => _removeExam(exam),
                  isDeleting: _pendingDeletionId == exam.id,
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.examManagerTitle)),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: body),
    );
  }

  Future<void> _createExam() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.examNameRequired))));
      return;
    }
    final course = _selectedCourse;
    if (course == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.courseSelectionRequired))));
      return;
    }
    setState(() => _isCreating = true);
    try {
      final exam = await _assessmentService.createExam(
        title: name,
        courseCode: course.code,
        examWindow: 'Draft window',
      );
      if (!mounted) return;
      setState(() {
        _exams = [exam, ..._exams];
        _nameController.clear();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.examCreated))));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadExams(),
      _loadCourses(),
    ]);
  }

  void _openBuilder(ExamBrief exam) {
    Navigator.pushNamed(
      context,
      LecturerCreateMcqScreen.routeName,
      arguments: exam,
    );
  }

  Future<void> _removeExam(ExamBrief exam) async {
    setState(() => _pendingDeletionId = exam.id);
    try {
      await _assessmentService.deleteExam(exam.id);
      if (!mounted) return;
      setState(() => _exams = _exams.where((item) => item.id != exam.id).toList());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.examRemoved))));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _pendingDeletionId = null);
      }
    }
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isCoursesLoading = true;
      _courseError = null;
    });
    try {
      final courses = await _enrollmentService.fetchAvailableCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        if (courses.isEmpty) {
          _selectedCourse = null;
        } else if (_selectedCourse == null ||
            courses.every((course) => course.code != _selectedCourse!.code)) {
          _selectedCourse = courses.first;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _courseError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isCoursesLoading = false);
      }
    }
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final exams = await _assessmentService.fetchExams();
      if (!mounted) return;
      setState(() => _exams = exams);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.exam,
    required this.onManage,
    required this.onRemove,
    required this.isDeleting,
  });

  final ExamBrief exam;
  final VoidCallback onManage;
  final VoidCallback onRemove;
  final bool isDeleting;

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
                      onPressed: isDeleting ? null : onRemove,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      child: isDeleting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.t(AppText.removeExamButton)),
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

class _EmptyList extends StatelessWidget {
  const _EmptyList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.assignment_add, size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          context.t(AppText.examManagerSubtitle),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
