import 'package:hive/hive.dart';

part 'quiz_model.g.dart'; // 这个文件将由 build_runner 自动生成

@HiveType(typeId: 0)
class Quiz {
  @HiveField(0)
  String id;

  @HiveField(1)
  String question;

  @HiveField(2)
  List<String> options;

  @HiveField(3)
  int correctAnswer;

  @HiveField(4)
  String source;

  @HiveField(5)
  String? difficulty;

  @HiveField(6)
  String? category;

  Quiz({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.source,
    this.difficulty,
    this.category,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'].toString(),
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      source: json['source'],
      difficulty: json['difficulty'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'source': source,
      'difficulty': difficulty,
      'category': category,
    };
  }
}
