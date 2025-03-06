class Question {
  final String id;
  final String source;
  final String content;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.id,
    required this.source,
    required this.content,
    required this.options,
    required this.correctOptionIndex,
  });
}