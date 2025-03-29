import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class CommunityChallenge {
  final String id;
  final int creatorId;
  final String creatorName;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final List<dynamic> questions; // 存储题目列表
  final int difficultyLevel; // 1-4 对应新手、普通、进阶、地狱难度
  final int playCount; // 挑战次数
  final int passCount; // 通过次数
  final double passRate; // 通过率
  final List<CompletionRecord> completionRecords; // 通关记录
  final bool isPublished; // 是否发布到社区

  CommunityChallenge({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.questions,
    this.difficultyLevel = 1,
    this.playCount = 0,
    this.passCount = 0,
    this.passRate = 0.0,
    this.completionRecords = const [],
    this.isPublished = false,
  });

  // 根据通过率计算难度级别
  int calculateDifficultyLevel() {
    if (playCount < 5) return 1; // 新手级别（数据不足）

    if (passRate >= 0.8) return 1; // 新手级别（80%以上通过率）
    if (passRate >= 0.5) return 2; // 普通级别（50-80%通过率）
    if (passRate >= 0.2) return 3; // 进阶级别（20-50%通过率）
    return 4; // 地狱级别（低于20%通过率）
  }

  // 添加通关记录
  CommunityChallenge addCompletionRecord(CompletionRecord record) {
    List<CompletionRecord> updatedRecords = List.from(completionRecords);
    updatedRecords.add(record);

    int newPlayCount = playCount + 1;
    int newPassCount = record.isCompleted ? passCount + 1 : passCount;
    double newPassRate = newPlayCount > 0 ? newPassCount / newPlayCount : 0.0;

    return copyWith(
      playCount: newPlayCount,
      passCount: newPassCount,
      passRate: newPassRate,
      difficultyLevel: calculateDifficultyLevel(),
      completionRecords: updatedRecords,
    );
  }

  // 获取难度文本描述
  String getDifficultyText() {
    switch (difficultyLevel) {
      case 1:
        return "新手";
      case 2:
        return "普通";
      case 3:
        return "进阶";
      case 4:
        return "地狱";
      default:
        return "未知";
    }
  }

  // 复制并更新部分属性
  CommunityChallenge copyWith({
    String? title,
    String? description,
    String? category,
    List<dynamic>? questions,
    int? difficultyLevel,
    int? playCount,
    int? passCount,
    double? passRate,
    List<CompletionRecord>? completionRecords,
    bool? isPublished,
  }) {
    return CommunityChallenge(
      id: this.id,
      creatorId: this.creatorId,
      creatorName: this.creatorName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: this.createdAt,
      questions: questions ?? this.questions,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      playCount: playCount ?? this.playCount,
      passCount: passCount ?? this.passCount,
      passRate: passRate ?? this.passRate,
      completionRecords: completionRecords ?? this.completionRecords,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  factory CommunityChallenge.fromJson(Map<String, dynamic> json) {
    return CommunityChallenge(
      id: json['id'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      questions: json['questions'] ?? [],
      difficultyLevel: json['difficultyLevel'] ?? 1,
      playCount: json['playCount'] ?? 0,
      passCount: json['passCount'] ?? 0,
      passRate: json['passRate'] ?? 0.0,
      completionRecords:
          json['completionRecords'] != null
              ? List<CompletionRecord>.from(
                json['completionRecords'].map(
                  (x) => CompletionRecord.fromJson(x),
                ),
              )
              : [],
      isPublished: json['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'questions': questions,
      'difficultyLevel': difficultyLevel,
      'playCount': playCount,
      'passCount': passCount,
      'passRate': passRate,
      'completionRecords': completionRecords.map((x) => x.toJson()).toList(),
      'isPublished': isPublished,
    };
  }
}

// 通关记录类
class CompletionRecord {
  final int userId;
  final String username;
  final String userAvatar;
  final DateTime completedAt;
  final bool isCompleted;
  final int score;
  final int timeSpent; // 秒数
  final String? location; // 可选的地理位置信息

  CompletionRecord({
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.completedAt,
    required this.isCompleted,
    required this.score,
    required this.timeSpent,
    this.location,
  });

  factory CompletionRecord.fromJson(Map<String, dynamic> json) {
    return CompletionRecord(
      userId: json['userId'],
      username: json['username'],
      userAvatar: json['userAvatar'],
      completedAt: DateTime.parse(json['completedAt']),
      isCompleted: json['isCompleted'],
      score: json['score'],
      timeSpent: json['timeSpent'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'completedAt': completedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'score': score,
      'timeSpent': timeSpent,
      'location': location,
    };
  }
}
