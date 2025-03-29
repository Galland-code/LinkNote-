import '../models/chaQuestion.dart';

class RevengeChallenge {
  final String id;
  final String title;
  final String category;
  final DateTime createdAt;
  final List<chaQuestion> questions;
  final int completedCount;
  final bool isCompleted;
  final int difficultyLevel; // 1-简单, 2-中等, 3-困难
  final String weaknessDescription; // 薄弱点描述

  RevengeChallenge({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.questions,
    this.completedCount = 0,
    this.isCompleted = false,
    this.difficultyLevel = 1,
    this.weaknessDescription = '',
  });

  factory RevengeChallenge.fromJson(Map<String, dynamic> json) {
    return RevengeChallenge(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      questions:
          (json['questions'] as List)
              .map((q) => chaQuestion.fromJson(q))
              .toList(),
      completedCount: json['completedCount'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      difficultyLevel: json['difficultyLevel'] ?? 1,
      weaknessDescription: json['weaknessDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'questions': questions.map((q) => q).toList(),
      'completedCount': completedCount,
      'isCompleted': isCompleted,
      'difficultyLevel': difficultyLevel,
      'weaknessDescription': weaknessDescription,
    };
  }

  RevengeChallenge copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? createdAt,
    List<chaQuestion>? questions,
    int? completedCount,
    bool? isCompleted,
    int? difficultyLevel,
    String? weaknessDescription,
  }) {
    return RevengeChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      questions: questions ?? this.questions,
      completedCount: completedCount ?? this.completedCount,
      isCompleted: isCompleted ?? this.isCompleted,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      weaknessDescription: weaknessDescription ?? this.weaknessDescription,
    );
  }
}
