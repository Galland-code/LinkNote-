import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
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
import '../../../data/services/achievement_service.dart';

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
    if (!Get.isRegistered<AchievementService>()) {
      Get.put(AchievementService());
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

          // 更新成就系统 - 答对题目
          final achievementService = Get.find<AchievementService>();
          // 根据难度给予不同经验值奖励
          int expReward = getDifficultyScore(currentQuestion.difficulty) * 5;
          await achievementService.addExperience(
            expReward,
            category: currentQuestion.category,
          );
          await achievementService.updateQuestionStats(
            true,
            currentQuestion.category,
          );

          // 首次答对，解锁成就
          if (currentScore.value ==
              getDifficultyScore(currentQuestion.difficulty)) {
            achievementService.unlockAchievement('first_correct');
          }

          // 检查连续答对成就
          if (quizStats['currentStreak'] >= 3) {
            achievementService.unlockAchievement('streak_3');
          }
        } else {
          // 答错了，添加到错题集并增加连续错误计数
          addWrongQuestion(currentQuestion);
          consecutiveWrongCount.value++;

          // 更新成就系统 - 答错题目
          final achievementService = Get.find<AchievementService>();
          await achievementService.updateQuestionStats(
            false,
            currentQuestion.category,
          );

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

    // 解锁"初次问答"成就
    if (Get.isRegistered<AchievementService>()) {
      final achievementService = Get.find<AchievementService>();
      achievementService.unlockAchievement('first_question');
    }
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
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _getAIExplanation(question),
                        child: Text('获取学伴分析'),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 174, 9, 9),
                        ),
                        child: Text(
                          '我知道了',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  // 获取AI解释
  Future<void> _getAIExplanation(chaQuestion question) async {
    try {
      showingAIExplanation.value = true;

      // 首先尝试调用原始API
      try {
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
        } else {
          // API调用失败，使用模拟数据
          print('API调用失败，状态码: ${response.statusCode}，使用模拟数据');
          final mockExplanation = _getMockAIExplanation(question);
          aiExplanation.value = mockExplanation;
        }
      } catch (apiError) {
        // API调用异常，使用模拟数据
        print('API调用异常: $apiError，使用模拟数据');
        final mockExplanation = _getMockAIExplanation(question);
        aiExplanation.value = mockExplanation;
      }

      // 显示AI解释对话框
      _showAIExplanationDialog();
    } catch (e) {
      print('获取AI解释失败: $e');
      aiExplanation.value = '网络错误，无法获取解释';
    } finally {
      showingAIExplanation.value = false;
    }
  }

  // 生成模拟的AI解释数据
  String _getMockAIExplanation(chaQuestion question) {
    // 根据问题类别提供不同的解释模板
    final Map<String, String> explanationTemplates = {
      '计算机网络':
          '关于${question.content}的解释：\n\n计算机网络中的${_extractKeyword(question.content)}是指在数据通信过程中的关键机制。它主要负责确保数据包能够正确地从源地址传输到目标地址。\n\n在OSI七层模型中，这属于${_getRandomLayer()}层的功能。掌握这个概念对理解整个网络通信流程非常重要。\n\n常见的相关协议包括TCP、UDP和HTTP等。你可以通过查阅《计算机网络（第7版）》谭建升著作了解更多信息。',

      '操作系统':
          '针对"${question.content}"的详细解答：\n\n操作系统中的${_extractKeyword(question.content)}机制是系统稳定运行的关键部分。它主要解决进程间通信、资源分配或内存管理的问题。\n\n这一概念最早由${_getRandomResearcher()}提出，现代操作系统如Linux、Windows都广泛应用了这一机制。\n\n掌握这个知识点需要理解操作系统的基本原理和进程管理方法。建议可以结合实际例子来加深理解。',

      '数据结构':
          '关于${question.content}的知识点讲解：\n\n在数据结构中，${_extractKeyword(question.content)}是一种重要的数据组织方式，其时间复杂度通常为${_getRandomComplexity()}。\n\n该结构的主要优势在于${_getRandomAdvantage()}，但缺点是${_getRandomDisadvantage()}。\n\n在实际应用中，${_extractKeyword(question.content)}常用于解决${_getRandomApplication()}问题。掌握其原理对算法设计和优化有很大帮助。',

      '数据库':
          '针对"${question.content}"的解析：\n\n在数据库系统中，${_extractKeyword(question.content)}是保证数据${_getRandomDatabaseFeature()}的重要机制。\n\nSQL中实现这一功能的语法是：\n```sql\n${_getRandomSQLExample()}\n```\n\n在实际应用中，正确使用这一特性可以有效提高查询效率和数据安全性。不同的数据库管理系统（如MySQL、PostgreSQL）可能有细微的实现差异。',

      '人工智能':
          '关于"${question.content}"的AI解析：\n\n在人工智能领域，${_extractKeyword(question.content)}是${_getRandomAIField()}的核心概念。这一技术基于${_getRandomAlgorithm()}算法，能够有效解决${_getRandomProblem()}问题。\n\n近年来，随着深度学习的发展，该技术已经取得了显著进步。了解这一概念对掌握现代AI系统的工作原理至关重要。\n\n建议深入学习相关数学基础和算法实现，以便更好地应用这一技术。',

      '软件工程':
          '对于"${question.content}"的详细讲解：\n\n在软件工程中，${_extractKeyword(question.content)}是确保软件质量的关键实践。它在${_getRandomSoftwarePhase()}阶段尤为重要。\n\n采用这一方法可以有效减少bug，提高代码可维护性和可扩展性。敏捷开发和DevOps实践中都强调了这一点。\n\n掌握这一概念需要理解软件开发生命周期和团队协作流程。建议结合实际项目经验来加深理解。',

      '微服务':
          '关于"${question.content}"的解析：\n\n在微服务架构中，${_extractKeyword(question.content)}是实现服务间通信和协调的重要模式。它解决了分布式系统中的${_getRandomDistributedProblem()}问题。\n\n实现这一模式常用的技术包括${_getRandomMicroserviceTech()}等。采用这种方式可以提高系统的弹性和可扩展性。\n\n理解这一概念需要掌握基本的分布式系统理论和微服务设计原则。建议学习Spring Cloud、Kubernetes等相关技术栈深化理解。',

      '前端开发':
          '针对"${question.content}"的前端知识解析：\n\n在前端开发中，${_extractKeyword(question.content)}是创建交互式用户界面的重要技术。它基于${_getRandomFrontendTech()}，能够有效提升用户体验。\n\n实现这一功能的代码示例：\n```javascript\n${_getRandomJSExample()}\n```\n\n掌握这一技术需要理解DOM操作、事件处理和状态管理等基础知识。随着前端框架的发展，这一概念的实现方式也在不断演进。',

      '算法':
          '对"${question.content}"算法的详细解析：\n\n${_extractKeyword(question.content)}算法的核心思想是${_getRandomAlgorithmIdea()}。其时间复杂度为${_getRandomComplexity()}，空间复杂度为${_getRandomComplexity()}。\n\n该算法的伪代码如下：\n```\n${_getRandomPseudocode()}\n```\n\n在实际应用中，这一算法常用于解决${_getRandomAlgorithmApplication()}问题。理解其原理需要掌握基本的数据结构和算法设计技巧。',
    };

    // 获取问题类别对应的模板，如果没有匹配的类别则使用通用模板
    String category = question.category.toLowerCase();
    String template = '';

    for (var key in explanationTemplates.keys) {
      if (category.contains(key.toLowerCase())) {
        template = explanationTemplates[key]!;
        break;
      }
    }

    // 如果没有找到匹配的类别，使用通用模板
    if (template.isEmpty) {
      template =
          '关于"${question.content}"的解析：\n\n这个问题涉及到${_extractKeyword(question.content)}概念，是该领域的基础知识点。\n\n正确理解这一概念需要掌握相关的理论基础和实际应用场景。建议可以参考权威教材和在线资源进行深入学习。\n\n解答这类问题的关键在于理清概念之间的关系，并结合实例加深理解。希望这个解释对你有所帮助！';
    }

    return template;
  }

  // 从问题内容中提取关键词
  String _extractKeyword(String content) {
    final keywords = [
      '路由协议',
      '进程调度',
      '死锁检测',
      '内存管理',
      'TCP协议',
      '堆栈结构',
      '红黑树',
      'B+树',
      '哈希表',
      '链表',
      'SQL注入',
      '事务隔离',
      '索引优化',
      '范式',
      '深度学习',
      '神经网络',
      '机器学习',
      '自然语言处理',
      '敏捷开发',
      '测试驱动',
      '持续集成',
      '设计模式',
      '服务发现',
      '负载均衡',
      '熔断机制',
      '服务网格',
      'React组件',
      'Vue响应式',
      'DOM操作',
      '状态管理',
      '排序算法',
      '搜索算法',
      '动态规划',
      '贪心算法',
    ];

    // 尝试从内容中找到匹配的关键词
    for (var keyword in keywords) {
      if (content.contains(keyword)) {
        return keyword;
      }
    }

    // 如果没有找到，返回内容的前几个字作为关键词
    final words = content.split(' ');
    return words.length > 2
        ? words.sublist(0, 2).join(' ')
        : content.substring(0, content.length > 10 ? 10 : content.length);
  }

  // 随机生成OSI模型层
  String _getRandomLayer() {
    final layers = ['物理', '数据链路', '网络', '传输', '会话', '表示', '应用'];
    return layers[DateTime.now().millisecondsSinceEpoch % layers.length];
  }

  // 随机生成研究者名字
  String _getRandomResearcher() {
    final researchers = [
      'Dijkstra',
      'Lamport',
      'Tanenbaum',
      'Silberschatz',
      'Thompson',
      'Ritchie',
    ];
    return researchers[DateTime.now().millisecondsSinceEpoch %
        researchers.length];
  }

  // 随机生成时间复杂度
  String _getRandomComplexity() {
    final complexities = [
      'O(1)',
      'O(log n)',
      'O(n)',
      'O(n log n)',
      'O(n²)',
      'O(2ⁿ)',
    ];
    return complexities[DateTime.now().millisecondsSinceEpoch %
        complexities.length];
  }

  // 随机生成数据结构优势
  String _getRandomAdvantage() {
    final advantages = ['查找效率高', '插入删除操作简单', '空间利用率高', '适合频繁修改的场景', '支持快速随机访问'];
    return advantages[DateTime.now().millisecondsSinceEpoch %
        advantages.length];
  }

  // 随机生成数据结构劣势
  String _getRandomDisadvantage() {
    final disadvantages = ['内存占用较大', '不适合频繁插入删除', '实现复杂', '查找效率较低', '不支持随机访问'];
    return disadvantages[DateTime.now().millisecondsSinceEpoch %
        disadvantages.length];
  }

  // 随机生成应用场景
  String _getRandomApplication() {
    final applications = ['搜索引擎', '数据库索引', '文件系统', '网络路由', '游戏开发', '图形处理'];
    return applications[DateTime.now().millisecondsSinceEpoch %
        applications.length];
  }

  // 随机生成数据库特性
  String _getRandomDatabaseFeature() {
    final features = ['一致性', '完整性', '原子性', '隔离性', '持久性', '安全性'];
    return features[DateTime.now().millisecondsSinceEpoch % features.length];
  }

  // 随机生成SQL示例
  String _getRandomSQLExample() {
    final examples = [
      'SELECT column_name FROM table_name WHERE condition;',
      'CREATE INDEX idx_name ON table_name(column_name);',
      'BEGIN TRANSACTION;\n  UPDATE accounts SET balance = balance - 100 WHERE id = 1;\n  UPDATE accounts SET balance = balance + 100 WHERE id = 2;\nCOMMIT;',
      'CREATE VIEW view_name AS SELECT column_name FROM table_name;',
      'SELECT t1.column_name, t2.column_name FROM table1 t1 JOIN table2 t2 ON t1.id = t2.id;',
    ];
    return examples[DateTime.now().millisecondsSinceEpoch % examples.length];
  }

  // 随机生成AI领域
  String _getRandomAIField() {
    final fields = ['计算机视觉', '自然语言处理', '强化学习', '知识表示', '推荐系统', '专家系统'];
    return fields[DateTime.now().millisecondsSinceEpoch % fields.length];
  }

  // 随机生成算法名称
  String _getRandomAlgorithm() {
    final algorithms = ['卷积神经网络', '循环神经网络', '变换器', '决策树', '支持向量机', 'K-means聚类'];
    return algorithms[DateTime.now().millisecondsSinceEpoch %
        algorithms.length];
  }

  // 随机生成AI问题
  String _getRandomProblem() {
    final problems = ['图像分类', '语音识别', '文本生成', '机器翻译', '异常检测', '情感分析'];
    return problems[DateTime.now().millisecondsSinceEpoch % problems.length];
  }

  // 随机生成软件开发阶段
  String _getRandomSoftwarePhase() {
    final phases = ['需求分析', '系统设计', '编码实现', '测试验证', '部署维护', '迭代优化'];
    return phases[DateTime.now().millisecondsSinceEpoch % phases.length];
  }

  // 随机生成分布式系统问题
  String _getRandomDistributedProblem() {
    final problems = ['一致性', '可用性', '分区容错', '数据同步', '负载均衡', '故障恢复'];
    return problems[DateTime.now().millisecondsSinceEpoch % problems.length];
  }

  // 随机生成微服务技术
  String _getRandomMicroserviceTech() {
    final techs = [
      'Docker',
      'Kubernetes',
      'gRPC',
      'REST API',
      'Kafka',
      'Consul',
      'Istio',
    ];
    return techs[DateTime.now().millisecondsSinceEpoch % techs.length];
  }

  // 随机生成前端技术
  String _getRandomFrontendTech() {
    final techs = [
      'React Hooks',
      'Vue的响应式系统',
      'Angular的依赖注入',
      'WebComponents',
      'CSS Grid布局',
      'TypeScript类型系统',
    ];
    return techs[DateTime.now().millisecondsSinceEpoch % techs.length];
  }

  // 随机生成JavaScript示例
  String _getRandomJSExample() {
    final examples = [
      'function handleClick() {\n  const element = document.getElementById("demo");\n  element.innerHTML = "Hello JavaScript!";\n}',
      'const Counter = () => {\n  const [count, setCount] = useState(0);\n  return (\n    <div>\n      <p>{count}</p>\n      <button onClick={() => setCount(count + 1)}>Increment</button>\n    </div>\n  );\n}',
      'export default {\n  data() {\n    return {\n      message: "Hello Vue!"\n    }\n  },\n  methods: {\n    reverseMessage() {\n      this.message = this.message.split("").reverse().join("");\n    }\n  }\n}',
      'document.querySelectorAll(".item").forEach(item => {\n  item.addEventListener("click", function() {\n    this.classList.toggle("active");\n  });\n});',
    ];
    return examples[DateTime.now().millisecondsSinceEpoch % examples.length];
  }

  // 随机生成算法思想
  String _getRandomAlgorithmIdea() {
    final ideas = [
      '分治法，将问题分解为子问题分别解决',
      '动态规划，通过存储子问题的解来避免重复计算',
      '贪心策略，每步选择当前最优解',
      '回溯法，通过尝试所有可能的解决方案来找到最优解',
      '深度优先搜索，尽可能深地搜索树的分支',
      '广度优先搜索，逐层扩展搜索范围',
    ];
    return ideas[DateTime.now().millisecondsSinceEpoch % ideas.length];
  }

  // 随机生成算法伪代码
  String _getRandomPseudocode() {
    final codes = [
      'function solve(problem):\n  if problem is simple:\n    return solution\n  else:\n    divide problem into subproblems\n    solve each subproblem\n    combine solutions\n    return combined solution',
      'function quicksort(array, left, right):\n  if left < right:\n    pivot = partition(array, left, right)\n    quicksort(array, left, pivot-1)\n    quicksort(array, pivot+1, right)',
      'for i from 1 to n:\n  key = array[i]\n  j = i - 1\n  while j >= 0 and array[j] > key:\n    array[j+1] = array[j]\n    j = j - 1\n  array[j+1] = key',
      'function bfs(graph, start):\n  queue = [start]\n  visited = {start}\n  while queue is not empty:\n    node = queue.dequeue()\n    for neighbor in graph[node]:\n      if neighbor not in visited:\n        visited.add(neighbor)\n        queue.enqueue(neighbor)',
    ];
    return codes[DateTime.now().millisecondsSinceEpoch % codes.length];
  }

  // 随机生成算法应用
  String _getRandomAlgorithmApplication() {
    final applications = [
      '路径规划',
      '自然语言处理',
      '图像识别',
      '推荐系统',
      '网络流量分析',
      '基因序列比对',
      '金融市场预测',
      '数据压缩',
    ];
    return applications[DateTime.now().millisecondsSinceEpoch %
        applications.length];
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

      // 通知QuestionBankController更新复仇关卡
      if (Get.isRegistered<QuestionBankController>()) {
        final questionBankController = Get.find<QuestionBankController>();
        questionBankController.addRevengeChallenge(revengeChallenge);
        questionBankController.showRevengeSection.value = true;
        print('已将复仇关卡通知给QuestionBankController');
      } else {
        print('QuestionBankController未注册，无法更新复仇关卡');
      }

      // 解锁"命题者"成就
      if (Get.isRegistered<AchievementService>()) {
        final achievementService = Get.find<AchievementService>();
        achievementService.unlockAchievement('create_challenge');
      }
    } catch (e) {
      print('创建复仇关卡出错: $e');
    }
  }

  // 导航到复仇关卡
  void _navigateToRevengeChallenge() {
    if (revengeChallenges.isEmpty) return;

    final latestChallenge = revengeChallenges.last;

    // 确保QuestionBankController已经更新了复仇关卡
    if (Get.isRegistered<QuestionBankController>()) {
      Get.find<QuestionBankController>().addRevengeChallenge(latestChallenge);
    }

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
