import 'course_info.dart';

class EnrollmentRequest {
  const EnrollmentRequest({
    required this.id,
    required this.studentName,
    required this.course,
    required this.submittedOn,
  });

  final String id;
  final String studentName;
  final CourseInfo course;
  final String submittedOn;

  factory EnrollmentRequest.fromJson(Map<String, dynamic> json) {
    return EnrollmentRequest(
      id: (json['id'] ?? '').toString(),
      studentName: (json['student_name'] ?? json['studentName'] ?? 'Unknown').toString(),
      course: CourseInfo.fromJson(json),
      submittedOn: (json['submitted_on'] ?? json['submittedOn'] ?? '').toString(),
    );
  }
}
