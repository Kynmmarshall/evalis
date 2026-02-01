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
}
