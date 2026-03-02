class ExamBrief {
  const ExamBrief({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.window,
  });

  final String id;
  final String title;
  final String courseCode;
  final String window;

  factory ExamBrief.fromJson(Map<String, dynamic> json) {
    return ExamBrief(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      courseCode: (json['course_code'] ?? json['courseCode'] ?? '').toString(),
      window: (json['window'] ?? json['exam_window'] ?? json['examWindow'] ?? '').toString(),
    );
  }
}
