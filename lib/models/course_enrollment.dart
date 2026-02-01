import 'course_info.dart';

enum EnrollmentStatus { pending, approved }

class CourseEnrollment {
  const CourseEnrollment({required this.course, required this.status});

  final CourseInfo course;
  final EnrollmentStatus status;
}
