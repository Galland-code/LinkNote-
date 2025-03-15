import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password; // 通常不存储密码

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int avatarIndex;

  @HiveField(6)
  final int level;

  @HiveField(7)
  final int experiencePoints;

  @HiveField(8)
  final DateTime? updatedAt; // 允许为 null\
  @HiveField(9)
  final DateTime? lastLogin; // 允许为 null

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.avatarIndex,
    required this.level,
    required this.experiencePoints,
    this.updatedAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('Parsing UserModel from JSON: $json'); // 添加调试信息
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      createdAt: DateTime.parse(json['createdAt']),
      avatarIndex: json['avatarIndex'],
      level: json['level'],
      experiencePoints: json['experiencePoints'],
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'avatarIndex': avatarIndex,
      'level': level,
      'experiencePoints': experiencePoints,
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}
