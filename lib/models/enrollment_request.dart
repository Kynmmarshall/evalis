import 'course_info.dart';

class EnrollmentRequest {
  const EnrollmentRequest({
    required this.studentName,
    required this.course,
    required this.submittedOn,
  });

  final String studentName;
  final CourseInfo course;
  final String submittedOn;
}
