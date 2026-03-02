import 'dart:typed_data';
import 'package:mime/mime.dart';

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
  static const String _avatarBucket = 'profile-photos';

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
    final merged = Map<String, dynamic>.from(response)
      ..putIfAbsent('avatar_url', () => user.userMetadata?['avatar_url']);
    return UserProfile.fromJson(merged);
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

  Future<String> uploadAvatar({
    required Uint8List bytes,
    String? contentType,
  }) async {
    final user = _requireUser();
    final storage = _client.storage.from(_avatarBucket);
    final mime = contentType ?? lookupMimeType('', headerBytes: bytes);
    final extension = _extensionFromMime(mime);
    final filePath = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

    await storage.uploadBinary(
      filePath,
      bytes,
      fileOptions: FileOptions(contentType: mime ?? 'image/jpeg', upsert: true),
    );

    final publicUrl = storage.getPublicUrl(filePath);

    await _client.auth.updateUser(
      UserAttributes(data: {'avatar_url': publicUrl}),
    );

    await _tryUpdateAppUserAvatar(user.id, publicUrl);

    return publicUrl;
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

  Future<void> _tryUpdateAppUserAvatar(String userId, String avatarUrl) async {
    try {
      await _client.from('app_users').update({'avatar_url': avatarUrl}).eq('id', userId);
    } on PostgrestException catch (error) {
      if (error.code == '42703') {
        return;
      }
      rethrow;
    }
  }

  Future<List<CourseEnrollment>> _fetchEnrollments(String userId) async {
    final List<dynamic> response = await _client
        .from('course_enrollments')
        .select('status, courses ( code, title, lecturer, schedule )')
        .eq('user_id', userId);

    if (response.isEmpty) {
      return const [];
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map((row) {
          final map = Map<String, dynamic>.from(row);
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
    final List<dynamic> response = await _client
      .from('user_courses')
      .select('courses ( code, title, schedule, lecturer )')
      .eq('user_id', userId);

    if (response.isEmpty) {
      return const [];
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map((row) {
          final courseMap = row['courses'];
          if (courseMap is! Map<String, dynamic>) {
            return null;
          }
          final copy = Map<String, dynamic>.from(courseMap);
          copy.putIfAbsent('lecturer', () => lecturerName);
          return CourseInfo.fromJson(copy);
        })
        .whereType<CourseInfo>()
        .toList(growable: false);
  }
}
