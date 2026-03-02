import '../models/course_enrollment.dart';
import '../models/course_info.dart';
import '../models/enrollment_request.dart';
import 'api_client.dart';

class EnrollmentService {
  EnrollmentService._();

  static final EnrollmentService instance = EnrollmentService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<CourseInfo>> fetchAvailableCourses() async {
    final response = await _api.get('/courses') as Map<String, dynamic>;
    final courses = response['courses'] as List<dynamic>? ?? [];
    return courses.whereType<Map<String, dynamic>>().map(CourseInfo.fromJson).toList();
  }

  Future<List<CourseEnrollment>> fetchMyEnrollments() async {
    final response = await _api.get('/enrollments/me') as Map<String, dynamic>;
    final enrollments = response['enrollments'] as List<dynamic>? ?? [];
    return enrollments
        .whereType<Map<String, dynamic>>()
        .map(CourseEnrollment.fromJson)
        .toList(growable: false);
  }

  Future<void> requestEnrollment(String courseCode) async {
    await _api.post('/enrollments/requests', body: {'courseCode': courseCode});
  }

  Future<List<EnrollmentRequest>> fetchPendingApprovals() async {
    final response = await _api.get('/enrollments/pending') as Map<String, dynamic>;
    final requests = response['requests'] as List<dynamic>? ?? [];
    return requests
        .whereType<Map<String, dynamic>>()
        .map(EnrollmentRequest.fromJson)
        .toList(growable: false);
  }

  Future<void> approveRequest(EnrollmentRequest request) async {
    await _api.patch('/enrollments/${request.id}', body: {'status': 'approved'});
  }

  Future<void> rejectRequest(EnrollmentRequest request) async {
    await _api.post('/enrollments/${request.id}/reject');
  }
}
