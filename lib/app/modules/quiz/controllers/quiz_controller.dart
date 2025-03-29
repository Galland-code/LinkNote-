import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:pdf/pdf.dart';
import 'package:lottie/lottie.dart';
import '../../../data/models/chaQuestion.dart';
import '../../../data/models/question.dart';
import '../../../data/models/note.dart';
import '../../../data/models/wrong_analysis.dart';
import '../../../data/models/revenge_challenge.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/repositories/note_repository.dart';
import '../../../data/services/quiz_service.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/controllers/userController.dart';
import '../../link_note/controllers/link_note_controller.dart';
import '../../question_bank/controllers/question_bank_controller.dart';

// 增加对话框类
class ChatMessage {
  final String content;
  final bool isAI;
  final bool hasHint;

  ChatMessage({required this.content, this.isAI = false, this.hasHint = false});
}

class QuizController extends GetxController {
  final messageList = <ChatMessage>[].obs;
  final currentScore = 0.obs;
  final currentProgress = 0.0.obs;
  final currentDifficulty = '基础'.obs;
  final isLoadingAI = false.obs;
  // Dependencies
  final QuestionRepository _questionRepository = Get.find<QuestionRepository>();
  final NoteRepository _noteRepository = Get.find<NoteRepository>();
  final QuizService _quizService = Get.find<QuizService>();
  final LinkNoteController _linkNoteController = Get.find<LinkNoteController>();

  // Observable variables
  final RxInt currentNavIndex = 1.obs;
  final RxList<chaQuestion> questions = <chaQuestion>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Challenge generation
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxInt selectedNoteId = (-1).obs;
  final RxString selectedDifficulty = '简单'.obs; //默认简单
  final RxBool isAnswerCorrect = false.obs;
  // Challenge history
  final RxList<Map<String, dynamic>> challengeHistory =
      <Map<String, dynamic>>[].obs;
  RxBool showDialogForGeneration = false.obs;
  RxInt noteIdToGenerateQuestions = (-1).obs; // 用于存储需要生成题目的笔记 ID
  RxInt questionCount = 5.obs; // 用于存储用户输入的题目数量

  // Current question state
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool isAnswered = false.obs;
  final RxString answer = ''.obs;

  // Timer
  final RxInt timer = 60.obs; // Timer for each question
  late Rxn<int> timerInterval; // Interval for timer updating

  // Statistics
  final RxMap<String, dynamic> quizStats = <String, dynamic>{}.obs;

  final RxString selectedPdfId = ''.obs; // 用于存储选中的 PDF ID
  // 获取 PDF 文档
  List<dynamic> pdfDocuments = <dynamic>[];

  // 错题熔断机制相关属性
  final RxList<chaQuestion> wrongQuestions = <chaQuestion>[].obs; // 错题列表
  final RxInt consecutiveWrongCount = 0.obs; // 连续答错次数
  final RxBool circuitBreakerTriggered = false.obs; // 是否触发熔断
  final RxString currentWeakCategory = ''.obs; // 当前薄弱类别
  final RxList<RevengeChallenge> revengeChallenges =
      <RevengeChallenge>[].obs; // 复仇关卡列表
  final RxBool showingAIExplanation = false.obs; // 是否正在显示AI解释
  final RxString aiExplanation = ''.obs; // AI解释内容

  @override
  void onInit() {
    super.onInit();
    onQuestionsChanged();
    if (!Get.isRegistered<LinkNoteController>()) {
      Get.put(LinkNoteController());
    }
    initializePdfData().then((_) {
      // 在笔记加载完成后再加载其他数据
      loadNotes();
      loadQuestions();
      loadChallengeHistory();
      updateQuizStats();
      startTimer();
      startQnaSession();
    });
  }

  Future<void> initializePdfData() async {
    try {
      isLoading.value = true;
      // 等待 LinkNoteController 加载 PDF 数据
      await _linkNoteController.loadPdfDocuments();

      pdfDocuments = _linkNoteController.pdfDocuments;

      // 确认数据已加载
      print('PDF Documents loaded: ${pdfDocuments.length}');

      // 加载完成后再调用 loadNotes
      await loadNotes();
    } catch (e) {
      print('Error initializing PDF data: $e');
      errorMessage.value = '加载PDF数据失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load all questions
  Future<void> loadQuestions() async {
    try {
      print("开始加载问题");
      int userId = Get.find<UserController>().userId.value;
      isLoading.value = true;
      final response = await get(
        Uri.parse(
          'http://82.157.18.189:8080/linknote/api/questions/$userId/unanswered',
        ),
      );
      if (response.statusCode == 200) {
        String decodedResponse = utf8.decode(
          response.bodyBytes,
          allowMalformed: true,
        );
        print("API响应数据: $decodedResponse"); // 检查原始响应

        final parsedResponse = jsonDecode(decodedResponse);
        print("解析后的数据类型: ${parsedResponse.runtimeType}"); // 检查数据类型
        print("解析后的数据内容: $parsedResponse"); // 检查解析后的数据

        if (parsedResponse is List) {
          questions.value =
              parsedResponse.map<chaQuestion>((item) {
                print("处理单个问题数据: $item"); // 检查每个问题的数据
                final question = chaQuestion.fromJson(item);
                print(
                  "转换后的问题对象: id=${question.id}, type=${question.type}, answer=${question.answer}",
                ); // 检查转换后的对象
                return question;
              }).toList();

          print("最终问题列表长度: ${questions.length}"); // 检查最终列表
          print(
            "第一个问题示例: ${questions.isNotEmpty ? questions[0].content : '无问题'}",
          ); // 检查具体问题
        } else {
          print("数据格式错误：期望List类型，实际是 ${parsedResponse.runtimeType}");
        }
      } else {
        print("API请求失败: ${response.statusCode}");
      }
      isLoading.value = false;
    } catch (e, stackTrace) {
      print("加载问题时出错: $e");
      print("错误堆栈: $stackTrace"); // 添加堆栈跟踪
      isLoading.value = false;
      errorMessage.value = '加载问题失败: $e';
    }
  }

  // Load all notes for selection
  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      print("加载笔记");
      // Extract unique categories
      final Set<String> categorySet = {};
      if (pdfDocuments.isEmpty) {
        print("没有pdf数据");
      }
      for (var note in pdfDocuments) {
        categorySet.add(note.category);
        print("添加类别${note.category}");
      }
      categories.value = categorySet.toList();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载笔记失败: $e';
    }
  }

  // Load challenge history
  void loadChallengeHistory() {
    // In a real app, this would fetch from the database
    // Mock data for now
    challengeHistory.value = [
      {
        'id': '1',
        'title': '计组复习笔记 - 挑战1',
        'source': '计组复习笔记',
        'questionCount': 10,
        'completedCount': 7,
        'date': DateTime.now().subtract(Duration(days: 1)),
        'questions': [], // Would contain actual questions
        'levels': 2,
        'createdAt': '2024',
      },
      {
        'id': '2',
        'title': '测试理论 - 挑战2',
        'source': '测试理论笔记',
        'questionCount': 8,
        'completedCount': 4,
        'date': DateTime.now().subtract(Duration(days: 3)),
        'questions': [], // Would contain actual questions
        'levels': 2,
        'createdAt': '2024',
      },
      {
        'id': '3',
        'title': '所有笔记 - 随机挑战',
        'source': '多个来源',
        'questionCount': 15,
        'completedCount': 15,
        'date': DateTime.now().subtract(Duration(days: 5)),
        'questions': [], // Would contain actual questions
        'levels': 2,
        'createdAt': '2024',
      },
    ];
  }

  // Update quiz statistics
  void updateQuizStats() {
    quizStats.value = _quizService.getQuizStats();
  }

  // Select category for challenge
  void selectCategory(String category) {
    selectedCategory.value = category;
    selectedNoteId.value = -1;
  }

  // Select specific note for challenge
  void selectNote(int noteId) {
    try {
      selectedNoteId.value = noteId;
      // 使用 where().toList() 和 isEmpty 检查来安全地获取笔记
      final matchingNotes = pdfDocuments.where((n) => n.id == noteId).toList();
      if (matchingNotes.isEmpty) {
        // 如果没有找到匹配的笔记，使用第一个文档（如果存在）
        if (pdfDocuments.isNotEmpty) {
          selectedCategory.value = pdfDocuments[0].category ?? '未分类';
        }
      } else {
        // 使用找到的笔记
        selectedCategory.value = matchingNotes[0].category ?? '未分类';
      }
    } catch (e) {
      print('Error in selectNote: $e');
      // 可以在这里添加错误处理逻辑
    }
  }

  // Generate a new challenge based on selection
  Future<void> generateChallenge() async {
    try {
      isLoading.value = true;

      List<chaQuestion> challengeQuestions = [];
      String challengeTitle = '';
      if (questions.isEmpty) {
        print("问题列表为空，正在重新加载...");
        await loadQuestions(); // 等待加载问题
        if (questions.isEmpty) {
          print("加载后问题列表仍为空");
          throw Exception("没有可用的问题");
        }
      }
      print("当前问题总数: ${questions.length}");

      print("查看是否选择pdf");
      print(selectedNoteId.value);
      // 如果已选pdf
      // 2. 根据不同模式选择问题
      if (selectedNoteId.value != -1) {
        print("笔记挑战模式 - 选中的笔记ID: ${selectedNoteId.value}");
        final note = pdfDocuments.firstWhere(
          (n) => n.id == selectedNoteId.value,
          orElse: () => throw Exception("未找到选中的笔记"),
        );

        challengeTitle = '${note.fileName} - 挑战';
        challengeQuestions =
            questions.where((q) => q.sourceId == note.id).toList();
        print("找到的笔记相关问题数: ${challengeQuestions.length}");

        if (challengeQuestions.isEmpty) {
          Get.toNamed(
            Routes.CHALLENGE_GENERAGE,
            arguments: {'documentId': note.id},
          );
        }
      } else if (selectedCategory.value.isNotEmpty) {
        print("分类挑战模式 - 选中的分类: ${selectedCategory.value}");
        challengeTitle = '${selectedCategory.value} - 分类挑战';
        challengeQuestions =
            questions
                .where(
                  (q) => q.category.toLowerCase().contains(
                    selectedCategory.value.toLowerCase(),
                  ),
                )
                .toList();

        print("找到的分类相关问题数: ${challengeQuestions.length}");
        if (challengeQuestions.isEmpty) {
          throw Exception("该分类没有相关问题");
        }
      } else {
        challengeTitle = '随机挑战';
        print("选择了随机挑战！🫤");
        print(questions);
        challengeQuestions = List.from(questions)..shuffle();
        challengeQuestions = challengeQuestions.take(5).toList();
        print("随机选择的问题数: ${challengeQuestions.length}");
      }
      // 3. 创建挑战前检查问题列表
      if (challengeQuestions.isEmpty) {
        throw Exception("无法生成挑战：没有找到符合条件的问题");
      }

      // 4. 创建挑战对象
      final challenge = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': challengeTitle,
        'source':
            selectedNoteId.value != -1
                ? pdfDocuments
                    .firstWhere((n) => n.id == selectedNoteId.value)
                    .fileName
                : selectedCategory.value.isNotEmpty
                ? selectedCategory.value
                : '多个来源',
        'questionCount': challengeQuestions.length,
        'completedCount': 0,
        'date': DateTime.now(),
        'questions': challengeQuestions,
        'levels': challengeQuestions,
      };
      print(
        "生成的挑战信息: ${challenge['title']}, 问题数量: ${challenge['questionCount']}",
      );

      // 5. 更新历史记录和状态
      challengeHistory.insert(0, challenge);
      currentQuestionIndex.value = 0;
      isAnswered.value = false;
      answer.value = '';

      // 6. 导航到关卡页面
      Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challenge});
    } catch (e) {
      print("生成挑战失败: $e");
      errorMessage.value = '生成挑战失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // 调用生成题目的 API
  Future<void> generateQuestionsForNote(int noteId, int questionCount) async {
    try {
      print("开始生成题目");
      print("documentId:$noteId");
      print("questionCount:$questionCount");
      final response = await post(
        Uri.parse('http://82.157.18.189:8080/linknote/api/questions/generate'),
        body: jsonEncode({'documentId': noteId, 'count': questionCount}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('题目生成成功！');
        // 可以根据需要处理返回的数据，例如更新问题列表
        loadQuestions(); // 重新加载问题
      } else {
        print('生成题目失败: ${response.statusCode}');
      }
    } catch (e) {
      print('生成题目时出错: $e');
    }
  }

  // 添加生成问题的对话框方法
  void onQuestionsChanged() {
    ever(questions, (List<chaQuestion> questionsList) {
      print("问题列表已更新，当前数量: ${questionsList.length}");
    });
  }

  // Continue an existing challenge
  void continueChallenge(Map<String, dynamic> challenge) {
    try {
      final questionsList = challenge['questions'] as List;
      questions.value = questionsList.map((q) => q as chaQuestion).toList();

      print("继续挑战 - 问题数量: ${questions.length}");
      print("第一个问题内容: ${questions.first.content}");

      currentQuestionIndex.value = challenge['completedCount'] ?? 0;
      isAnswered.value = false;
      answer.value = '';

      if ((challenge['completedCount'] ?? 0) < challenge['questionCount']) {
        Get.toNamed(Routes.QUIZ_QUESTION);
      } else {
        Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challenge});
      }
    } catch (e) {
      print("继续挑战时出错: $e");
      errorMessage.value = '继续挑战失败: $e';
    }
  }

  @override
  Future<bool> answerQuestion(String userAnswer) async {
    if (isAnswered.value) return false;
    final firstLetter =
        userAnswer.isNotEmpty ? userAnswer[0].toUpperCase() : '';
    if (firstLetter.isEmpty) return false;
    final currentQuestion = questions[currentQuestionIndex.value];
    isAnswered.value = true;
    try {
      final submission = {
        "questionId": currentQuestion.id,
        "answer": firstLetter,
      };
      print("提交答案: $submission");

      final response = await post(
        Uri.parse('http://82.157.18.189:8080/linknote/api/questions/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(submission),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        isAnswerCorrect.value = responseData['correct'] as bool;

        // 处理答题结果
        if (isAnswerCorrect.value) {
          // 答对了，重置连续错误计数
          consecutiveWrongCount.value = 0;
          currentScore.value += getDifficultyScore(currentQuestion.difficulty);
        } else {
          // 答错了，添加到错题集并增加连续错误计数
          addWrongQuestion(currentQuestion);
          consecutiveWrongCount.value++;
          // 检查是否需要触发熔断
          if (consecutiveWrongCount.value >= 3) {
            _triggerCircuitBreaker(currentQuestion);
          }
        }

        // 更新进度
        currentProgress.value =
            (currentQuestionIndex.value + 1) / questions.length;

        return isAnswerCorrect.value;
      } else {
        errorMessage.value = '提交答案失败: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage.value = '提交答案失败: $e';
      return false;
    }
  }

  // Move to next question
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      isAnswered.value = false;
      answer.value = '';
    } else {
      Get.toNamed(Routes.QUIZ_RESULT);
    }
  }

  int getDifficultyScore(String difficulty) {
    switch (difficulty) {
      case '简单':
        return 1;
      case '中等':
        return 2;
      case '困难':
        return 3;
      default:
        return 1;
    }
  }

  // Start new challenge
  void startNewChallenge() {}

  // Start a timer for each question
  void startTimer() {
    timerInterval = Rxn<int>();
    timerInterval.value = 60;

    timerInterval.listen((count) {
      if (count != null && count > 0) {
        timer.value = count - 1;
      }
    });

    // Simulate timer decrement every second
    Future.delayed(Duration(seconds: 1), () => startTimer());
  }

  // 问答相关属性
  final RxString currentQnaQuestion = ''.obs;
  final RxList<Map<String, dynamic>> qnaConversation =
      <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> qnaQuestions = [
    // {
    //   'question': '如何设计一个短链接系统？',
    //   'keywords': ['URL缩短', '哈希算法', '数据库存储', '重定向', '冲突处理'],
    //   'level': '基础',
    // },
    // {
    //   'question': '如何设计微信朋友圈的消息更新拉取？',
    //   'keywords': ['时间线', '分页加载', '缓存', '增量更新', '长连接推送'],
    //   'level': '进阶',
    // },
    // {
    //   'question': '如何优化双十一秒杀系统的高并发性能？',
    //   'keywords': ['分布式锁', '限流', '缓存预热', '异步处理', '数据库优化'],
    //   'level': '高级',
    // },
    {
      'question': 'Redis有哪些常用的数据结构？',
      'keywords': ['字符串', '列表', '集合', '有序集合', '哈希'],
      'hints': {
        '字符串': '这是Redis最基本的数据类型，通常用来存储简单的键值对，比如缓存数据。你能想到它的用途吗？',
        '列表': '这种数据结构适合存储有序的元素序列，比如消息队列。你知道它支持哪些操作吗？',
        '集合': '它用于存储无序且唯一的元素，类似于数学中的集合。可以用在哪些场景？',
        '有序集合': '它在集合基础上增加了分数排序，比如排行榜。你能举个例子吗？',
        '哈希': '适合存储对象或键值对集合，比如用户信息。你能说明它的优势吗？',
      },
      'level': '基础',
    },
  ];

  // 开始问答会话
  void startQnaSession() {
    qnaConversation.clear();
    final randomQuestion = qnaQuestions.firstWhere(
      (q) => q['question'] == 'Redis有哪些常用的数据结构？', // 为测试固定选择此题目
      orElse: () => (qnaQuestions..shuffle()).first, // 默认随机
    );
    currentQnaQuestion.value = randomQuestion['question'];
    qnaConversation.add({
      'text':
          '我们从牛客网的模拟面试题库中为你挑选了一个问题：\n${randomQuestion['question']}\n请试着列出Redis的常用数据结构吧！',
      'isUser': false,
    });
  }

  void submitQnaAnswer(String answer) {
    qnaConversation.add({'text': answer, 'isUser': true});

    final currentQ = qnaQuestions.firstWhere(
      (q) => q['question'] == currentQnaQuestion.value,
    );
    final keywords = currentQ['keywords'] as List<String>;
    final hints = currentQ['hints'] as Map<String, String>;
    final allUserAnswers = qnaConversation
        .where((msg) => msg['isUser'] == true)
        .map((msg) => msg['text'] as String)
        .join(' '); // 合并所有用户回答
    final matchedKeywords =
        keywords.where((kw) => allUserAnswers.contains(kw)).toList();
    final matchRate = matchedKeywords.length / keywords.length;
    final attemptCount =
        qnaConversation.where((msg) => msg['isUser'] == true).length;

    String feedback;
    if (matchRate >= 0.8) {
      feedback =
          '太棒了！你的回答非常全面，涵盖了${matchedKeywords.join("、")}等关键数据结构，已经没有什么遗漏了。问答结束！';
      qnaConversation.add({'text': feedback, 'isUser': false});
      Future.delayed(Duration(seconds: 2), () => Get.back());
    } else if (matchRate >= 0.4) {
      final missingKeywords =
          keywords.where((kw) => !matchedKeywords.contains(kw)).toList();
      feedback =
          '很好！你已经提到了一些重要数据结构，比如${matchedKeywords.join("、")}。不过还有${missingKeywords.length}种没提到，比如${missingKeywords.first}，${hints[missingKeywords.first]}再想想看？';
      qnaConversation.add({'text': feedback, 'isUser': false});
    } else {
      final missingKeywords =
          keywords.where((kw) => !matchedKeywords.contains(kw)).toList();
      if (attemptCount == 1) {
        feedback =
            '有点接近了！你提到了一些内容，但还不够完整。Redis有多种数据结构，比如${missingKeywords.first}，${hints[missingKeywords.first]}试着补充更多吧！';
      } else {
        feedback =
            '别灰心！目前你提到的是${matchedKeywords.isEmpty ? "还不够具体" : matchedKeywords.join("、")}，Redis还有${missingKeywords.length}种数据结构没提到。比如${missingKeywords.first}，${hints[missingKeywords.first]}可以从这个方向思考哦！';
      }
      qnaConversation.add({'text': feedback, 'isUser': false});
    }
  }

  // 选择 PDF
  void selectPdf(String pdfId) {
    selectedPdfId.value = pdfId;
    // 这里可以添加其他逻辑，比如更新相关的状态或数据
  }

  // 填空题
  Future<bool> answerFillInQuestion(String value) async {
    if (isAnswered.value) return false;
    if (value.isEmpty) return false;

    final currentQuestion = questions[currentQuestionIndex.value];
    isAnswered.value = true;
    try {
      final submission = {"questionId": currentQuestion.id, "answer": value};
      print("提交填空题答案: $submission");

      final response = await post(
        Uri.parse('http://82.157.18.189:8080/linknote/api/questions/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(submission),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        isAnswerCorrect.value = responseData['correct'] as bool;

        // 更新统计信息
        if (isAnswerCorrect.value) {
          consecutiveWrongCount.value = 0;
          currentScore.value += getDifficultyScore(currentQuestion.difficulty);
        } else {
          // 答错了，添加到错题集并增加连续错误计数
          addWrongQuestion(currentQuestion);
          consecutiveWrongCount.value++;

          // 检查是否需要触发熔断
          if (consecutiveWrongCount.value >= 3) {
            _triggerCircuitBreaker(currentQuestion);
          }
        }

        // 更新进度
        currentProgress.value =
            (currentQuestionIndex.value + 1) / questions.length;

        // 清空输入框内容
        answer.value = '';

        return isAnswerCorrect.value;
      } else {
        errorMessage.value = '提交答案失败: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      errorMessage.value = '提交答案失败: $e';
      return false;
    }
  }

  // 简答题
  Future<bool> answerShortQuestion(String value) async {
    if (isAnswered.value) return false;
    if (value.isEmpty) return false;

    final currentQuestion = questions[currentQuestionIndex.value];
    isAnswered.value = true;

    try {
      // 将用户答案和标准答案都转换为小写后进行比较
      final userAnswer = value.trim().toLowerCase();
      final correctAnswer = currentQuestion.answer.trim().toLowerCase();
      print("用户答案: $userAnswer");
      print("正确答案: $correctAnswer");

      // 判断是否包含关键词
      final isCorrect = correctAnswer
          .split(' ')
          .every((keyword) => userAnswer.contains(keyword.toLowerCase()));

      isAnswerCorrect.value = isCorrect;

      // 更新统计信息
      if (isCorrect) {
        consecutiveWrongCount.value = 0;
        currentScore.value += getDifficultyScore(currentQuestion.difficulty);
      } else {
        // 答错了，添加到错题集并增加连续错误计数
        addWrongQuestion(currentQuestion);
        consecutiveWrongCount.value++;

        // 检查是否需要触发熔断
        if (consecutiveWrongCount.value >= 3) {
          _triggerCircuitBreaker(currentQuestion);
        }
      }

      // 更新进度
      currentProgress.value =
          (currentQuestionIndex.value + 1) / questions.length;

      return isCorrect;
    } catch (e) {
      errorMessage.value = '判断答案时出错: $e';
      return false;
    }
  }

  // 添加错题到错题列表
  void addWrongQuestion(chaQuestion question) {
    if (!wrongQuestions.any((q) => q.id == question.id)) {
      wrongQuestions.add(question);
    }
  }

  // 触发错题熔断
  void _triggerCircuitBreaker(chaQuestion question) {
    circuitBreakerTriggered.value = true;
    currentWeakCategory.value = question.category;

    // 获取知识点的AI解释
    _getAIExplanation(question);

    // 创建复仇关卡
    _createRevengeChallenge(question.category);

    // 显示Lottie动画对话框
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              height: 300,
              child: Lottie.asset(
                'assets/lottie/warning.json',
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '知识点薄弱',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 172, 4, 4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '检测到您在${question.category}类题目中存在困难，已为您准备知识点解析',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 174, 9, 9),
                    ),
                    child: Text('我知道了', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );

    // 在对话框显示后，5秒后自动关闭
    Future.delayed(Duration(seconds: 5), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  // 获取AI解释
  Future<void> _getAIExplanation(chaQuestion question) async {
    try {
      showingAIExplanation.value = true;

      final response = await post(
        Uri.parse('http://82.157.18.189:8080/linknote/api/questions/explain'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'questionId': question.id,
          'category': question.category,
          'content': question.content,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        aiExplanation.value = data['explanation'] ?? '暂无解释';

        // 显示AI解释对话框
        _showAIExplanationDialog();
      } else {
        aiExplanation.value = '获取解释失败，请稍后再试';
      }
    } catch (e) {
      aiExplanation.value = '网络错误，无法获取解释';
    } finally {
      showingAIExplanation.value = false;
    }
  }

  // 显示AI解释对话框
  void _showAIExplanationDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '学伴AI解析',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Text(
                    aiExplanation.value,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: () => Get.back(), child: Text('关闭')),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _navigateToRevengeChallenge();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(
                      '挑战复仇关卡',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // 创建复仇关卡
  Future<void> _createRevengeChallenge(String category) async {
    try {
      // 从错题集中筛选同类别的题目
      List<chaQuestion> categoryWrongQuestions =
          wrongQuestions
              .where((q) => q.category.toLowerCase() == category.toLowerCase())
              .toList();

      // 确保至少有3道题目
      if (categoryWrongQuestions.length < 3) {
        // 如果不够，从所有题目中补充
        final additionalQuestions =
            questions
                .where(
                  (q) => q.category.toLowerCase() == category.toLowerCase(),
                )
                .where(
                  (q) => !categoryWrongQuestions.any((wq) => wq.id == q.id),
                )
                .take(3 - categoryWrongQuestions.length)
                .toList();

        categoryWrongQuestions.addAll(additionalQuestions);
      }

      // 打乱顺序
      categoryWrongQuestions.shuffle();

      // 创建复仇关卡
      final revengeChallenge = RevengeChallenge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '${category}复仇关卡',
        category: category,
        createdAt: DateTime.now(),
        questions: categoryWrongQuestions,
        difficultyLevel: 2,
        weaknessDescription: '针对${category}知识点的薄弱环节定制训练',
      );

      // 添加到复仇关卡列表
      revengeChallenges.add(revengeChallenge);
    } catch (e) {
      print('创建复仇关卡出错: $e');
    }
  }

  // 导航到复仇关卡
  void _navigateToRevengeChallenge() {
    if (revengeChallenges.isEmpty) return;

    final latestChallenge = revengeChallenges.last;

    // 构建挑战对象
    final challenge = {
      'id': latestChallenge.id,
      'title': latestChallenge.title,
      'source': latestChallenge.category,
      'questionCount': latestChallenge.questions.length,
      'completedCount': 0,
      'date': DateTime.now(),
      'questions': latestChallenge.questions,
      'levels': latestChallenge.questions,
    };

    // 导航到关卡页面
    Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challenge});
  }

  // 获取复仇关卡列表
  List<RevengeChallenge> getRevengeChallenges() {
    return revengeChallenges;
  }

  // 重置熔断状态
  void resetCircuitBreaker() {
    circuitBreakerTriggered.value = false;
    consecutiveWrongCount.value = 0;
    currentWeakCategory.value = '';
  }
}
