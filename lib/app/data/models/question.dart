class Question {
  final String id;
  final String source; // 对应 document 的 fileName
  final String content;
  final List<String>? options; // 修改为可选属性
  final String correctOptionIndex; // 对应 answer
  final String type; // 新增 type 属性
  final String difficulty; // 新增 difficulty 属性
  final int sourceId; // 新增 sourceId，对应 document 的 id
  final String? wrongAnswer; // 保持为可选属性
  final String category; // 新增 category 属性

  Question({
    required this.id,
    required this.source,
    required this.content,
    this.options, // 修改为可选属性
    required this.correctOptionIndex,
    required this.type,
    required this.difficulty,
    required this.sourceId,
    this.wrongAnswer,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final questionData = json['question'] as Map<String, dynamic>?; // 确保 questionData 不为 null
    final documentData = (json['pdfDocument1'] ?? json['document']) as Map<String, dynamic>?; // 确保 documentData 不为 null
    final answer = questionData?['answer'] as String? ?? ''; // 提供默认值

    if (questionData == null || documentData == null) {
      // 处理 questionData 或 documentData 为 null 的情况，例如抛出异常或返回 null
      print('Error: questionData or documentData is null!');
      return Question(
        id: '0',
        source: 'Unknown',
        content: 'Unknown',
        correctOptionIndex: 'A',
        type: 'Unknown',
        difficulty: 'Unknown',
        sourceId: 0,
        category: 'Unknown',
      );
    }

    return Question(
      id: (questionData['id'] as int).toString(),
      source: (documentData['fileName'] as String?) ?? '未知来源', // 提供默认值
      content: (questionData['content'] as String?) ?? '无内容', // 提供默认值
      options:
      questionData['options'] != null
          ? List<String>.from(questionData['options'])
          : null, // 如果 options 为空则使用 null
      correctOptionIndex: answer,
      type: _parseQuestionType(json['type']?.toString()),
      difficulty: (questionData['difficulty'] as String?) ?? '未知难度', // 提供默认值
      sourceId: documentData['id'] as int,
      wrongAnswer: json['wrongAnswer'] as String?, // 保持为可选属性
      category: (questionData['category'] as String?) ?? '未分类', // 提供默认值
    );
  }
  // 解析题型并标准化
  static String _parseQuestionType(String? type) {
    const typeMapping = {
      '填空题': '填空题',
      '简答题': '简答题',
      '选择题': '选择题',
    };
    return typeMapping[type] ?? '未知题型';
  }

  // 辅助方法：判断是否为选择题
  bool get isChoiceQuestion => type == '选择题';
}
