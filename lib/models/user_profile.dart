import 'course_info.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.headline,
    required this.courses,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String roleLabel;
  final String headline;
  final List<CourseInfo> courses;
  final String? avatarUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawName = (json['full_name'] ?? json['name'] ?? '').toString();
    final rawEmail = (json['email'] ?? json['email_address'] ?? '').toString();
    final rawRole = (json['role_label'] ?? json['role'] ?? '').toString();
    final rawHeadline = (json['headline'] ?? json['bio'] ?? '').toString();
    final coursesData = json['courses'];
    final List<CourseInfo> courses = coursesData is List
        ? coursesData
            .whereType<Map<String, dynamic>>()
            .map(CourseInfo.fromJson)
            .toList(growable: false)
        : const [];

    return UserProfile(
      name: rawName.isEmpty ? '—' : rawName,
      email: rawEmail.isEmpty ? '—' : rawEmail,
      roleLabel: rawRole.isEmpty ? '—' : rawRole,
      headline: rawHeadline,
      courses: courses,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
