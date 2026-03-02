class StudentScore {
  const StudentScore({required this.name, required this.score, required this.sent});

  final String name;
  final int score;
  final bool sent;

  factory StudentScore.fromJson(Map<String, dynamic> json) {
    return StudentScore(
      name: (json['name'] ?? '').toString(),
      score: json['score'] is int ? json['score'] as int : int.tryParse(json['score']?.toString() ?? '') ?? 0,
      sent: json['sent'] == true,
    );
  }
}
