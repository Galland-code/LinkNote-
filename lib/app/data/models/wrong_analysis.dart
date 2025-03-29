class WrongAnalysis {
  final String analysis;
  final int userId;
  final List<String> weakCategories; // 用户薄弱的知识分类
  final int wrongCount; // 错题总数
  final int consecutiveWrongCount; // 连续错题数
  final bool circuitBreakerTriggered; // 是否触发熔断
  final String aiSuggestion; // AI辅导建议

  WrongAnalysis({
    required this.analysis,
    required this.userId,
    this.weakCategories = const [],
    this.wrongCount = 0,
    this.consecutiveWrongCount = 0,
    this.circuitBreakerTriggered = false,
    this.aiSuggestion = '',
  });

  factory WrongAnalysis.fromJson(Map<String, dynamic> json) {
    return WrongAnalysis(
      analysis: json['analysis'] ?? '',
      userId: json['userId'],
      weakCategories: List<String>.from(json['weakCategories'] ?? []),
      wrongCount: json['wrongCount'] ?? 0,
      consecutiveWrongCount: json['consecutiveWrongCount'] ?? 0,
      circuitBreakerTriggered: json['circuitBreakerTriggered'] ?? false,
      aiSuggestion: json['aiSuggestion'] ?? '',
    );
  }

  // 检查是否需要熔断
  bool needsCircuitBreaker() {
    return consecutiveWrongCount >= 3 || // 连续答错3次以上
        wrongCount >= 5; // 错题总数达到5个
  }

  // 获取优先复习的类别
  List<String> getPriorityCategories() {
    if (weakCategories.isEmpty) {
      return [];
    }
    return weakCategories.take(3).toList(); // 返回前三个薄弱类别
  }
}
