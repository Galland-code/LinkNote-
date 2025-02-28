class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    this.unlockedAt,
    this.isUnlocked = false,
  });
}

// Sample data
final List<Achievement> sampleAchievements = [
  Achievement(
    id: '1',
    title: '连续完美无错',
    description: '连续完成3组挑战而不犯错',
    iconPath: 'assets/icons/trophy.png',
    unlockedAt: DateTime(2024, 12, 10),
    isUnlocked: true,
  ),
  Achievement(
    id: '2',
    title: '连续登录',
    description: '连续3天登录应用',
    iconPath: 'assets/icons/cup.png',
    unlockedAt: DateTime(2024, 12, 1),
    isUnlocked: true,
  ),
  Achievement(
    id: '3',
    title: '关卡错误率',
    description: '错误率低于10%',
    iconPath: 'assets/icons/smile.png',
    unlockedAt: null,
    isUnlocked: true,
  ),
  Achievement(
    id: '4',
    title: 'NoGameNo Notebook',
    description: '完成所有挑战',
    iconPath: 'assets/icons/gameboy.png',
    unlockedAt: null,
    isUnlocked: true,
  ),
];