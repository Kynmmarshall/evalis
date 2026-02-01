import 'course_info.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.headline,
    required this.courses,
  });

  final String name;
  final String email;
  final String roleLabel;
  final String headline;
  final List<CourseInfo> courses;
}
