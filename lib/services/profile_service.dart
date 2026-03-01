import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course_enrollment.dart';
import '../models/course_info.dart';
import '../models/user_profile.dart';

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

  final SupabaseClient _client = Supabase.instance.client;

  Future<ProfileSnapshot> fetchStudentSnapshot() async {
    final user = _requireUser();
    final profile = await _fetchProfile(user);
    final enrollments = await _fetchEnrollments(user.id);
    return ProfileSnapshot(profile: profile, enrollments: enrollments);
  }

  Future<LecturerProfileSnapshot> fetchLecturerSnapshot() async {
    final user = _requireUser();
    final profile = await _fetchProfile(user);
    final courses = await _fetchLecturerCourses(user.id, lecturerName: profile.name);
    return LecturerProfileSnapshot(profile: profile, courses: courses);
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AuthException('Please sign in again.');
    }
    return user;
  }

  Future<UserProfile> _fetchProfile(User user) async {
    final response = await _client
      .from('app_users')
        .select()
        .eq('id', user.id)
      .maybeSingle();

    if (response == null) {
      return _profileFromAuth(user);
    }

    return UserProfile.fromJson(Map<String, dynamic>.from(response));
  }

  UserProfile _profileFromAuth(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final rawName = (metadata['full_name'] ?? metadata['name'] ?? user.email ?? user.id).toString();
    final headline = (metadata['headline'] ?? '').toString();
    final role = (metadata['role'] ?? '').toString();
    return UserProfile(
      name: rawName.isEmpty ? (user.email ?? user.id) : rawName,
      email: user.email ?? '—',
      roleLabel: role.isEmpty ? 'Member' : role,
      headline: headline,
      courses: const [],
      avatarUrl: metadata['avatar_url'] as String?,
    );
  }

  Future<List<CourseEnrollment>> _fetchEnrollments(String userId) async {
    final response = await _client
        .from('course_enrollments')
        .select('status, courses ( code, title, lecturer, schedule )')
        .eq('user_id', userId);

    if (response is! List) {
      return const [];
    }

    return response
        .whereType<Map>()
        .map((row) {
          final map = Map<String, dynamic>.from(row as Map);
          try {
            return CourseEnrollment.fromJson(map);
          } on FormatException {
            return null;
          }
        })
        .whereType<CourseEnrollment>()
        .toList(growable: false);
  }

  Future<List<CourseInfo>> _fetchLecturerCourses(
    String userId, {
    required String lecturerName,
  }) async {
    final response = await _client
      .from('user_courses')
      .select('courses ( code, title, schedule, lecturer )')
      .eq('user_id', userId);

    if (response is! List) {
      return const [];
    }

    return response
        .whereType<Map>()
        .map((row) {
          final courseMap = row['courses'];
          if (courseMap is! Map) {
            return null;
          }
          final copy = Map<String, dynamic>.from(courseMap as Map);
          copy.putIfAbsent('lecturer', () => lecturerName);
          return CourseInfo.fromJson(copy);
        })
        .whereType<CourseInfo>()
        .toList(growable: false);
  }
}
