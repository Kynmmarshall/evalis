import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/course_enrollment.dart';
import '../../models/course_info.dart';
import '../../services/api_client.dart';
import '../../services/enrollment_service.dart';
import '../../widgets/evalis_app_bar.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  static const routeName = '/student/courses';

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  late Future<_CoursePayload> _coursesFuture;
  final EnrollmentService _service = EnrollmentService.instance;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _loadCourses();
  }

  Future<_CoursePayload> _loadCourses() async {
    final courses = await _service.fetchAvailableCourses();
    final enrollments = await _service.fetchMyEnrollments();
    final enrolledCodes = enrollments.map((e) => e.course.code).toSet();
    final available = courses
        .where((course) => !enrolledCodes.contains(course.code))
        .toList(growable: false);
    return _CoursePayload(available: available, enrollments: enrollments);
  }

  Future<void> _refresh() async {
    setState(() {
      _coursesFuture = _loadCourses();
    });
    await _coursesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.availableCoursesTitle)),
      body: FutureBuilder<_CoursePayload>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(message: snapshot.error.toString(), onRetry: _refresh);
          }
          final data = snapshot.requireData;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(context.t(AppText.pendingApprovalNote)),
                  ),
                ),
                const SizedBox(height: 20),
                if (data.available.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      context.t(AppText.noMoreCourses),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ...data.available.map((course) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text('${course.code} • ${course.schedule}',
                                    style: Theme.of(context).textTheme.bodySmall),
                                Text(course.lecturer,
                                    style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton(
                                    onPressed: () => _handleRequest(course),
                                    child: Text(context.t(AppText.registerCourseButton)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                const SizedBox(height: 20),
                Text(
                  context.t(AppText.coursesPendingTitle),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (data.enrollments.isEmpty)
                  Text(context.t(AppText.noPendingRequests),
                      style: Theme.of(context).textTheme.bodyMedium)
                else
                  ...data.enrollments.map((enrollment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ListTile(
                            title: Text(enrollment.course.title),
                            subtitle:
                                Text('${enrollment.course.code} • ${enrollment.course.schedule}'),
                            trailing: Text(
                              enrollment.status == EnrollmentStatus.approved
                                  ? context.t(AppText.approvedStatus)
                                  : context.t(AppText.pendingStatus),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRequest(CourseInfo course) async {
    try {
      await _service.requestEnrollment(course.code);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.requestSent))));
      await _refresh();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

class _CoursePayload {
  const _CoursePayload({required this.available, required this.enrollments});

  final List<CourseInfo> available;
  final List<CourseEnrollment> enrollments;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
            FilledButton(onPressed: onRetry, child: Text(context.t(AppText.retryAction))),
          ],
        ),
      ),
    );
  }
}
