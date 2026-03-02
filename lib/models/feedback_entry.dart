class FeedbackEntry {
  const FeedbackEntry({
    required this.title,
    required this.status,
    required this.detail,
    required this.isCorrect,
  });

  final String title;
  final String status;
  final String detail;
  final bool isCorrect;

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      detail: (json['detail'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true || json['is_correct'] == true,
    );
  }
}
