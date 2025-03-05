import 'package:hive/hive.dart';

part 'user_model.g.dart'; // 这个文件将由 build_runner 自动生成

@HiveType(typeId: 3)
class User {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String? email;

  @HiveField(3)
  int perfectStreak;

  @HiveField(4)
  int loginStreak;

  @HiveField(5)
  List<String> unlockedAchievementIds;

  @HiveField(6)
  int totalQuizzesTaken;

  @HiveField(7)
  int totalCorrectAnswers;

  @HiveField(8)
  double averageScore;

  User({
    required this.id,
    required this.username,
    this.email,
    required this.perfectStreak,
    required this.loginStreak,
    required this.unlockedAchievementIds,
    required this.totalQuizzesTaken,
    required this.totalCorrectAnswers,
    required this.averageScore,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      perfectStreak: json['perfectStreak'],
      loginStreak: json['loginStreak'],
      unlockedAchievementIds: (json['unlockedAchievements'] as List)
          .map((e) => e['id'].toString())
          .toList(),
      totalQuizzesTaken: json['totalQuizzesTaken'],
      totalCorrectAnswers: json['totalCorrectAnswers'],
      averageScore: json['averageScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'perfectStreak': perfectStreak,
      'loginStreak': loginStreak,
      'unlockedAchievementIds': unlockedAchievementIds,
      'totalQuizzesTaken': totalQuizzesTaken,
      'totalCorrectAnswers': totalCorrectAnswers,
      'averageScore': averageScore,
    };
  }
}