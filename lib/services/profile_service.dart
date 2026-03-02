import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import '../models/course_enrollment.dart';
import '../models/course_info.dart';
import '../models/user_profile.dart';
import 'api_client.dart';
import 'auth_service.dart';

class ProfileSnapshot {
  const ProfileSnapshot({required this.profile, required this.enrollments});

  final UserProfile profile;
  final List<CourseEnrollment> enrollments;

  List<CourseEnrollment> byStatus(EnrollmentStatus status) =>
      enrollments.where((enrollment) => enrollment.status == status).toList();
}

class LecturerProfileSnapshot {
  const LecturerProfileSnapshot({required this.profile, required this.courses});

  final UserProfile profile;
  final List<CourseInfo> courses;
}

class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  final ApiClient _api = ApiClient.instance;

  Future<ProfileSnapshot> fetchStudentSnapshot() async {
    final response = await _api.get('/profile/student') as Map<String, dynamic>;
    final profile = UserProfile.fromJson(response['profile'] as Map<String, dynamic>);
    final enrollments = (response['enrollments'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CourseEnrollment.fromJson)
        .toList(growable: false);
    return ProfileSnapshot(profile: profile, enrollments: enrollments);
  }

  Future<LecturerProfileSnapshot> fetchLecturerSnapshot() async {
    final response = await _api.get('/profile/lecturer') as Map<String, dynamic>;
    final profile = UserProfile.fromJson(response['profile'] as Map<String, dynamic>);
    final courses = (response['courses'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CourseInfo.fromJson)
        .toList(growable: false);
    return LecturerProfileSnapshot(profile: profile, courses: courses);
  }

  Future<String> uploadAvatar({
    required Uint8List bytes,
    String? contentType,
  }) async {
    final authToken = AuthService.instance.token;
    if (authToken == null) {
      throw const AuthException('Sign in required');
    }
    final extension = _extensionFromMime(contentType ?? lookupMimeType('', headerBytes: bytes));
    final request = http.MultipartRequest('POST', _api.resolve('/profile/avatar'))
      ..headers['Authorization'] = 'Bearer $authToken'
      ..files.add(http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: 'avatar.$extension',
      ));

    final result = await _api.send(request) as Map<String, dynamic>;
    final avatarUrl = result['avatarUrl'] as String?;
    if (avatarUrl == null) {
      throw const ApiException('Avatar upload failed');
    }
    return avatarUrl;
  }

  String _extensionFromMime(String? contentType) {
    if (contentType == null) {
      return 'jpg';
    }
    final parts = contentType.split('/');
    if (parts.length == 2 && parts.last.isNotEmpty) {
      return parts.last;
    }
    return 'jpg';
  }
}
