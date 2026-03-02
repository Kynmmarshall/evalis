class LearningResource {
  const LearningResource({
    required this.title,
    required this.description,
    required this.format,
    required this.eta,
  });

  final String title;
  final String description;
  final String format;
  final String eta;

  factory LearningResource.fromJson(Map<String, dynamic> json) {
    return LearningResource(
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      format: (json['format'] ?? '').toString(),
      eta: (json['eta'] ?? '').toString(),
    );
  }
}
