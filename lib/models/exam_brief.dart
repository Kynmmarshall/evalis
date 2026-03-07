class ExamBrief {
  const ExamBrief({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.window,
    required this.startAt,
    required this.endAt,
    required this.launched,
  });

  final String id;
  final String title;
  final String courseCode;
  final String window;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool launched;

  bool get isScheduled => startAt != null && endAt != null;

  bool get isLive {
    if (!launched || startAt == null || endAt == null) {
      return false;
    }
    final now = DateTime.now();
    return !now.isBefore(startAt!) && now.isBefore(endAt!);
  }

  bool get isUpcoming {
    if (!launched || startAt == null) {
      return false;
    }
    return DateTime.now().isBefore(startAt!);
  }

  bool get isClosed {
    if (!launched || endAt == null) {
      return false;
    }
    return !DateTime.now().isBefore(endAt!);
  }

  factory ExamBrief.fromJson(Map<String, dynamic> json) {
    return ExamBrief(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      courseCode: (json['course_code'] ?? json['courseCode'] ?? '').toString(),
      window: (json['window'] ?? json['exam_window'] ?? json['examWindow'] ?? '').toString(),
      startAt: _parseDate(json['start_at'] ?? json['startAt']),
      endAt: _parseDate(json['end_at'] ?? json['endAt']),
      launched: json['launched'] == true,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  final parsed = DateTime.tryParse(value.toString());
  return parsed?.toLocal();
}
