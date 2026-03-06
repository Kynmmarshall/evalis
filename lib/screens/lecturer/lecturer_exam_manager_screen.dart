import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String? _pendingScheduleId;

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
                  onSchedule: () => _openSchedule(exam),
                  onRemove: () => _removeExam(exam),
                  isDeleting: _pendingDeletionId == exam.id,
                  isScheduling: _pendingScheduleId == exam.id,
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

  Future<void> _openSchedule(ExamBrief exam) async {
    final result = await showModalBottomSheet<_ExamScheduleResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ExamScheduleSheet(exam: exam),
    );
    if (result == null) return;
    setState(() => _pendingScheduleId = exam.id);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await _assessmentService.updateExamSchedule(
        examId: exam.id,
        examWindow: result.windowLabel,
        startAt: result.startAt,
        endAt: result.endAt,
        launched: result.launched,
      );
      if (!mounted) return;
      setState(() {
        _exams = _exams.map((item) => item.id == updated.id ? updated : item).toList();
      });
      messenger.showSnackBar(SnackBar(content: Text(context.t(AppText.scheduleSaved))));
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _pendingScheduleId = null);
      }
    }
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
    required this.onSchedule,
    required this.onRemove,
    required this.isDeleting,
    required this.isScheduling,
  });

  final ExamBrief exam;
  final VoidCallback onManage;
  final VoidCallback onSchedule;
  final VoidCallback onRemove;
  final bool isDeleting;
  final bool isScheduling;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = _ExamStatus.resolve(exam, context);
    final formatter = DateFormat('EEE, MMM d • h:mm a');
    final startText = exam.startAt != null ? formatter.format(exam.startAt!) : null;
    final endText = exam.endAt != null ? formatter.format(exam.endAt!) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exam.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${exam.courseCode} • ${exam.window}', style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              if (startText != null && endText != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.schedule_rounded, size: 18, color: colorScheme.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('$startText → $endText', style: theme.textTheme.bodySmall),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(Icons.timer_off_rounded, size: 18, color: colorScheme.outline),
                    const SizedBox(width: 8),
                    Text(context.t(AppText.scheduleUnsetHint), style: theme.textTheme.bodySmall),
                  ],
                ),
              const SizedBox(height: 16),
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
                    child: FilledButton.tonal(
                      onPressed: isScheduling ? null : onSchedule,
                      child: isScheduling
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.t(AppText.scheduleExamButton)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: isDeleting ? null : onRemove,
                style: OutlinedButton.styleFrom(foregroundColor: colorScheme.error),
                child: isDeleting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.t(AppText.removeExamButton)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamStatus {
  const _ExamStatus({required this.label, required this.color});

  final String label;
  final Color color;

  static _ExamStatus resolve(ExamBrief exam, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (exam.isLive) {
      return _ExamStatus(label: context.t(AppText.examStatusLive), color: scheme.primary);
    }
    if (exam.isUpcoming) {
      return _ExamStatus(label: context.t(AppText.examStatusScheduled), color: scheme.tertiary);
    }
    if (exam.isClosed) {
      return _ExamStatus(label: context.t(AppText.examStatusClosed), color: scheme.outline);
    }
    return _ExamStatus(label: context.t(AppText.examStatusDraft), color: scheme.outlineVariant);
  }
}

class _ExamScheduleSheet extends StatefulWidget {
  const _ExamScheduleSheet({required this.exam});

  final ExamBrief exam;

  @override
  State<_ExamScheduleSheet> createState() => _ExamScheduleSheetState();
}

class _ExamScheduleSheetState extends State<_ExamScheduleSheet> {
  late final TextEditingController _windowController;
  late final DateFormat _formatter;
  DateTime? _startAt;
  DateTime? _endAt;
  bool _launch = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _windowController = TextEditingController(text: widget.exam.window);
    _startAt = widget.exam.startAt;
    _endAt = widget.exam.endAt;
    _launch = widget.exam.launched && widget.exam.isScheduled;
    _formatter = DateFormat('EEE, MMM d • h:mm a');
  }

  @override
  void dispose() {
    _windowController.dispose();
    super.dispose();
  }

  String? get _startLabel => _startAt == null ? null : _formatter.format(_startAt!);
  String? get _endLabel => _endAt == null ? null : _formatter.format(_endAt!);

  bool get _isValid => _startAt != null && _endAt != null && _endAt!.isAfter(_startAt!);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottomInset + 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t(AppText.examScheduleTitle),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _windowController,
            decoration: InputDecoration(
              labelText: context.t(AppText.examWindowLabel),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          _ScheduleTile(
            icon: Icons.play_arrow_rounded,
            label: context.t(AppText.examStartLabel),
            value: _startLabel,
            placeholder: context.t(AppText.scheduleUnsetHint),
            onTap: _pickStart,
          ),
          const SizedBox(height: 12),
          _ScheduleTile(
            icon: Icons.stop_rounded,
            label: context.t(AppText.examEndLabel),
            value: _endLabel,
            placeholder: context.t(AppText.scheduleUnsetHint),
            onTap: _pickEnd,
          ),
          SwitchListTile.adaptive(
            title: Text(context.t(AppText.examLaunchToggle)),
            value: _launch,
            onChanged: (value) => setState(() => _launch = value),
            contentPadding: EdgeInsets.zero,
          ),
          if (_showError)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                context.t(AppText.scheduleValidation),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: Text(context.t(AppText.saveScheduleButton)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStart() async {
    final value = await _pickDateTime(_startAt ?? DateTime.now());
    if (value == null) return;
    setState(() {
      _startAt = value;
      if (_endAt != null && !_endAt!.isAfter(value)) {
        _endAt = value.add(const Duration(hours: 1));
      }
      _showError = false;
    });
  }

  Future<void> _pickEnd() async {
    final base = _startAt ?? DateTime.now();
    final value = await _pickDateTime(_endAt ?? base.add(const Duration(hours: 1)), firstDate: base);
    if (value == null) return;
    setState(() {
      _endAt = value;
      _showError = false;
    });
  }

  Future<DateTime?> _pickDateTime(DateTime initial, {DateTime? firstDate}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _submit() {
    if (!_isValid) {
      setState(() => _showError = true);
      return;
    }
    final fallback = widget.exam.window.isEmpty
        ? context.t(AppText.examWindowLabel)
        : widget.exam.window;
    final label = _windowController.text.trim().isEmpty ? fallback : _windowController.text.trim();
    Navigator.of(context).pop(
      _ExamScheduleResult(
        windowLabel: label,
        startAt: _startAt!,
        endAt: _endAt!,
        launched: _launch,
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.icon,
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final String placeholder;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value ?? placeholder),
        trailing: const Icon(Icons.edit_calendar_rounded),
      ),
    );
  }
}

class _ExamScheduleResult {
  const _ExamScheduleResult({
    required this.windowLabel,
    required this.startAt,
    required this.endAt,
    required this.launched,
  });

  final String windowLabel;
  final DateTime startAt;
  final DateTime endAt;
  final bool launched;
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
