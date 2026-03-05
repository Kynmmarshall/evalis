import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/course_info.dart';
import '../../services/enrollment_service.dart';
import '../../widgets/evalis_app_bar.dart';

class LecturerCoursesScreen extends StatefulWidget {
  const LecturerCoursesScreen({super.key});

  static const routeName = '/lecturer/courses/manage';

  @override
  State<LecturerCoursesScreen> createState() => _LecturerCoursesScreenState();
}

class _LecturerCoursesScreenState extends State<LecturerCoursesScreen> {
  final EnrollmentService _service = EnrollmentService.instance;
  List<CourseInfo> _courses = const [];
  bool _isLoading = true;
  String? _error;
  String? _pendingDeletionCode;

  @override
  void initState() {
    super.initState();
    _refreshCourses(initial: true);
  }

  Future<void> _refreshCourses({bool initial = false}) async {
    if (!mounted) return;
    if (initial) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() => _error = null);
    }
    try {
      final courses = await _service.fetchAvailableCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (initial && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openEditor({CourseInfo? course}) async {
    final result = await showModalBottomSheet<_CourseFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CourseEditorSheet(initial: course),
    );
    if (result == null) return;
    await _persistCourse(result, course);
  }

  Future<void> _persistCourse(_CourseFormResult data, CourseInfo? course) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (course == null) {
        await _service.saveCourse(
          title: data.title,
          lecturer: data.lecturer,
        );
        messenger.showSnackBar(SnackBar(content: Text(context.t(AppText.courseSaved))));
      } else {
        await _service.updateCourse(
          code: course.code,
          title: data.title,
          lecturer: data.lecturer,
        );
        messenger.showSnackBar(SnackBar(content: Text(context.t(AppText.courseUpdated))));
      }
      await _refreshCourses();
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _confirmDelete(CourseInfo course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t(AppText.deleteCourseButton)),
        content: Text(context.t(AppText.confirmCourseDelete)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(context.t(AppText.deleteCourseButton)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _pendingDeletionCode = course.code);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.deleteCourse(course.code);
      messenger.showSnackBar(SnackBar(content: Text(context.t(AppText.courseDeleted))));
      await _refreshCourses();
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _pendingDeletionCode = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.courseManagerTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.t(AppText.createCourseButton)),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorBody(
        message: _error!,
        onRetry: () => _refreshCourses(initial: true),
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshCourses,
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(
            context.t(AppText.courseManagerSubtitle),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          if (_courses.isEmpty)
            _EmptyCourses(message: context.t(AppText.courseListEmpty))
          else
            ..._courses.map(
              (course) => _CourseCard(
                key: ValueKey(course.code),
                course: course,
                isBusy: _pendingDeletionCode == course.code,
                onEdit: () => _openEditor(course: course),
                onDelete: () => _confirmDelete(course),
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    super.key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
    required this.isBusy,
  });

  final CourseInfo course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('${course.code} • ${course.lecturer}', style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            if (course.schedule.trim().isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.event_note, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      course.schedule,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: isBusy ? null : onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    label: Text(context.t(AppText.updateCourseButton)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: isBusy
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.t(AppText.deleteCourseButton)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school_rounded, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
              onPressed: onRetry,
              child: Text(context.t(AppText.retryAction)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseEditorSheet extends StatefulWidget {
  const _CourseEditorSheet({this.initial});

  final CourseInfo? initial;

  @override
  State<_CourseEditorSheet> createState() => _CourseEditorSheetState();
}

class _CourseEditorSheetState extends State<_CourseEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _lecturerController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _lecturerController = TextEditingController(text: widget.initial?.lecturer ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.initial == null
        ? context.t(AppText.createCourseButton)
        : context.t(AppText.updateCourseButton);
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.t(AppText.courseTitleLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? context.t(AppText.formFieldRequired)
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lecturerController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.t(AppText.courseLecturerLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? context.t(AppText.formFieldRequired)
                  : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: Text(titleText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      _CourseFormResult(
        title: _titleController.text.trim(),
        lecturer: _lecturerController.text.trim(),
      ),
    );
  }
}

class _CourseFormResult {
  const _CourseFormResult({
    required this.title,
    required this.lecturer,
  });
  final String title;
  final String lecturer;
}
