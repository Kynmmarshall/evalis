import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../models/course_enrollment.dart';
import '../../models/course_info.dart';
import '../../services/enrollment_service.dart';
import '../../widgets/evalis_app_bar.dart';

class StudentCoursesScreen extends StatelessWidget {
  StudentCoursesScreen({super.key});

  static const routeName = '/student/courses';

  final EnrollmentService _service = EnrollmentService();

  @override
  Widget build(BuildContext context) {
    final enrolledCodes = studentEnrollments.map((e) => e.course.code).toSet();
    final visibleCourses = availableCourses.where((course) => !enrolledCodes.contains(course.code)).toList();
    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.availableCoursesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(context.t(AppText.pendingApprovalNote)),
            ),
          ),
          const SizedBox(height: 20),
          ...visibleCourses.map((course) => Padding(
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
                        Text(course.lecturer, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: () => _handleRequest(context, course),
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
          ...studentEnrollments.map((enrollment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    title: Text(enrollment.course.title),
                    subtitle: Text('${enrollment.course.code} • ${enrollment.course.schedule}'),
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
  }

  Future<void> _handleRequest(BuildContext context, CourseInfo course) async {
    await _service.requestEnrollment(course);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.t(AppText.requestSent))));
  }
}
