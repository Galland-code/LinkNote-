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
}
