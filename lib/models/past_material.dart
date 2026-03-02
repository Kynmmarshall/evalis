class PastMaterial {
  const PastMaterial({
    required this.title,
    required this.topic,
    required this.duration,
    required this.difficulty,
  });

  final String title;
  final String topic;
  final String duration;
  final String difficulty;

  factory PastMaterial.fromJson(Map<String, dynamic> json) {
    return PastMaterial(
      title: (json['title'] ?? '').toString(),
      topic: (json['topic'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? '').toString(),
    );
  }
}
