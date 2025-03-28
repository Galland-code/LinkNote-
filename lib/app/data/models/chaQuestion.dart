class chaQuestion {
  final int id;
  final String source; // 对应 document 的 fileName
  final String content;
  final List<String>? options; // 修改为可选属性
  final String answer; // 对应 answer
  final String type; // 新增 type 属性
  final String difficulty; // 新增 difficulty 属性
  final int sourceId; // 新增 sourceId，对应 document 的 id
  final String? wrongAnswer; // 保持为可选属性
  final String category; // 新增 category 属性

  chaQuestion({
    required this.id,
    required this.source,
    required this.content,
    this.options, // 修改为可选属性
    required this.answer,
    required this.type,
    required this.difficulty,
    required this.sourceId,
    this.wrongAnswer,
    required this.category,
  });

  factory chaQuestion.fromJson(Map<String, dynamic> json) {
    // 获取题目信息
    final documentData = json['document'] as Map<String, dynamic>?; // 获取文档信息
    final answer = json['answer'] as String? ?? ''; // 获取答案（默认值为空）

    // 如果没有找到 document 或 answer 字段，返回默认值
    if (documentData == null) {
      print('Error: documentData is null!');
      return chaQuestion(
        id: -1,
        source: 'Unknown',
        content: 'Unknown',
        answer: 'A',
        type: 'Unknown',
        difficulty: 'Unknown',
        sourceId: 0,
        category: 'Unknown',
      );
    }

    // 返回 Question 对象
    return chaQuestion(
      id: json['id'], // 直接使用 id 字段
      source: documentData['fileName'] ?? '未知来源', // 从 document 获取文件名
      content: json['content'] ?? '无内容', // 题目内容
      options: json['options'] != null ? List<String>.from(json['options']) : null, // 选项
      answer: answer, // 答案
      type: json['type'] ?? '未知题型', // 题型
      difficulty: json['difficulty'] ?? '未知难度', // 难度
      sourceId: documentData['id'], // document 的 id
      wrongAnswer: json['wrongAnswer'] as String?, // 错误答案（如果有）
      category: documentData['category'] ?? '未分类', // 从 document 获取分类
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

  // 辅助方法：判断是否为填空题
  bool get isFillInBlank => type == '填空题';

  // 辅助方法：判断是否为简答题
  bool get isShortAnswer => type == '简答题';

  // 辅助方法：检查答案是否正确
  bool checkAnswer(String userAnswer) {
    if (isChoiceQuestion) {
      return userAnswer.toUpperCase() == answer.toUpperCase();
    } else if (isFillInBlank) {
      return userAnswer.trim() == answer.trim();
    } else {
      // 简答题可能需要更复杂的匹配逻辑
      return userAnswer.trim().contains(answer.trim());
    }
  }
}
