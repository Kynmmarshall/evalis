import 'student_score.dart';

class ExamScorebook {
  const ExamScorebook({
    required this.examId,
    required this.title,
    required this.courseCode,
    required this.examWindow,
    required this.questionCount,
    required this.closedAt,
    required this.students,
  });

  final String examId;
  final String title;
  final String courseCode;
  final String examWindow;
  final int questionCount;
  final DateTime? closedAt;
  final List<StudentScore> students;

  factory ExamScorebook.fromJson(Map<String, dynamic> json) {
    final students = (json['students'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(StudentScore.fromJson)
        .toList(growable: false);
    return ExamScorebook(
      examId: (json['examId'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      courseCode: (json['courseCode'] ?? '').toString(),
      examWindow: (json['examWindow'] ?? '').toString(),
      questionCount: json['questionCount'] is int
          ? json['questionCount'] as int
          : int.tryParse(json['questionCount']?.toString() ?? '') ?? 0,
      closedAt: _parseDate(json['endAt'] ?? json['closedAt']),
      students: students,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toLocal();
  }
  final parsed = DateTime.tryParse(value.toString());
  return parsed?.toLocal();
}
