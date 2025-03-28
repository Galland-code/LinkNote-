class WrongAnalysis {
  final String analysis;
  final int userId;

  WrongAnalysis({
    required this.analysis,
    required this.userId,
  });

  factory WrongAnalysis.fromJson(Map<String, dynamic> json) {
    return WrongAnalysis(
      analysis: json['analysis'] ?? '',
      userId: json['userId'],
    );
  }
}