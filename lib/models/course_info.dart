class CourseInfo {
  const CourseInfo({
    required this.code,
    required this.title,
    required this.lecturer,
    required this.schedule,
  });

  final String code;
  final String title;
  final String lecturer;
  final String schedule;

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] ?? json['course_code'] ?? '').toString();
    final title = (json['title'] ?? json['name'] ?? 'Untitled course').toString();
    final lecturer =
        (json['lecturer'] ?? json['lecturer_name'] ?? json['teacher'] ?? '—').toString();
    final schedule = (json['schedule'] ?? json['time_slot'] ?? json['semester'] ?? '—').toString();

    return CourseInfo(
      code: code.isEmpty ? '—' : code,
      title: title,
      lecturer: lecturer,
      schedule: schedule,
    );
  }
}
