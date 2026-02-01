import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_texts.dart';
import '../../models/course_enrollment.dart';
import '../../widgets/evalis_app_bar.dart';
import 'student_courses_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  static const routeName = '/student/profile';

  @override
  Widget build(BuildContext context) {
    final approvedCourses = studentEnrollments
        .where((enrollment) => enrollment.status == EnrollmentStatus.approved)
        .toList();
    final pendingCourses = studentEnrollments
        .where((enrollment) => enrollment.status == EnrollmentStatus.pending)
        .toList();

    return Scaffold(
      appBar: EvalisAppBar(title: context.t(AppText.studentProfileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentProfile.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(studentProfile.roleLabel, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Text(studentProfile.headline, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Text(studentProfile.email, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.t(AppText.studentProfileSubtitle),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          _CourseSection(
            title: context.t(AppText.coursesCardTitle),
            enrollments: approvedCourses,
            statusLabel: context.t(AppText.approvedStatus),
          ),
          const SizedBox(height: 16),
          _CourseSection(
            title: context.t(AppText.coursesPendingTitle),
            enrollments: pendingCourses,
            statusLabel: context.t(AppText.pendingStatus),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, StudentCoursesScreen.routeName),
            icon: const Icon(Icons.playlist_add_check_circle_rounded),
            label: Text(context.t(AppText.availableCoursesTitle)),
          ),
        ],
      ),
    );
  }
}

class _CourseSection extends StatelessWidget {
  const _CourseSection({
    required this.title,
    required this.enrollments,
    required this.statusLabel,
  });

  final String title;
  final List<CourseEnrollment> enrollments;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    if (enrollments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...enrollments.map((enrollment) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(enrollment.status == EnrollmentStatus.approved
                          ? Icons.verified_rounded
                          : Icons.hourglass_top_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(enrollment.course.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            Text('${enrollment.course.code} • ${enrollment.course.schedule}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Text(statusLabel, style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
