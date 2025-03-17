import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/quiz_challenge.dart';
import '../models/question.dart';
import '../models/note.dart';
import '../providers/api_provider.dart';
import '../services/database_service.dart';

class QuizRepository {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // 获取所有挑战
  Future<List<QuizChallenge>> getChallenges() async {
    // 模拟数据
    List<QuizChallenge> challenges = [];

    // 示例挑战1 - 已部分完成
    challenges.add(
      QuizChallenge(
        id: '1',
        title: '计算机组成原理挑战',
        source: '计组复习笔记',
        levels: [
          QuizLevel(
            id: '1-1',
            name: '第一关：基础概念',
            description: '计算机基本组成和工作原理',
            questions: _generateMockQuestions(5, '计组复习笔记'),
            progress: 1.0,
            isCompleted: true,
          ),
          QuizLevel(
            id: '1-2',
            name: '第二关：CPU架构',
            description: 'CPU结构和指令执行',
            questions: _generateMockQuestions(5, '计组复习笔记'),
            progress: 0.6,
            isCompleted: false,
          ),
          QuizLevel(
            id: '1-3',
            name: '第三关：存储系统',
            description: '内存层次和缓存机制',
            questions: _generateMockQuestions(5, '计组复习笔记'),
            progress: 0.0,
            isCompleted: false,
          ),
        ],
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
    );

    // 示例挑战2 - 全新
    challenges.add(
      QuizChallenge(
        id: '2',
        title: '数据结构与算法挑战',
        source: '算法笔记',
        levels: [
          QuizLevel(
            id: '2-1',
            name: '第一关：线性结构',
            description: '数组、链表、栈和队列',
            questions: _generateMockQuestions(5, '算法笔记'),
            progress: 0.0,
            isCompleted: false,
          ),
          QuizLevel(
            id: '2-2',
            name: '第二关：树结构',
            description: '二叉树、平衡树和堆',
            questions: _generateMockQuestions(5, '算法笔记'),
            progress: 0.0,
            isCompleted: false,
          ),
          QuizLevel(
            id: '2-3',
            name: '第三关：图算法',
            description: '图的表示和遍历算法',
            questions: _generateMockQuestions(5, '算法笔记'),
            progress: 0.0,
            isCompleted: false,
          ),
        ],
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
    );

    return challenges;
  }

  // 从分类生成挑战
  Future<QuizChallenge> generateChallengeFromCategory(String category) async {
    // 生成3个关卡，每个关卡5个问题
    final uuid = Uuid();
    final challengeId = uuid.v4();

    return QuizChallenge(
      id: challengeId,
      title: '$category 挑战',
      source: category,
      levels: [
        QuizLevel(
          id: '$challengeId-1',
          name: '第一关：入门级',
          description: '基础知识点测试',
          questions: _generateMockQuestions(5, category),
          progress: 0.0,
          isCompleted: false,
        ),
        QuizLevel(
          id: '$challengeId-2',
          name: '第二关：进阶级',
          description: '中等难度的概念和应用',
          questions: _generateMockQuestions(5, category),
          progress: 0.0,
          isCompleted: false,
        ),
        QuizLevel(
          id: '$challengeId-3',
          name: '第三关：挑战级',
          description: '高难度知识点和综合应用',
          questions: _generateMockQuestions(5, category),
          progress: 0.0,
          isCompleted: false,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  // 从笔记生成挑战
  Future<QuizChallenge> generateChallengeFromNote(Note note) async {
    // 生成3个关卡，每个关卡5个问题
    final uuid = Uuid();
    final challengeId = uuid.v4();

    return QuizChallenge(
      id: challengeId,
      title: '${note.title} 挑战',
      source: note.title,
      levels: [
        QuizLevel(
          id: '$challengeId-1',
          name: '第一关：要点回顾',
          description: '回顾笔记中的关键概念',
          questions: _generateMockQuestions(5, note.title),
          progress: 0.0,
          isCompleted: false,
        ),
        QuizLevel(
          id: '$challengeId-2',
          name: '第二关：深入理解',
          description: '深入理解笔记内容',
          questions: _generateMockQuestions(5, note.title),
          progress: 0.0,
          isCompleted: false,
        ),
        QuizLevel(
          id: '$challengeId-3',
          name: '第三关：知识应用',
          description: '应用笔记中的知识解决问题',
          questions: _generateMockQuestions(5, note.title),
          progress: 0.0,
          isCompleted: false,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  // 保存挑战进度
  Future<void> saveChallenge(QuizChallenge challenge) async {
    // 实际应用中，这里应该调用API或更新本地数据库
    await Future.delayed(Duration(milliseconds: 300)); // 模拟网络延迟
    return;
  }

  // 生成模拟问题数据
  List<Question> _generateMockQuestions(int count, String source) {
    List<Question> questions = [];
    final uuid = Uuid();

    // 计算机组成原理相关问题
    if (source.contains('计组')) {
      questions = [
        Question(
          id: uuid.v4(),
          content: '计算机存储的最小单位是什么？',
          options: ['字节(Byte)', '位(Bit)', '字(Word)', '千字节(KB)'],
          correctOptionIndex: 'D',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
        ),
        Question(
          id: uuid.v4(),
          content: 'CPU的主要组成部分有哪些？',
          options: ['控制器、运算器、存储器', '控制器、运算器', '控制器、运算器、寄存器', '运算器、寄存器、缓存'],
          correctOptionIndex: 'C',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
        ),
        Question(
          id: uuid.v4(),
          content: '以下哪种存储器速度最快？',
          options: ['硬盘', '内存', '缓存', '寄存器'],
          correctOptionIndex: 'B',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
        ),
        Question(
          id: uuid.v4(),
          content: '什么是流水线技术？',
          options: ['一种网络传输技术', '一种让CPU能够并行执行多条指令的技术', '一种数据压缩技术', '一种文件系统'],
          correctOptionIndex: 'A',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
        ),
        Question(
          id: uuid.v4(),
          content: 'RISC和CISC分别代表什么？',
          options: [
            '精简指令集计算机和复杂指令集计算机',
            '冗余指令集计算机和紧凑指令集计算机',
            '快速指令集计算机和普通指令集计算机',
            '实时指令集计算机和通用指令集计算机',
          ],
          correctOptionIndex: 'A',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,
          wrongAnswer: '',
          category: '计算机组成原理',
        ),
      ];
    }
    // 算法相关问题
    else if (source.contains('算法')) {
      questions = [
        Question(
          id: uuid.v4(),
          content: '以下哪种排序算法的平均时间复杂度是O(n log n)？',
          options: ['冒泡排序', '插入排序', '快速排序', '选择排序'],
          correctOptionIndex: 'A',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,

          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
        ),
        Question(
          id: uuid.v4(),
          content: '二分查找算法的时间复杂度是多少？',
          options: ['O(n)', 'O(n log n)', 'O(log n)', 'O(n²)'],
          correctOptionIndex: 'A',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
        ),
        Question(
          id: uuid.v4(),
          content: '以下哪种数据结构适合实现优先队列？',
          options: ['数组', '链表', '堆', '栈'],
          correctOptionIndex: 'A',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
        ),
        Question(
          id: uuid.v4(),
          content: '哪种遍历二叉树的方法会先访问根节点？',
          options: ['前序遍历', '中序遍历', '后序遍历', '层序遍历'],
          correctOptionIndex: 'A',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
        ),
        Question(
          id: uuid.v4(),
          content: '动态规划算法通常用于解决什么类型的问题？',
          options: ['排序问题', '搜索问题', '具有重叠子问题和最优子结构的问题', '图着色问题'],
          correctOptionIndex: 'C',
          source: source,
          type: '选择题',
          difficulty: '简单',
          sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
        ),
      ];
    }
    // 默认问题
    else {
      for (int i = 0; i < count; i++) {
        questions.add(
          Question(
            id: uuid.v4(),
            content: '$source 相关问题 ${i + 1}',
            options: ['选项A', '选项B', '选项C', '选项D'],
            correctOptionIndex: 'C',
            source: source,
            type: '选择题',
            difficulty: '简单',
            sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
          ),
        );
      }
    }

    return questions;
  }

  // Generate questions from a specific note content
  // Future<List<Question>> getQuestionsFromNoteContent(Note note) async {
  //   try {
  //     // In a real app, this would be done through an API call
  //     // to a backend service that processes the note content

  //     // For now, we'll generate mock questions based on the note title
  //     List<Question> mockQuestions = [];

  //     // Generate 5-10 questions
  //     final questionCount = 5 + (note.title.length % 6); // 5-10 questions

  //     for (int i = 0; i < questionCount; i++) {
  //       mockQuestions.add(Question(
  //         id: 'note_${note.id}_question_$i',
  //         content: '关于"${note.title}"的问题 ${i + 1}',
  //         options: [
  //           '选项A - ${note.title.substring(0, note.title.length > 3 ? 3 : note.title.length)}',
  //           '选项B - ${note.title}',
  //           '选项C - ${note.category}',
  //           '选项D - 以上都不对'
  //         ],
  //         correctOptionIndex: 'A', // simple pattern for mock data
  //         source: note.title,
  //         type: '选择题',
  //         difficulty: '简单',
  //         sourceId: 1,
  //       ));
  //     }

  //     return mockQuestions;
  //   } catch (e) {
  //     print('Error generating questions from note: $e');
  //     // Return empty list if failed
  //     return [];
  //   }
  // }

  // Generate questions for a category of notes
  Future<List<Question>> getQuestionsFromCategory(String category) async {
    try {
      // Get all questions that might have this category as source
      final allQuestions = _databaseService.getAllQuestions();

      // Filter questions by category/source
      final categoryQuestions =
          allQuestions
              .where(
                (q) => q.source.toLowerCase().contains(category.toLowerCase()),
              )
              .toList();

      // If we have enough questions from the database, use those
      if (categoryQuestions.length >= 5) {
        categoryQuestions.shuffle();
        return categoryQuestions.take(10).toList();
      }

      // Otherwise, generate mock questions
      List<Question> mockQuestions = List.from(categoryQuestions);

      // Add more questions to reach at least 5
      for (int i = categoryQuestions.length; i < 5; i++) {
        mockQuestions.add(
          Question(
            id: 'category_${category}_question_$i',
            content: '关于"${category}"的问题 ${i + 1}',
            options: [
              '选项A - ${category}相关',
              '选项B - ${category}理论',
              '选项C - ${category}应用',
              '选项D - 以上都不对',
            ],
            correctOptionIndex: ' i % 4', // simple pattern for mock data
            source: category,
            type: '选择题',
            difficulty: '简单',
            sourceId: 1,
          wrongAnswer: '错误答案示例',
          category: '计算机组成原理',
          ),
        );
      }

      return mockQuestions;
    } catch (e) {
      print('Error generating questions from category: $e');
      // Return empty list if failed
      return [];
    }
  }
}
