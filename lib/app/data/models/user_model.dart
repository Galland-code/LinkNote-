class UserModel {
  final String id;
  final String username;
  final String email;
  final int? avatarIndex;
  final DateTime createdAt;
  final int level;
  final int experiencePoints;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarIndex,
    required this.createdAt,
    this.level = 1,
    this.experiencePoints = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarIndex: json['avatarIndex'],
      createdAt: DateTime.parse(json['createdAt']),
      level: json['level'],
      experiencePoints: json['experiencePoints'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarIndex': avatarIndex,
      'createdAt': createdAt.toIso8601String(),
      'level': level,
      'experiencePoints': experiencePoints,
    };
  }
}
