class StudentScore {
  const StudentScore({
    required this.studentId,
    required this.name,
    required this.answeredQuestions,
    required this.correctAnswers,
  });

  final String studentId;
  final String name;
  final int answeredQuestions;
  final int correctAnswers;

  factory StudentScore.fromJson(Map<String, dynamic> json) {
    return StudentScore(
      studentId: (json['studentId'] ?? json['student_id'] ?? '').toString(),
      name: (json['name'] ?? json['studentName'] ?? '').toString(),
      answeredQuestions: json['answeredQuestions'] is int
          ? json['answeredQuestions'] as int
          : int.tryParse(json['answeredQuestions']?.toString() ?? '') ?? 0,
      correctAnswers: json['correctAnswers'] is int
          ? json['correctAnswers'] as int
          : int.tryParse(json['correctAnswers']?.toString() ?? '') ?? 0,
    );
  }
}
