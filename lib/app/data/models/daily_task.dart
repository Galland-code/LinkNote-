class DailyTask {
  final String id;
  final String title;
  final String? description;
  final int points;
  final bool isCompleted;
  final DateTime? completedAt;

  DailyTask({
    required this.id,
    required this.title,
    this.description,
    required this.points,
    this.isCompleted = false,
    this.completedAt,
  });
}