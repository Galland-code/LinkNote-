import 'question.dart';

class QuizChallenge {
  final String id;
  final String title;
  final String source; // 来源（分类名或笔记标题）
  final List<QuizLevel> levels;
  final DateTime createdAt;

  QuizChallenge({
    required this.id,
    required this.title,
    required this.source,
    required this.levels,
    required this.createdAt,
  });
}

class QuizLevel {
  final String id;
  final String name;
  final String description;
  final List<Question> questions;
  final double progress; // 0.0 - 1.0
  final bool isCompleted;

  QuizLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.questions,
    this.progress = 0.0,
    this.isCompleted = false,
  });
}