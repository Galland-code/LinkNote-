import 'package:get/get.dart';
import '../../../data/models/question.dart';
import '../../../data/models/note.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/repositories/note_repository.dart';
import '../../../data/services/quiz_service.dart';
import '../../../routes/app_routes.dart';
// 增加对话框类
class ChatMessage {
  final String content;
  final bool isAI;
  final bool hasHint;

  ChatMessage({
    required this.content,
    this.isAI = false,
    this.hasHint = false,
  });
}
class QuizController extends GetxController {
  // new message
  final messageList = <ChatMessage>[].obs;
  final currentScore = 0.obs;
  final currentProgress = 0.0.obs;
  final currentDifficulty = '基础'.obs;
  final isLoadingAI = false.obs;
  // Dependencies
  final QuestionRepository _questionRepository = Get.find<QuestionRepository>();
  final NoteRepository _noteRepository = Get.find<NoteRepository>();
  final QuizService _quizService = Get.find<QuizService>();

  // Observable variables
  final RxInt currentNavIndex = 1.obs;
  final RxList<Question> questions = <Question>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Challenge generation
  final RxList<Note> notes = <Note>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedNoteId = ''.obs;
  final RxString selectedDifficulty = '简单'.obs;//默认简单

  // Challenge history
  final RxList<Map<String, dynamic>> challengeHistory = <Map<String, dynamic>>[].obs;

  // Current question state
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool isAnswered = false.obs;
  final RxInt selectedAnswerIndex = (-1).obs;

  // Timer
  final RxInt timer = 60.obs;  // Timer for each question
  late Rxn<int> timerInterval; // Interval for timer updating

  // Statistics
  final RxMap<String, dynamic> quizStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
    loadNotes();
    loadChallengeHistory();
    updateQuizStats();
    startTimer();
    loadQuestions();
    loadNotes();
    loadChallengeHistory();
    updateQuizStats();
    startQnaSession(); // 初始化问答会话
  }

  // Load all questions
  Future<void> loadQuestions() async {
    try {
      isLoading.value = true;
      questions.value = await _questionRepository.getQuestions();
      isLoading.value = false;
      errorMessage.value = '';
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载问题失败: $e';
    }
  }

  // Load all notes for selection
  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      notes.value = await _noteRepository.getNotes();

      // Extract unique categories
      final Set<String> categorySet = {};
      for (var note in notes) {
        categorySet.add(note.category);
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
    selectedNoteId.value = '';
  }

  // Select specific note for challenge
  void selectNote(String noteId) {
    selectedNoteId.value = noteId;
    final note = notes.firstWhere((n) => n.id == noteId, orElse: () => notes.first);
    selectedCategory.value = note.category;
  }

  // Generate a new challenge based on selection
  Future<void> generateChallenge() async {
    try {
      isLoading.value = true;

      List<Question> challengeQuestions = [];
      String challengeTitle = '';

      if (selectedNoteId.value.isNotEmpty) {
        final note = notes.firstWhere((n) => n.id == selectedNoteId.value);
        challengeTitle = '${note.title} - 挑战';
        challengeQuestions = await _questionRepository.getQuestionsFromNoteContent(note);
      } else if (selectedCategory.value.isNotEmpty) {
        challengeTitle = '${selectedCategory.value} - 分类挑战';
        challengeQuestions = await _questionRepository.getQuestionsFromCategory(selectedCategory.value);
      } else {
        challengeTitle = '随机挑战';
        challengeQuestions = questions.toList()..shuffle();
        challengeQuestions = challengeQuestions.take(10).toList();
      }

      final challenge = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': challengeTitle,
        'source': selectedNoteId.value.isNotEmpty
            ? notes.firstWhere((n) => n.id == selectedNoteId.value).title
            : selectedCategory.value.isNotEmpty ? selectedCategory.value : '多个来源',
        'questionCount': challengeQuestions.length,
        'completedCount': 0,
        'date': DateTime.now(),
        'questions': challengeQuestions,
        'levels': challengeQuestions,
      };

      challengeHistory.insert(0, challenge);

      isLoading.value = false;

      questions.value = challengeQuestions;
      currentQuestionIndex.value = 0;
      isAnswered.value = false;
      selectedAnswerIndex.value = -1;

      Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challenge});
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '生成挑战失败: $e';
    }
  }

  // Continue an existing challenge
  void continueChallenge(Map<String, dynamic> challenge) {
    questions.value = List<Question>.from(challenge['questions']);
    currentQuestionIndex.value = challenge['completedCount'];
    isAnswered.value = false;
    selectedAnswerIndex.value = -1;

    if (challenge['completedCount'] < challenge['questionCount']) {
      Get.toNamed(Routes.QUIZ_QUESTION);
    } else {
      Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challenge});
    }
  }

  // Answer current question
  Future<void> answerQuestion(int index) async {
    if (isAnswered.value) return;

    isAnswered.value = true;
    selectedAnswerIndex.value = index;

    final currentQuestion = questions[currentQuestionIndex.value];
    final isCorrect = await _quizService.recordAnswer(currentQuestion.id, index);

    updateQuizStats();

    if (challengeHistory.isNotEmpty) {
      final challengeIndex = challengeHistory.indexWhere((c) => c['questions'] == questions.value || (c['questionCount'] == questions.length && c['title'].contains(currentQuestion.source)));

      if (challengeIndex >= 0) {
        final challenge = challengeHistory[challengeIndex];
        challenge['completedCount'] = currentQuestionIndex.value + 1;
        challengeHistory[challengeIndex] = challenge;
      }
    }

    await Future.delayed(Duration(seconds: 1));
    nextQuestion();
  }

  // Move to next question
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      isAnswered.value = false;
      selectedAnswerIndex.value = -1;
    } else {
      Get.toNamed(Routes.QUIZ_RESULT);
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
  final RxList<Map<String, dynamic>> qnaConversation = <Map<String, dynamic>>[].obs;
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
      'keywords': [
        '字符串',
        '列表',
        '集合',
        '有序集合',
        '哈希',
      ],
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
      'text': '我们从牛客网的模拟面试题库中为你挑选了一个问题：\n${randomQuestion['question']}\n请试着列出Redis的常用数据结构吧！',
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
    final matchedKeywords = keywords.where((kw) => allUserAnswers.contains(kw)).toList();
    final matchRate = matchedKeywords.length / keywords.length;
    final attemptCount = qnaConversation.where((msg) => msg['isUser'] == true).length;

    String feedback;
    if (matchRate >= 0.8) {
      feedback =
      '太棒了！你的回答非常全面，涵盖了${matchedKeywords.join("、")}等关键数据结构，已经没有什么遗漏了。问答结束！';
      qnaConversation.add({'text': feedback, 'isUser': false});
      Future.delayed(Duration(seconds: 2), () => Get.back());
    } else if (matchRate >= 0.4) {
      final missingKeywords = keywords.where((kw) => !matchedKeywords.contains(kw)).toList();
      feedback =
      '很好！你已经提到了一些重要数据结构，比如${matchedKeywords.join("、")}。不过还有${missingKeywords.length}种没提到，比如${missingKeywords.first}，${hints[missingKeywords.first]}再想想看？';
      qnaConversation.add({'text': feedback, 'isUser': false});
    } else {
      final missingKeywords = keywords.where((kw) => !matchedKeywords.contains(kw)).toList();
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



}
