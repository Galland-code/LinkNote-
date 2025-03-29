import 'package:hive/hive.dart';
import 'dart:math' as math;

// part 'user_achievement.g.dart'; // 需要运行hive生成器生成这个文件

@HiveType(typeId: 10)
class UserAchievement {
  @HiveField(0)
  final int userId;

  @HiveField(1)
  final int level;

  @HiveField(2)
  final int experiencePoints;

  @HiveField(3)
  final int nextLevelExperience;

  @HiveField(4)
  final String currentTitle;

  @HiveField(5)
  final String currentFrame;

  @HiveField(6)
  final List<String> unlockedTitles;

  @HiveField(7)
  final List<String> unlockedFrames;

  @HiveField(8)
  final List<String> unlockedAchievements;

  @HiveField(9)
  final List<String> unlockedBadges;

  @HiveField(10)
  final int correctQuestions;

  @HiveField(11)
  final int totalQuestions;

  @HiveField(12)
  final Map<String, int> categoryProgress;

  @HiveField(13)
  final int powerScore; // 战力值

  @HiveField(14)
  final DateTime updatedAt;

  UserAchievement({
    required this.userId,
    this.level = 1,
    this.experiencePoints = 0,
    this.nextLevelExperience = 100,
    this.currentTitle = "初学者",
    this.currentFrame = "default",
    this.unlockedTitles = const ["初学者"],
    this.unlockedFrames = const ["default"],
    this.unlockedAchievements = const [],
    this.unlockedBadges = const [],
    this.correctQuestions = 0,
    this.totalQuestions = 0,
    this.categoryProgress = const {},
    this.powerScore = 0,
    required this.updatedAt,
  });

  // 计算战力值
  int calculatePowerScore() {
    // 基础分 = 等级 * 10
    int baseScore = level * 10;

    // 精准度分 = 正确率 * 50（如果有答题记录）
    int accuracyScore =
        totalQuestions > 0
            ? ((correctQuestions / totalQuestions) * 50).round()
            : 0;

    // 知识覆盖分 = 已解锁成就数 * 5 + 已解锁徽章数 * 10
    int coverageScore =
        unlockedAchievements.length * 5 + unlockedBadges.length * 10;

    // 多样性分 = 已解锁类别数 * 15
    int diversityScore = categoryProgress.keys.length * 15;

    return baseScore + accuracyScore + coverageScore + diversityScore;
  }

  // 克隆并更新部分属性
  UserAchievement copyWith({
    int? level,
    int? experiencePoints,
    int? nextLevelExperience,
    String? currentTitle,
    String? currentFrame,
    List<String>? unlockedTitles,
    List<String>? unlockedFrames,
    List<String>? unlockedAchievements,
    List<String>? unlockedBadges,
    int? correctQuestions,
    int? totalQuestions,
    Map<String, int>? categoryProgress,
    int? powerScore,
    DateTime? updatedAt,
  }) {
    return UserAchievement(
      userId: this.userId,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      nextLevelExperience: nextLevelExperience ?? this.nextLevelExperience,
      currentTitle: currentTitle ?? this.currentTitle,
      currentFrame: currentFrame ?? this.currentFrame,
      unlockedTitles: unlockedTitles ?? this.unlockedTitles,
      unlockedFrames: unlockedFrames ?? this.unlockedFrames,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      correctQuestions: correctQuestions ?? this.correctQuestions,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      powerScore: powerScore ?? this.powerScore,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 增加经验值并检查升级
  UserAchievement addExperience(int exp) {
    int newExp = experiencePoints + exp;
    int newLevel = level;
    int newNextLevelExp = nextLevelExperience;

    // 检查是否升级
    while (newExp >= newNextLevelExp) {
      newExp -= newNextLevelExp;
      newLevel++;
      newNextLevelExp = calculateNextLevelExperience(newLevel);
    }

    return copyWith(
      level: newLevel,
      experiencePoints: newExp,
      nextLevelExperience: newNextLevelExp,
      updatedAt: DateTime.now(),
      powerScore: calculatePowerScore(), // 更新战力值
    );
  }

  // 计算下一级所需经验值
  int calculateNextLevelExperience(int level) {
    // 经验曲线: 100 * (1.2^(level-1))
    return (100 * math.pow(1.2, level - 1)).round();
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      userId: json['userId'],
      level: json['level'] ?? 1,
      experiencePoints: json['experiencePoints'] ?? 0,
      nextLevelExperience: json['nextLevelExperience'] ?? 100,
      currentTitle: json['currentTitle'] ?? "初学者",
      currentFrame: json['currentFrame'] ?? "default",
      unlockedTitles: List<String>.from(json['unlockedTitles'] ?? ["初学者"]),
      unlockedFrames: List<String>.from(json['unlockedFrames'] ?? ["default"]),
      unlockedAchievements: List<String>.from(
        json['unlockedAchievements'] ?? [],
      ),
      unlockedBadges: List<String>.from(json['unlockedBadges'] ?? []),
      correctQuestions: json['correctQuestions'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      categoryProgress: Map<String, int>.from(json['categoryProgress'] ?? {}),
      powerScore: json['powerScore'] ?? 0,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'level': level,
      'experiencePoints': experiencePoints,
      'nextLevelExperience': nextLevelExperience,
      'currentTitle': currentTitle,
      'currentFrame': currentFrame,
      'unlockedTitles': unlockedTitles,
      'unlockedFrames': unlockedFrames,
      'unlockedAchievements': unlockedAchievements,
      'unlockedBadges': unlockedBadges,
      'correctQuestions': correctQuestions,
      'totalQuestions': totalQuestions,
      'categoryProgress': categoryProgress,
      'powerScore': powerScore,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
