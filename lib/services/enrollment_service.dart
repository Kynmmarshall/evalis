import 'dart:async';

import '../models/course_info.dart';
import '../models/enrollment_request.dart';

class EnrollmentService {
  Future<void> requestEnrollment(CourseInfo course) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }

  Future<void> approveRequest(EnrollmentRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> rejectRequest(EnrollmentRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }
}
