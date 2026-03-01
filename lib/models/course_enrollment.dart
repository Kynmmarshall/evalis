import 'course_info.dart';

enum EnrollmentStatus { pending, approved }

class CourseEnrollment {
  const CourseEnrollment({required this.course, required this.status});

  final CourseInfo course;
  final EnrollmentStatus status;

  factory CourseEnrollment.fromJson(Map<String, dynamic> json) {
    final statusRaw = (json['status'] ?? '').toString().toLowerCase();
    final status = EnrollmentStatus.values.firstWhere(
      (candidate) => candidate.name == statusRaw,
      orElse: () => EnrollmentStatus.pending,
    );

    final courseMap = json['course'] ?? json['courses'];
    if (courseMap is! Map<String, dynamic>) {
      throw const FormatException('Missing course data for enrollment');
    }

    return CourseEnrollment(
      course: CourseInfo.fromJson(courseMap),
      status: status,
    );
  }
}
