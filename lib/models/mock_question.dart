class MockQuestion {
  const MockQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.tip,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String tip;

  factory MockQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    return MockQuestion(
      id: (json['id'] ?? '').toString(),
      prompt: (json['prompt'] ?? '').toString(),
      options: rawOptions is List
          ? rawOptions.map((option) => option.toString()).toList(growable: false)
          : const [],
      correctIndex: json['correctIndex'] is int
          ? json['correctIndex'] as int
          : int.tryParse(json['correct_index']?.toString() ?? '') ?? 0,
      tip: (json['tip'] ?? '').toString(),
    );
  }
}
