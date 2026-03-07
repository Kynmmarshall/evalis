class MockQuestion {
  const MockQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.tip,
    this.selectedIndex,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String tip;
  final int? selectedIndex;

  factory MockQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final selectedRaw = json['selectedIndex'] ?? json['selected_index'];
    int? parsedSelection;
    if (selectedRaw is int) {
      parsedSelection = selectedRaw;
    } else if (selectedRaw is String) {
      parsedSelection = int.tryParse(selectedRaw);
    }
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
      selectedIndex: parsedSelection,
    );
  }
}
