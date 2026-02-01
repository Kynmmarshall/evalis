class MockQuestion {
  const MockQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.tip,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String tip;
}
